variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names and tags"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that contains the security groups"
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range of the VPC, used for ECS DNS egress rules"
  type        = string
}

variable "product_service_port" {
  description = "Container port used by Product Service"
  type        = number
}

variable "order_service_port" {
  description = "Container port used by Order Service"
  type        = number
}

variable "inventory_service_port" {
  description = "Container port used by Inventory Service"
  type        = number
}
