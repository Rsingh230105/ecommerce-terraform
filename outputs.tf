# ------------------------------------------------------------
# SNS Outputs
# ------------------------------------------------------------

output "order_events_topic_arn" {
  # ARN of the SNS topic used for Order events.
  description = "ARN of the Order Events SNS topic"
  value       = aws_sns_topic.order_events.arn
}


# ------------------------------------------------------------
# SQS Main Queue Outputs
# ------------------------------------------------------------

output "inventory_queue_url" {
  # URL used by the Inventory Service to receive messages.
  description = "URL of the Inventory SQS queue"
  value       = aws_sqs_queue.inventory_queue.url
}

output "inventory_queue_arn" {
  # ARN uniquely identifies the Inventory SQS queue.
  description = "ARN of the Inventory SQS queue"
  value       = aws_sqs_queue.inventory_queue.arn
}


# ------------------------------------------------------------
# SQS DLQ Outputs
# ------------------------------------------------------------

output "inventory_dlq_url" {
  # URL used to inspect failed Inventory messages.
  description = "URL of the Inventory Dead Letter Queue"
  value       = aws_sqs_queue.inventory_dlq.url
}

output "inventory_dlq_arn" {
  # ARN uniquely identifies the Inventory Dead Letter Queue.
  description = "ARN of the Inventory Dead Letter Queue"
  value       = aws_sqs_queue.inventory_dlq.arn
}


# ------------------------------------------------------------
# SNS -> SQS Subscription Output
# ------------------------------------------------------------

output "inventory_subscription_arn" {
  # ARN of the subscription connecting SNS to Inventory SQS.
  description = "ARN of the SNS to SQS subscription"
  value       = aws_sns_topic_subscription.inventory_queue.arn
}

# ------------------------------------------------------------
# S3 Output
# ------------------------------------------------------------

output "product_media_bucket_name" {
  # Bucket name used by the application to store product media.
  description = "Name of the Product Media S3 bucket"
  value       = aws_s3_bucket.product_media.id
}


output "product_media_bucket_arn" {
  # ARN uniquely identifies the Product Media S3 bucket.
  description = "ARN of the Product Media S3 bucket"
  value       = aws_s3_bucket.product_media.arn
}


# ------------------------------------------------------------
# ECR Outputs
# ------------------------------------------------------------

output "product_service_ecr_repository_url" {
  # Docker image repository URL for the Product Service.
  description = "ECR repository URL for Product Service"
  value       = aws_ecr_repository.product_service.repository_url
}


output "order_service_ecr_repository_url" {
  # Docker image repository URL for the Order Service.
  description = "ECR repository URL for the Order Service"
  value       = aws_ecr_repository.order_service.repository_url
}


output "inventory_service_ecr_repository_url" {
  # Docker image repository URL for the Inventory Service.
  description = "ECR repository URL for the Inventory Service"
  value       = aws_ecr_repository.inventory_service.repository_url
}

# ------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------

output "vpc_id" {
  # ID of the main e-commerce VPC.
  description = "ID of the e-commerce VPC"
  value       = aws_vpc.main.id
}


output "public_subnet_ids" {
  # IDs of the public subnets used by the ALB.
  description = "IDs of the public subnets"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}


output "private_subnet_ids" {
  # IDs of the private subnets used by ECS and RDS.
  description = "IDs of the private subnets"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}


output "nat_gateway_id" {
  # ID of the NAT Gateway used by private subnets.
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

# ------------------------------------------------------------
# Security Group Outputs
# ------------------------------------------------------------

output "alb_security_group_id" {
  # Security group ID used by the public Application Load Balancer.
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}


output "ecs_security_group_id" {
  # Security group ID used by ECS application tasks.
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}


output "rds_security_group_id" {
  # Security group ID used by the PostgreSQL RDS instance.
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}


# ------------------------------------------------------------
# RDS Outputs
# ------------------------------------------------------------

output "rds_endpoint" {
  # DNS hostname used by applications to connect to PostgreSQL.
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}


output "rds_port" {
  # PostgreSQL port exposed inside the VPC.
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}


output "rds_database_name" {
  # Application database name.
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}


output "rds_master_secret_arn" {
  # ARN of the Secrets Manager secret created and managed by RDS.
  #
  # We output the ARN, not the actual password.
  description = "ARN of the RDS-managed master password secret"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

# ------------------------------------------------------------
# ECS Outputs
# ------------------------------------------------------------

output "ecs_cluster_name" {
  # Name of the ECS cluster where our services will run.
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}


output "ecs_cluster_arn" {
  # ARN uniquely identifies the ECS cluster.
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}


# ------------------------------------------------------------
# CloudWatch Log Group Outputs
# ------------------------------------------------------------

output "product_log_group_name" {
  # CloudWatch log group used by the Product Service.
  description = "Product Service CloudWatch log group"
  value       = aws_cloudwatch_log_group.product_service.name
}


output "order_log_group_name" {
  # CloudWatch log group used by the Order Service.
  description = "Order Service CloudWatch log group"
  value       = aws_cloudwatch_log_group.order_service.name
}


output "inventory_log_group_name" {
  # CloudWatch log group used by the Inventory Service.
  description = "Inventory Service CloudWatch log group"
  value       = aws_cloudwatch_log_group.inventory_service.name
}

# ------------------------------------------------------------
# ECS Application Task Role Outputs
# ------------------------------------------------------------

output "product_task_role_arn" {
  # IAM role used by the Product Service container.
  description = "ARN of the Product Service ECS task role"
  value       = aws_iam_role.product_task.arn
}


output "order_task_role_arn" {
  # IAM role used by the Order Service container.
  description = "ARN of the Order Service ECS task role"
  value       = aws_iam_role.order_task.arn
}


output "inventory_task_role_arn" {
  # IAM role used by the Inventory Service container.
  description = "ARN of the Inventory Service ECS task role"
  value       = aws_iam_role.inventory_task.arn
}


output "order_sns_publish_policy_arn" {
  # Policy that allows Order Service to publish order events.
  description = "ARN of the Order Service SNS publish policy"
  value       = aws_iam_policy.order_sns_publish.arn
}