variable "project_name" {
  description = "Project name used in ALB resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in ALB resource names and tags"
  type        = string
}

variable "enable_https" {
  description = "Whether to create an HTTPS listener and redirect HTTP traffic"
  type        = bool
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for the ALB target groups"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  type        = string
}

variable "product_service_port" {
  description = "Product Service target port"
  type        = number
}

variable "order_service_port" {
  description = "Order Service target port"
  type        = number
}

variable "inventory_service_port" {
  description = "Inventory Service target port"
  type        = number
}
