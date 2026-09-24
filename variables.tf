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


# ------------------------------------------------------------
# Microservice Container Ports
# ------------------------------------------------------------
# These ports are used by the applications inside ECS containers.
# Inventory is already running on port 8002.
# Product and Order can be changed here if their applications
# use different ports.

variable "product_service_port" {
  # Port exposed by the Product Service container.
  description = "Product Service container port"
  type        = number
  default     = 8000
}


variable "order_service_port" {
  # Port exposed by the Order Service container.
  description = "Order Service container port"
  type        = number
  default     = 8001
}


variable "inventory_service_port" {
  # Port exposed by the Inventory Service container.
  description = "Inventory Service container port"
  type        = number
  default     = 8002
}

# ------------------------------------------------------------
# Docker Image Tags
# ------------------------------------------------------------
# Terraform creates the ECR repositories, while CI/CD or Docker
# pushes the actual images into those repositories.
#
# We keep the image tag configurable so we can deploy:
# v1, v2, commit SHA, release-001, etc.

variable "product_image_tag" {
  # Docker tag used by the Product Service image.
  description = "Docker image tag for Product Service"
  type        = string
  default     = "latest"
}


variable "order_image_tag" {
  # Docker tag used by the Order Service image.
  description = "Docker image tag for Order Service"
  type        = string
  default     = "latest"
}


variable "inventory_image_tag" {
  # Docker tag used by the Inventory Service image.
  description = "Docker tag used by Inventory Service"
  type        = string
  default     = "latest"
}


# ------------------------------------------------------------
# ECS Task CPU and Memory
# ------------------------------------------------------------
# Fargate task CPU and memory can be changed without changing
# the task-definition code.

variable "ecs_task_cpu" {
  # 256 CPU units = 0.25 vCPU.
  description = "CPU units for ECS Fargate tasks"
  type        = number
  default     = 256
}


variable "ecs_task_memory" {
  # 512 MB memory.
  description = "Memory in MB for ECS Fargate tasks"
  type        = number
  default     = 512
}


# ------------------------------------------------------------
# ECS Desired Counts
# ------------------------------------------------------------
# Number of running tasks for each service.

variable "product_desired_count" {
  # Number of Product Service tasks.
  description = "Desired number of Product Service ECS tasks"
  type        = number
  default     = 1
}


variable "order_desired_count" {
  # Number of Order Service tasks.
  description = "Desired number of Order Service ECS tasks"
  type        = number
  default     = 1
}


variable "inventory_desired_count" {
  # Number of Inventory Service tasks.
  description = "Desired number of Inventory Service ECS tasks"
  type        = number
  default     = 1
}