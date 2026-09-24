# ============================================================
# IAM ROLES FOR E-COMMERCE ECS
# ============================================================
#
# We use two IAM role concepts:
#
# 1. ECS Task Execution Role
#    → Used by ECS/Fargate infrastructure.
#    → Pulls Docker images from ECR.
#    → Sends container logs to CloudWatch.
#    → Reads Secrets Manager values when ECS injects secrets.
#
# 2. ECS Application Task Roles
#    → Used by application code inside containers.
#    → Product    → S3 access
#    → Order      → SNS publish access
#    → Inventory  → SQS consume access
#
# Keeping these roles separate follows the least-privilege model.
# ============================================================


# ------------------------------------------------------------
# ECS TASK EXECUTION ROLE
# ------------------------------------------------------------
# This role is used by ECS/Fargate itself, not by our application
# business logic.

resource "aws_iam_role" "ecs_task_execution" {
  # Unique name for the ECS execution role.
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  # Trust policy:
  # Allows the ECS tasks service to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "ecs"
    Purpose     = "task-execution"
  }
}


# ------------------------------------------------------------
# STANDARD ECS EXECUTION POLICY
# ------------------------------------------------------------
# AWS provides a managed policy containing the standard
# permissions needed by ECS/Fargate for task execution.
#
# This commonly includes permissions needed to:
# - Pull images from ECR
# - Write logs to CloudWatch
#
# Additional permission for Secrets Manager is added separately
# below with a least-privilege custom policy.

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  # Attach the AWS-managed execution policy to our role.
  role = aws_iam_role.ecs_task_execution.name

  # AWS managed policy for ECS task execution.
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ------------------------------------------------------------
# PRODUCT SERVICE TASK ROLE
# ------------------------------------------------------------
# This role is available only to the Product Service container.
#
# S3 permissions will be attached in iam_policies.tf.

resource "aws_iam_role" "product_task" {
  # Unique Product Service task role.
  name = "${var.project_name}-${var.environment}-product-task-role"

  # Allow ECS tasks to assume this application role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
    Purpose     = "application-task"
  }
}


# ------------------------------------------------------------
# ORDER SERVICE TASK ROLE
# ------------------------------------------------------------
# This role is available only to the Order Service container.
#
# SNS publish permissions will be attached in iam_policies.tf.

resource "aws_iam_role" "order_task" {
  # Unique Order Service task role.
  name = "${var.project_name}-${var.environment}-order-task-role"

  # Allow ECS tasks to assume this application role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
    Purpose     = "application-task"
  }
}


# ------------------------------------------------------------
# INVENTORY SERVICE TASK ROLE
# ------------------------------------------------------------
# This role is available only to the Inventory Service container.
#
# SQS consumer permissions will be attached in iam_policies.tf.

resource "aws_iam_role" "inventory_task" {
  # Unique Inventory Service task role.
  name = "${var.project_name}-${var.environment}-inventory-task-role"

  # Allow ECS tasks to assume this application role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
    Purpose     = "application-task"
  }
}