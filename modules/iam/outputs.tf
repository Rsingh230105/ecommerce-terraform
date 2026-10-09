output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "product_task_role_arn" {
  description = "ARN of the Product application task role"
  value       = aws_iam_role.product_task.arn
}

output "order_task_role_arn" {
  description = "ARN of the Order application task role"
  value       = aws_iam_role.order_task.arn
}

output "inventory_task_role_arn" {
  description = "ARN of the Inventory application task role"
  value       = aws_iam_role.inventory_task.arn
}

output "order_sns_publish_policy_arn" {
  description = "ARN of the Order Service SNS publish policy"
  value       = aws_iam_policy.order_sns_publish.arn
}
