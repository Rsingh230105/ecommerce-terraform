resource "aws_cloudwatch_log_group" "product_service" {
  name              = "/ecs/${var.project_name}-${var.environment}/product-service"
  retention_in_days = var.retention_in_days

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}

resource "aws_cloudwatch_log_group" "order_service" {
  name              = "/ecs/${var.project_name}-${var.environment}/order-service"
  retention_in_days = var.retention_in_days

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}

resource "aws_cloudwatch_log_group" "inventory_service" {
  name              = "/ecs/${var.project_name}-${var.environment}/inventory-service"
  retention_in_days = var.retention_in_days

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}
