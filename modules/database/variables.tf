variable "project_name" {
  description = "Project name used in database resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used for database behavior and tags"
  type        = string
}

variable "instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID allowed to access PostgreSQL"
  type        = string
}
