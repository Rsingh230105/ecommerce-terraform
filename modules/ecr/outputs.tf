output "product_service_repository_url" {
  description = "ECR repository URL for Product Service"
  value       = aws_ecr_repository.product_service.repository_url
}

output "order_service_repository_url" {
  description = "ECR repository URL for Order Service"
  value       = aws_ecr_repository.order_service.repository_url
}

output "inventory_service_repository_url" {
  description = "ECR repository URL for Inventory Service"
  value       = aws_ecr_repository.inventory_service.repository_url
}
