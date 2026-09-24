# ------------------------------------------------------------
# SNS Outputs
# ------------------------------------------------------------

output "order_events_topic_arn" {
  # ARN of the SNS topic used for Order events.
  description = "ARN of the Order Events SNS topic"
  value       = aws_sns_topic.order_events.arn
}


# ------------------------------------------------------------
# SQS Main Queue Outputs
# ------------------------------------------------------------

output "inventory_queue_url" {
  # URL used by the Inventory Service to receive messages.
  description = "URL of the Inventory SQS queue"
  value       = aws_sqs_queue.inventory_queue.url
}

output "inventory_queue_arn" {
  # ARN uniquely identifies the Inventory SQS queue.
  description = "ARN of the Inventory SQS queue"
  value       = aws_sqs_queue.inventory_queue.arn
}


# ------------------------------------------------------------
# SQS DLQ Outputs
# ------------------------------------------------------------

output "inventory_dlq_url" {
  # URL used to inspect failed Inventory messages.
  description = "URL of the Inventory Dead Letter Queue"
  value       = aws_sqs_queue.inventory_dlq.url
}

output "inventory_dlq_arn" {
  # ARN uniquely identifies the Inventory Dead Letter Queue.
  description = "ARN of the Inventory Dead Letter Queue"
  value       = aws_sqs_queue.inventory_dlq.arn
}


# ------------------------------------------------------------
# SNS -> SQS Subscription Output
# ------------------------------------------------------------

output "inventory_subscription_arn" {
  # ARN of the subscription connecting SNS to Inventory SQS.
  description = "ARN of the SNS to SQS subscription"
  value       = aws_sns_topic_subscription.inventory_queue.arn
}