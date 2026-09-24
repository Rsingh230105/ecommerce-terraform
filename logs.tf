# ------------------------------------------------------------
# CloudWatch Logs - Product Service
# ------------------------------------------------------------
# ECS containers will send application logs to CloudWatch.
# This helps us troubleshoot errors and monitor the service.

resource "aws_cloudwatch_log_group" "product_service" {
  # Log group name used by the Product ECS task.
  name = "/ecs/${var.project_name}-${var.environment}/product-service"

  # Keep development logs for 7 days.
  # Increase this value for production requirements.
  retention_in_days = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}


# ------------------------------------------------------------
# CloudWatch Logs - Order Service
# ------------------------------------------------------------

resource "aws_cloudwatch_log_group" "order_service" {
  # Log group name used by the Order ECS task.
  name = "/ecs/${var.project_name}-${var.environment}/order-service"

  # Keep development logs for 7 days.
  retention_in_days = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}


# ------------------------------------------------------------
# CloudWatch Logs - Inventory Service
# ------------------------------------------------------------

resource "aws_cloudwatch_log_group" "inventory_service" {
  # Log group name used by the Inventory ECS task.
  name = "/ecs/${var.project_name}-${var.environment}/inventory-service"

  # Keep development logs for 7 days.
  retention_in_days = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}