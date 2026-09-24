# ------------------------------------------------------------
# SQS - Inventory Dead Letter Queue (DLQ)
# ------------------------------------------------------------

resource "aws_sqs_queue" "inventory_dlq" {
  # Failed Inventory messages will be moved to this queue.
  name = "${var.project_name}-${var.environment}-inventory-dlq"

  # Keep failed messages for up to 14 days.
  # This gives developers time to inspect and troubleshoot failures.
  message_retention_seconds = 1209600

  # Enable SQS-managed encryption at rest.
  # AWS manages the encryption key for us.
  sqs_managed_sse_enabled = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
    Purpose     = "dead-letter-queue"
  }
}


# ------------------------------------------------------------
# SQS - Main Inventory Queue
# ------------------------------------------------------------

resource "aws_sqs_queue" "inventory_queue" {
  # Main queue receives Order events for Inventory processing.
  name = "${var.project_name}-${var.environment}-inventory-queue"

  # A message stays hidden from other consumers for 30 seconds
  # while the current consumer processes it.
  visibility_timeout_seconds = 30

  # Keep messages for 4 days if they are not deleted.
  message_retention_seconds = 345600

  # Long polling reduces unnecessary empty receive requests.
  receive_wait_time_seconds = 10

  # Enable AWS-managed encryption for message data.
  sqs_managed_sse_enabled = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
    Purpose     = "main-queue"
  }
}