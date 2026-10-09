output "product_log_group_name" {
  description = "Product Service CloudWatch log group name"
  value       = aws_cloudwatch_log_group.product_service.name
}

output "order_log_group_name" {
  description = "Order Service CloudWatch log group name"
  value       = aws_cloudwatch_log_group.order_service.name
}

output "inventory_log_group_name" {
  description = "Inventory Service CloudWatch log group name"
  value       = aws_cloudwatch_log_group.inventory_service.name
}
