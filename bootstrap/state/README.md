# Terraform State Bucket Bootstrap

This separate, local-state configuration prepares a private, encrypted, versioned S3 bucket for Terraform state. It enables S3 native state locking in the application backend configuration. The bucket has `prevent_destroy` and `force_destroy = false`.

No AWS resources are created by reading this folder. Review the account, bucket name, and plan before a human operator applies this bootstrap. Keep its own local state file private and backed up.

Example commands from this directory:

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -var="state_bucket_name=REPLACE_WITH_GLOBALLY_UNIQUE_NAME"
```

After the bucket is deliberately created, copy `backend.tf.example` to `backend.tf`, copy one of the backend configuration examples to a private `.hcl` file, and replace its bucket placeholder. Use a separate state key for each environment.

For a local state migration, back up the existing state first, then initialize with the appropriate backend file and `-migrate-state`. Do not use the old `terraform.tfstate.backup` as the current deployment state. Confirm account, region, workspace, and state lineage before migration.
