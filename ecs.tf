# ------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------
# The ECS cluster is the logical group where our Fargate
# services and tasks will run.

resource "aws_ecs_cluster" "main" {
  # Create a descriptive cluster name.
  name = "${var.project_name}-${var.environment}-cluster"

  # Enable CloudWatch Container Insights for monitoring.
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Project     = var.project_name
    Environment = var.environment
    Service     = "ecs"
  }
}