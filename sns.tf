# ------------------------------------------------------------
# SNS Topic - Order Events
# ------------------------------------------------------------

resource "aws_sns_topic" "order_events" {
  # Topic name is created dynamically from project and environment.
  # Example: ecommerce-dev-order-events
  name = "${var.project_name}-${var.environment}-order-events"

  # Tags help us identify and manage AWS resources.
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "messaging"
  }
}