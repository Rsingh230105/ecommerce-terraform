# E-Commerce AWS Infrastructure (Terraform)

This project defines the AWS infrastructure intended to host the Product, Order, and Inventory services. Terraform configuration is a desired-state definition; a resource block alone does not mean the resource currently exists.

## Current status

The owner reports that `terraform apply` completed successfully and that the stack was subsequently destroyed to reduce costs. The selected `default` workspace's local `terraform.tfstate` currently has no managed resources, which is consistent with that report. This checkout does not configure a remote backend. An older `terraform.tfstate.backup` is present; it appears to predate the destroy and is not the active state. Neither local state file independently verifies the AWS account: check the intended AWS account and region before assuming everything is gone.

The configuration passed `terraform fmt -check -recursive` and `terraform validate` after the production-safety changes. The dev plan reports 82 additions and no changes or destroys against the empty active state. A prior saved plan is stale evidence and must not be applied as a substitute for a fresh plan.

This remains a **development project, not production-approved infrastructure**. Production planning now requires an ACM certificate ARN in `ap-south-1`, at least two tasks for each API, and a database class other than the dev `db.t3.micro`. A domain and validated ACM certificate do not exist yet, so the production example intentionally cannot be planned successfully until those prerequisites are met.

Current development configuration in `terraform.tfvars`:

- Region: `ap-south-1`
- Project/environment: `ecommerce-dev`
- Product image: `v1.0.1`
- Order image: `v1.0.3`
- Inventory image: `v1.0.4`

Check that the immutable image tags exist in the correct ECR repositories before applying. Do not infer that ECR repositories or any other resources still exist just because Terraform defines them.

## Resources described by the configuration

The root configuration currently defines or wires together:

- VPC, public/private subnets, internet gateway, NAT gateway, routes, and security groups
- Public Application Load Balancer with HTTP routing in dev and certificate-backed HTTPS/HTTP redirect in prod
- ECR repositories for Product, Order, and Inventory
- ECS Fargate cluster, task definitions, API services, and separate Order Outbox Publisher service
- Private PostgreSQL RDS and its Secrets Manager-managed master credentials
- CloudWatch log groups and IAM execution/application roles and policies
- ECS Service Connect namespace and Product Service discovery
- SNS Order Events topic, Inventory SQS queue, DLQ, subscription, queue policy, and redrive configuration
- Product media S3 bucket

Check the `.tf` files and a fresh `terraform plan` for exact current behavior. The Terraform state is the record of resources managed by the selected state; the AWS account is the authority on what exists.

## Request and event networking

```text
Internet -> ALB :80 -> /products/*  -> Product task :8000
                    -> /orders/*    -> Order task :8001
                    -> /inventory/* -> Inventory task :8002

Order task -> Service Connect product-service:8000 -> Product task

Order outbox -> Publisher task -> SNS -> Inventory SQS -> Inventory task
                                                      -> DLQ after retries
```

Application tasks are configured for private subnets with public IP assignment disabled. Security groups allow ALB-to-API traffic, ECS-to-Product traffic for Service Connect, and ECS-to-RDS PostgreSQL traffic. Review the current routing/security-group files and plan whenever ports or network topology change.

## Key configuration files

| File | Main area |
|---|---|
| `provider.tf`, `versions.tf` | AWS provider and Terraform version constraints |
| `variables.tf`, `terraform.tfvars` | Configurable project values and dev settings |
| `main.tf` | Root module calls and resource-address migration blocks |
| `environments/` | Example dev/prod inputs and separate S3 backend configuration examples |
| `bootstrap/state/` | Plan-only bootstrap configuration for a protected Terraform state bucket |
| `backend.tf.example` | Optional S3 backend declaration; activate only after reviewing the bootstrap |
| `modules/networking/` | VPC, subnets, gateways, routes, inputs, and outputs |
| `modules/security/` | ALB, ECS, and RDS security groups and network rules |
| `modules/alb/` | ALB, target groups, listener, path routing, and outputs |
| `modules/ecr/` | Image repositories, lifecycle policy, and repository URL outputs |
| `modules/ecs/` | ECS cluster, task definitions, services, Service Connect namespace, and outputs |
| `modules/database/` | PostgreSQL RDS instance, subnet group, and connection/secret outputs |
| `modules/storage/` | Product media S3 bucket, security configuration, and outputs |
| `modules/iam/` | ECS execution/task roles, scoped policies, attachments, and outputs |
| `modules/observability/` | CloudWatch log groups and retention |
| `modules/messaging/` | SNS topic, Inventory queues, subscription, queue policies, redrive, and outputs |
| `outputs.tf` | Useful output values |

## Safe workflow after destroy

Run commands from this directory. Use the same AWS account, region, and state backend as the deployment being managed.

The current root uses local state until the state bucket has been deliberately bootstrapped. Do not plan/apply production with local state. The `bootstrap/state/` configuration is code only: select a globally unique bucket name, review its plan, then have a human operator apply it. Afterward, activate `backend.tf.example` as `backend.tf`, create private dev/prod `.hcl` files from the examples with the actual bucket name, and migrate/reconfigure state deliberately. The backend config files are ignored by Git.

Use separate state keys and explicit environment files. Example commands after backend setup:

```powershell
terraform init -backend-config=environments/backend-dev.hcl -migrate-state
terraform plan -var-file=environments/dev.tfvars
```

For production, use the separate state key and do not copy dev state into it:

```powershell
terraform init -backend-config=environments/backend-prod.hcl -reconfigure
terraform plan -var-file=environments/prod.tfvars
```

Replace all `.example` files with private working copies; never plan with the placeholder certificate or image tags. Verify `aws sts get-caller-identity`, region, backend key, and selected input file every time before a production plan.

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

Review the plan and confirm the intended account/environment before applying:

```powershell
terraform apply
```

Do not apply saved `.tfplan` files from a previous configuration or deployment. Rebuild and push service images first if the selected image tags are not present in ECR. Before a future destroy, inspect the plan and back up any state or data you need. Destroy can permanently delete RDS data and other infrastructure.

Useful checks after applying include `terraform state list`, `terraform output`, ECS service/task health, ALB target health, RDS connectivity, and a full create-order-to-inventory event test. These checks confirm different things: state list shows Terraform tracking, while AWS health and end-to-end behavior show runtime operation.

After a successful apply, Terraform prints `application_base_url`, `product_service_url`, `order_service_url`, and `inventory_service_url`. These use the ALB's generated DNS name, so a custom domain is not needed for development. The service URLs point to the API path prefixes and can be used with a browser or API client. Re-run `terraform output` later to retrieve them.

Terraform provisions the ECR repositories but does not build or push Docker images. Before creating ECS services, the selected immutable image tags must already exist in those repositories; otherwise tasks cannot start and the apply may fail while waiting for service stability. A fully automated build-and-deploy flow needs a CI/CD runner with AWS OIDC permissions and Docker builds; it is not performed by a plain `terraform apply`.

## Cost and deletion considerations

- NAT Gateway and RDS may incur charges while provisioned, even with little application traffic.
- The ECR repositories set `force_delete = true` for `dev`; Terraform can remove repositories even when they contain images. This can erase image history and prevent rollbacks.
- Destroying RDS can destroy application data. Back up or export data first if it matters.
- Saved local state and plan files may contain infrastructure metadata. Keep them private and do not commit sensitive state or secrets.
- Use `.gitignore` to keep local state, plan files, credentials, and `.terraform` working data out of source control; use a secured remote backend with locking for team or long-lived use.

## Terraform module refactor progress

**Step 1 complete: Networking module.** The VPC, public/private subnets, Internet Gateway, NAT Gateway, Elastic IP, routes, and route-table associations are now under `modules/networking/`. Root configuration uses module outputs for ALB, ECS, security groups, RDS, and Terraform outputs. The original resource settings and CIDR defaults were preserved. Root `moved` blocks are included for the old network resource addresses so an existing state can be migrated without treating the refactor itself as resource replacement.

**Step 2 complete: Security module.** The ALB, ECS, and RDS security groups and their ingress/egress rules are now under `modules/security/`. The root module passes the VPC ID/CIDR and service ports into it, and ALB, ECS, RDS, and root outputs consume the module's security-group outputs. Rule ports, protocols, sources, descriptions, and tags have been kept the same. Root `moved` blocks are included for the previous security-group and rule addresses.

**Step 3 complete: ECR module.** The three immutable repositories and the existing Product repository lifecycle policy are now under `modules/ecr/`. The root module passes project/environment and the existing development `force_delete` choice. ECS task definitions and root outputs now use ECR module outputs. Existing repository names, image-scanning, AES256 encryption, tags, and lifecycle rules are preserved. Root `moved` blocks cover the three repositories and the Product lifecycle policy.

Deletion warning: `force_delete` remains true for `dev`, just as before. Destroying the dev stack may delete images in those ECR repositories, which can remove rollback versions. The lifecycle policy is only attached to Product; Order and Inventory do not gain new cleanup rules in this refactor.

**Step 4 complete: Database module.** The RDS PostgreSQL instance and DB subnet group are now under `modules/database/`. The root passes the private subnet IDs and RDS security-group ID into the module. ECS task definitions, the Secrets Manager access policy, and root outputs consume database module outputs for the endpoint, port, database name, and master secret ARN. Resource identifiers and the prior RDS behavior were preserved, and root `moved` blocks cover the previous RDS resource addresses.

**RDS safety note:** current development settings still disable automated backups (`backup_retention_period = 0`), disable deletion protection, and skip the final snapshot. A destroy can permanently remove database data. These settings were preserved intentionally for this structural step; review retention and snapshot choices before any future apply/destroy.

**Step 5 complete: Messaging module.** The Order Events SNS topic, Inventory SQS queue and DLQ, SNS-to-SQS subscription, queue policy, and redrive policies are now under `modules/messaging/`. The root task definitions, IAM policies, and outputs consume module outputs. Existing queue names, retention, visibility timeout, long polling, encryption, raw delivery, SNS source restriction, and three-receive redrive threshold were preserved. Root `moved` blocks cover the seven moved managed resources.

**Step 6 complete: Observability module.** The Product, Order, and Inventory CloudWatch log groups are now under `modules/observability/`. ECS task definitions and root outputs reference log-group name outputs from the module. Names, seven-day retention, and tags were preserved; root `moved` blocks cover the prior log-group resource addresses.

**Step 7 complete: Storage module.** The Product media S3 bucket and its versioning, AES256 server-side encryption, public-access-block, and bucket-owner-enforced ownership controls are now under `modules/storage/`. Root outputs use the storage module's name and ARN outputs. Bucket naming and settings were preserved, and root `moved` blocks cover the five moved managed resources.

**Step 8 complete: ALB module.** The public Application Load Balancer, Product/Order/Inventory target groups, HTTP listener, and path-routing rules are now under `modules/alb/`. The module accepts networking/security-group outputs and the existing service ports; ECS services consume its target-group outputs and depend on the module. Listener port 80, route patterns/priorities, default 404 response, health-check paths, protocols, and thresholds were preserved. Root `moved` blocks cover the eight moved managed resources.

**Step 9 complete: ECS module.** The ECS cluster, four task definitions, four ECS services (including the Order outbox publisher), and Service Connect namespace are now under `modules/ecs/`. The module takes explicit inputs from networking, security, ALB, ECR, database, messaging, observability, and the IAM module. Task sizing, image tags, environment variables/secrets, log settings, desired counts, ports, private-subnet placement, Service Connect, service ordering, and deployment settings were preserved. Root `moved` blocks cover all ten moved managed resources; cluster outputs now come from the ECS module.

**Step 10 complete: IAM module.** The ECS execution role and managed-policy attachment, Product/Order/Inventory task roles, Inventory SQS consumer policy and attachment, Order SNS publish policy and attachment, and execution-role database-secret policy are now under `modules/iam/`. Existing role/policy names, trust policies, actions, resource scoping, and tags were preserved. The module receives only the database-secret, Order SNS topic, and Inventory queue ARNs it needs, and exports role/policy ARNs for ECS and root outputs. Root `moved` blocks cover all ten moved IAM resources.

Checks completed for Steps 1–10:

- `terraform fmt -check -recursive` passed after each module change.
- `terraform validate` passed after each module change.
- After Step 1, a fresh plan reported `82 to add, 0 to change, 0 to destroy`. This is expected after the reported destroy and empty local state; it is **not** a plan to apply as part of the refactor.
- After Step 2, a fresh plan also reported `82 to add, 0 to change, 0 to destroy`. The plan now shows security resources under `module.security`; all creates are expected because the local state is empty.
- Step 3: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; ECR resources are now shown under `module.ecr`.
- Step 4: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; the RDS resources are now shown under `module.database`.
- Step 5: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; the SNS/SQS managed resources now appear under `module.messaging`.
- Step 6: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; the CloudWatch log groups now appear under `module.observability`.
- Step 7: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; the S3 resources now appear under `module.storage`.
- Step 8: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; ALB resources now appear under `module.alb`.
- Step 9: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; ECS resources now appear under `module.ecs`.
- Step 10: `terraform fmt -check -recursive` and `terraform validate` passed. The fresh plan reported `82 to add, 0 to change, 0 to destroy`, as expected with empty local state; IAM resources now appear under `module.iam`.
- No `terraform apply` was run.

The reusable infrastructure resources are now grouped into modules. The migration-address review is recorded below. Before redeploying, verify the intended AWS account and region, confirm whether any resources still exist, verify the selected image tags in ECR, and review a fresh plan. With the active state empty, expect a create plan; do not restore or use the older backup state as if it were current.

### Migration-address review (2026-10-09)

- The active `default` workspace state contains zero managed resources. The older local backup contains 82 managed resources and three data-source records; it appears to be a pre-destroy snapshot, not a current deployment state.
- All 82 managed addresses in that backup match the 82 `moved` block source addresses in `main.tf`. The destinations are unique, and every source/destination pair keeps the same Terraform resource type.
- Data sources are read-only and will be evaluated again at their current module addresses; they do not need managed-resource `moved` blocks.
- This is a static address-coverage result, **not** proof of a successful migration against a live, non-empty state. The fresh plan using the active empty state reports 82 creates. No plan was applied, and the older backup was not treated as the active state.

**Conclusion:** the moved-address mapping is complete against the available pre-destroy snapshot. Since the deployment was destroyed and the active state is empty, there is no current non-empty deployment state here against which to certify an in-place migration. If the stack is redeployed from this empty state, review it as a new create operation instead.

### Production-safety preparation (2026-10-09)

- Added example input files for dev and prod; production requires a valid ACM certificate ARN in the selected region, non-placeholder image tags, at least two desired tasks for each API service, and a non-`db.t3.micro` RDS class.
- Added production-only HTTPS listener behavior (HTTP redirects to HTTPS), port 443 ingress, ALB deletion protection, 30-day RDS backup retention, deferred RDS changes (`apply_immediately = false`), 30-day log retention, and two NAT Gateways with AZ-specific private routing. Dev keeps HTTP, one NAT Gateway, seven-day log retention, and existing cost-oriented database settings.
- Added a separate state-bucket bootstrap configuration with versioning, server-side encryption, public-access blocking, TLS-only bucket policy, and deletion protection. S3 backend declaration/configuration examples use separate dev/prod keys and native S3 locking. No state bucket or application infrastructure was created.
- Validation: formatting and `terraform validate` passed for the application configuration and state-bucket bootstrap. The current dev plan remains 82 creates. A production plan without a certificate or with placeholder image tags was correctly rejected; a production plan with one API task or `db.t3.micro` was also rejected. Using a syntactically valid sample ARN and sample tags to inspect resource shape produced 88 creates, with HTTPS, two NAT Gateways, Multi-AZ RDS, API counts, and production safeguards. The sample ARN was not checked against ACM and must not be used.

These changes improve production safeguards but do not make the system production-ready. Before launch, acquire a domain and DNS-validate a real ACM certificate; choose/verify database and Fargate sizing using workload data; confirm pushed immutable image tags; configure alerting, autoscaling, WAF/rate limits and operational runbooks; test backups/restores and deployments; and review security/IAM and cost estimates. No `terraform apply` was run.

## Recommended module layout

The current root configuration is being refactored incrementally into reusable modules. Keep each step a **behavior-preserving refactor**; do not combine module moves with a major network or resource redesign.

Suggested structure:

```text
ecommerce-terraform/
├── README.md
├── versions.tf
├── provider.tf
├── backend.tf.example         # activate after state-bucket bootstrap
├── main.tf                    # module calls and moved blocks
├── variables.tf
├── outputs.tf
├── environments/
│   ├── dev.tfvars.example
│   ├── prod.tfvars.example
│   ├── backend-dev.hcl.example
│   └── backend-prod.hcl.example
├── bootstrap/
│   └── state/                 # S3 state bucket bootstrap
└── modules/
    ├── networking/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/
    ├── alb/
    ├── ecr/
    ├── ecs/
    ├── database/
    ├── messaging/
    ├── observability/
    └── storage/
```

Start by grouping and documenting module interfaces, not by trying to turn every repeated line into a generic abstraction. A module should expose only the inputs and outputs its callers need. Keep environment-specific values outside reusable modules. Consider one state per environment (and a secure remote backend with locking) before adding staging or production.

### Refactor acceptance checklist

1. Record the current resource addresses, outputs, and a fresh baseline plan using the intended state/backend.
2. Move a small, coherent group of resources into one module at a time.
3. Preserve resource addresses with `moved` blocks or carefully reviewed `terraform state mv` operations when state is non-empty. Do not casually re-create production resources during a refactor.
4. Re-run `terraform fmt`, `terraform validate`, and a fresh `terraform plan` after each group.
5. Confirm the plan contains no unexpected creates, replacements, or destroys. An empty-state plan after destroy is not a substitute for testing state migration against a non-empty development deployment.
6. Apply only after reviewing the plan and confirming account, region, and environment.
7. Update this README with the final module responsibilities and a tested deploy/destroy workflow.

## Remaining production work

- Bootstrap and activate S3 remote state; verify environment keys and account access policies before any production apply.
- Obtain a domain, DNS-validate an ACM certificate in `ap-south-1`, and replace the production certificate placeholder.
- Load-test and confirm database/Fargate sizing and monthly costs; consider RDS Proxy if connection counts require it.
- Add CloudWatch alarms/notifications, ECS autoscaling, WAF/rate limiting, and deployment/rollback runbooks.
- Replace broad or unnecessary IAM permissions with service-specific least privilege.
- Decide whether dev ECR repositories should retain images on Terraform destroy; use lifecycle policies for image cleanup rather than force-deleting entire repositories.
- Add a one-off migration deployment step and gate Order API/publisher rollout on migration success.
- Extend CI with security scanning and remote-state-backed plan review; never auto-apply unreviewed production plans.

## GitHub Actions

The `Terraform checks` workflow runs formatting and validation on pull requests and pushes to `dev`. It initializes Terraform with `-backend=false`; it does not access AWS, create resources, or apply changes.

There is intentionally no automated Terraform apply workflow yet. The S3 backend is still an example and has not been bootstrapped or activated, and the infrastructure was destroyed to save cost. Do not run Terraform apply from an ephemeral GitHub runner with local state. First bootstrap and configure the protected remote state backend, then add an explicitly approved deployment workflow with GitHub OIDC and environment protection.

The service repositories have their own development deployment workflows. Terraform continues to own task-definition templates and ignores only the ECS services' deployed task-definition revisions; this prevents a later Terraform apply from reverting CI releases. A task-definition template change is picked up by the next successful service deployment. After the development infrastructure has been applied, configure each service's GitHub OIDC role and repository variables as described in its README. On a successful apply, the Terraform outputs still print the ALB base URL and all three service URLs; retrieve them later with `terraform output`.
