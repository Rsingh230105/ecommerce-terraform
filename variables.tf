variable "aws_region" {
  # AWS region used by the e-commerce infrastructure.
  description = "AWS region for the e-commerce infrastructure"

  # Default region: Mumbai.
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  # Common project name used for resource naming and tags.
  description = "Name of the e-commerce project"

  type    = string
  default = "ecommerce"
}

variable "environment" {
  # Environment name such as dev, staging, or prod.
  description = "Deployment environment"

  type    = string
  default = "dev"
}