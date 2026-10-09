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

  lifecycle {
    precondition {
      condition = var.environment != "prod" || (
        var.product_desired_count >= 2 &&
        var.order_desired_count >= 2 &&
        var.inventory_desired_count >= 2 &&
        var.order_publisher_desired_count >= 1
      )
      error_message = "Production API services must each run at least two tasks; the Order outbox publisher must run at least one task."
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Project     = var.project_name
    Environment = var.environment
    Service     = "ecs"
  }
}