variable "project_name" {
  description = "Project name used in IAM resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in IAM resource names and tags"
  type        = string
}

variable "inventory_queue_arn" {
  description = "ARN of the Inventory SQS queue"
  type        = string
}

variable "order_events_topic_arn" {
  description = "ARN of the Order Events SNS topic"
  type        = string
}

variable "database_master_secret_arn" {
  description = "ARN of the RDS-managed database credentials secret"
  type        = string
}
