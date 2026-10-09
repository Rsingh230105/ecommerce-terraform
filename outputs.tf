# ------------------------------------------------------------
# SNS Outputs
# ------------------------------------------------------------

output "order_events_topic_arn" {
  # ARN of the SNS topic used for Order events.
  description = "ARN of the Order Events SNS topic"
  value       = module.messaging.order_events_topic_arn
}


# ------------------------------------------------------------
# SQS Main Queue Outputs
# ------------------------------------------------------------

output "inventory_queue_url" {
  # URL used by the Inventory Service to receive messages.
  description = "URL of the Inventory SQS queue"
  value       = module.messaging.inventory_queue_url
}

output "inventory_queue_arn" {
  # ARN uniquely identifies the Inventory SQS queue.
  description = "ARN of the Inventory SQS queue"
  value       = module.messaging.inventory_queue_arn
}


# ------------------------------------------------------------
# SQS DLQ Outputs
# ------------------------------------------------------------

output "inventory_dlq_url" {
  # URL used to inspect failed Inventory messages.
  description = "URL of the Inventory Dead Letter Queue"
  value       = module.messaging.inventory_dlq_url
}

output "inventory_dlq_arn" {
  # ARN uniquely identifies the Inventory Dead Letter Queue.
  description = "ARN of the Inventory Dead Letter Queue"
  value       = module.messaging.inventory_dlq_arn
}


# ------------------------------------------------------------
# SNS -> SQS Subscription Output
# ------------------------------------------------------------

output "inventory_subscription_arn" {
  # ARN of the subscription connecting SNS to Inventory SQS.
  description = "ARN of the SNS to SQS subscription"
  value       = module.messaging.inventory_subscription_arn
}

# ------------------------------------------------------------
# S3 Output
# ------------------------------------------------------------

output "product_media_bucket_name" {
  # Bucket name used by the application to store product media.
  description = "Name of the Product Media S3 bucket"
  value       = module.storage.product_media_bucket_name
}


output "product_media_bucket_arn" {
  # ARN uniquely identifies the Product Media S3 bucket.
  description = "ARN of the Product Media S3 bucket"
  value       = module.storage.product_media_bucket_arn
}


# ------------------------------------------------------------
# ECR Outputs
# ------------------------------------------------------------

output "product_service_ecr_repository_url" {
  # Docker image repository URL for the Product Service.
  description = "ECR repository URL for Product Service"
  value       = module.ecr.product_service_repository_url
}


output "order_service_ecr_repository_url" {
  # Docker image repository URL for the Order Service.
  description = "ECR repository URL for the Order Service"
  value       = module.ecr.order_service_repository_url
}


output "inventory_service_ecr_repository_url" {
  # Docker image repository URL for the Inventory Service.
  description = "ECR repository URL for the Inventory Service"
  value       = module.ecr.inventory_service_repository_url
}

# ------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------

output "vpc_id" {
  # ID of the main e-commerce VPC.
  description = "ID of the e-commerce VPC"
  value       = module.networking.vpc_id
}


output "public_subnet_ids" {
  # IDs of the public subnets used by the ALB.
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}


output "private_subnet_ids" {
  # IDs of the private subnets used by ECS and RDS.
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}


output "nat_gateway_id" {
  # ID of the NAT Gateway used by private subnets.
  description = "ID of the NAT Gateway"
  value       = module.networking.nat_gateway_id
}

# ------------------------------------------------------------
# Security Group Outputs
# ------------------------------------------------------------

output "alb_security_group_id" {
  # Security group ID used by the public Application Load Balancer.
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}


output "ecs_security_group_id" {
  # Security group ID used by ECS application tasks.
  description = "ID of the ECS security group"
  value       = module.security.ecs_security_group_id
}


output "rds_security_group_id" {
  # Security group ID used by the PostgreSQL RDS instance.
  description = "ID of the RDS security group"
  value       = module.security.rds_security_group_id
}


# ------------------------------------------------------------
# RDS Outputs
# ------------------------------------------------------------

output "rds_endpoint" {
  # DNS hostname used by applications to connect to PostgreSQL.
  description = "RDS PostgreSQL endpoint"
  value       = module.database.endpoint
}


output "rds_port" {
  # PostgreSQL port exposed inside the VPC.
  description = "RDS PostgreSQL port"
  value       = module.database.port
}


output "rds_database_name" {
  # Application database name.
  description = "RDS database name"
  value       = module.database.database_name
}


output "rds_master_secret_arn" {
  # ARN of the Secrets Manager secret created and managed by RDS.
  #
  # We output the ARN, not the actual password.
  description = "ARN of the RDS-managed master password secret"
  value       = module.database.master_secret_arn
}

# ------------------------------------------------------------
# ECS Outputs
# ------------------------------------------------------------

output "ecs_cluster_name" {
  # Name of the ECS cluster where our services will run.
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}


output "ecs_cluster_arn" {
  # ARN uniquely identifies the ECS cluster.
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

# ------------------------------------------------------------
# Public Application URLs
# ------------------------------------------------------------

output "application_base_url" {
  description = "Base URL of the public application load balancer"
  value       = "${var.environment == "prod" ? "https" : "http"}://${module.alb.load_balancer_dns_name}"
}

output "product_service_url" {
  description = "Product Service API base URL"
  value       = "${var.environment == "prod" ? "https" : "http"}://${module.alb.load_balancer_dns_name}/products"
}

output "order_service_url" {
  description = "Order Service API base URL"
  value       = "${var.environment == "prod" ? "https" : "http"}://${module.alb.load_balancer_dns_name}/orders"
}

output "inventory_service_url" {
  description = "Inventory Service API base URL"
  value       = "${var.environment == "prod" ? "https" : "http"}://${module.alb.load_balancer_dns_name}/inventory"
}


# ------------------------------------------------------------
# CloudWatch Log Group Outputs
# ------------------------------------------------------------

output "product_log_group_name" {
  # CloudWatch log group used by the Product Service.
  description = "Product Service CloudWatch log group"
  value       = module.observability.product_log_group_name
}


output "order_log_group_name" {
  # CloudWatch log group used by the Order Service.
  description = "Order Service CloudWatch log group"
  value       = module.observability.order_log_group_name
}


output "inventory_log_group_name" {
  # CloudWatch log group used by the Inventory Service.
  description = "Inventory Service CloudWatch log group"
  value       = module.observability.inventory_log_group_name
}

# ------------------------------------------------------------
# ECS Application Task Role Outputs
# ------------------------------------------------------------

output "product_task_role_arn" {
  # IAM role used by the Product Service container.
  description = "ARN of the Product Service ECS task role"
  value       = module.iam.product_task_role_arn
}


output "order_task_role_arn" {
  # IAM role used by the Order Service container.
  description = "ARN of the Order Service ECS task role"
  value       = module.iam.order_task_role_arn
}


output "inventory_task_role_arn" {
  # IAM role used by the Inventory Service container.
  description = "ARN of the Inventory Service ECS task role"
  value       = module.iam.inventory_task_role_arn
}


output "order_sns_publish_policy_arn" {
  # Policy that allows Order Service to publish order events.
  description = "ARN of the Order Service SNS publish policy"
  value       = module.iam.order_sns_publish_policy_arn
}