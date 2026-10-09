variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names and tags"
  type        = string
}

variable "vpc_cidr_block" {
  description = "IPv4 CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr_block" {
  description = "IPv4 CIDR range for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr_block" {
  description = "IPv4 CIDR range for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr_block" {
  description = "IPv4 CIDR range for the first private subnet"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_2_cidr_block" {
  description = "IPv4 CIDR range for the second private subnet"
  type        = string
  default     = "10.0.12.0/24"
}
