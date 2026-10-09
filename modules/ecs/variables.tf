variable "project_name" {
  description = "Project name used in ECS resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in ECS resource names and tags"
  type        = string
}

variable "aws_region" {
  description = "AWS region used by containers and CloudWatch logging"
  type        = string
}

variable "product_service_port" {
  description = "Product Service container port"
  type        = number
}

variable "order_service_port" {
  description = "Order Service container port"
  type        = number
}

variable "inventory_service_port" {
  description = "Inventory Service container port"
  type        = number
}

variable "product_image_tag" {
  description = "Product Service image tag"
  type        = string
}

variable "order_image_tag" {
  description = "Order Service and publisher image tag"
  type        = string
}

variable "inventory_image_tag" {
  description = "Inventory Service image tag"
  type        = string
}

variable "product_ecs_task_cpu" {
  description = "CPU units for Product ECS task"
  type        = number
}

variable "product_ecs_task_memory" {
  description = "Memory in MiB for Product ECS task"
  type        = number
}

variable "order_ecs_task_cpu" {
  description = "CPU units for Order ECS task"
  type        = number
}

variable "order_ecs_task_memory" {
  description = "Memory in MiB for Order ECS task"
  type        = number
}

variable "inventory_ecs_task_cpu" {
  description = "CPU units for Inventory ECS task"
  type        = number
}

variable "inventory_ecs_task_memory" {
  description = "Memory in MiB for Inventory ECS task"
  type        = number
}

variable "order_publisher_ecs_task_cpu" {
  description = "CPU units for Order Outbox Publisher ECS task"
  type        = number
}

variable "order_publisher_ecs_task_memory" {
  description = "Memory in MiB for Order Outbox Publisher ECS task"
  type        = number
}

variable "fargate_platform_version" {
  description = "AWS Fargate Linux platform version"
  type        = string
}

variable "product_desired_count" {
  description = "Desired number of Product Service tasks"
  type        = number
}

variable "order_desired_count" {
  description = "Desired number of Order Service tasks"
  type        = number
}

variable "inventory_desired_count" {
  description = "Desired number of Inventory Service tasks"
  type        = number
}

variable "order_publisher_desired_count" {
  description = "Desired number of Order Outbox Publisher tasks"
  type        = number
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID attached to ECS tasks"
  type        = string
}

variable "product_target_group_arn" {
  description = "ALB target group ARN for Product Service"
  type        = string
}

variable "order_target_group_arn" {
  description = "ALB target group ARN for Order Service"
  type        = string
}

variable "inventory_target_group_arn" {
  description = "ALB target group ARN for Inventory Service"
  type        = string
}

variable "product_ecr_repository_url" {
  description = "ECR repository URL for Product Service"
  type        = string
}

variable "order_ecr_repository_url" {
  description = "ECR repository URL for Order Service"
  type        = string
}

variable "inventory_ecr_repository_url" {
  description = "ECR repository URL for Inventory Service"
  type        = string
}

variable "database_endpoint" {
  description = "PostgreSQL endpoint hostname"
  type        = string
}

variable "database_port" {
  description = "PostgreSQL connection port"
  type        = number
}

variable "database_name" {
  description = "Application database name"
  type        = string
}

variable "database_master_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret"
  type        = string
}

variable "order_events_topic_arn" {
  description = "SNS topic ARN for Order events"
  type        = string
}

variable "inventory_queue_url" {
  description = "Inventory SQS queue URL"
  type        = string
}

variable "product_log_group_name" {
  description = "Product Service CloudWatch log group name"
  type        = string
}

variable "order_log_group_name" {
  description = "Order Service CloudWatch log group name"
  type        = string
}

variable "inventory_log_group_name" {
  description = "Inventory Service CloudWatch log group name"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "product_task_role_arn" {
  description = "Product application task role ARN"
  type        = string
}

variable "order_task_role_arn" {
  description = "Order application task role ARN"
  type        = string
}

variable "inventory_task_role_arn" {
  description = "Inventory application task role ARN"
  type        = string
}
