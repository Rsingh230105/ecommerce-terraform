# ------------------------------------------------------------
# Main SQS Queue -> DLQ Redrive Policy
# ------------------------------------------------------------

resource "aws_sqs_queue_redrive_policy" "inventory_queue" {
  # Attach the redrive policy to the main Inventory queue.
  queue_url = aws_sqs_queue.inventory_queue.id

  redrive_policy = jsonencode({
    # Failed messages are moved to the Inventory DLQ.
    deadLetterTargetArn = aws_sqs_queue.inventory_dlq.arn

    # After 3 failed receives, move the message to the DLQ.
    maxReceiveCount = 3
  })
}


# ------------------------------------------------------------
# DLQ Redrive Allow Policy
# ------------------------------------------------------------

resource "aws_sqs_queue_redrive_allow_policy" "inventory_dlq" {
  # Attach the allow policy to the Inventory DLQ.
  queue_url = aws_sqs_queue.inventory_dlq.id

  redrive_allow_policy = jsonencode({
    # Only the specified source queue can use this DLQ.
    redrivePermission = "byQueue"

    # Main Inventory queue is allowed to send failed messages here.
    sourceQueueArns = [
      aws_sqs_queue.inventory_queue.arn
    ]
  })
}