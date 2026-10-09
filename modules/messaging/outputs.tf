output "order_events_topic_arn" {
  description = "ARN of the Order Events SNS topic"
  value       = aws_sns_topic.order_events.arn
}

output "inventory_queue_url" {
  description = "URL of the Inventory SQS queue"
  value       = aws_sqs_queue.inventory_queue.url
}

output "inventory_queue_arn" {
  description = "ARN of the Inventory SQS queue"
  value       = aws_sqs_queue.inventory_queue.arn
}

output "inventory_dlq_url" {
  description = "URL of the Inventory dead-letter queue"
  value       = aws_sqs_queue.inventory_dlq.url
}

output "inventory_dlq_arn" {
  description = "ARN of the Inventory dead-letter queue"
  value       = aws_sqs_queue.inventory_dlq.arn
}

output "inventory_subscription_arn" {
  description = "ARN of the SNS-to-SQS subscription"
  value       = aws_sns_topic_subscription.inventory_queue.arn
}
