output "load_balancer_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.main.dns_name
}

output "http_listener_arn" {
  description = "ARN of the public HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener, when enabled"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

output "product_target_group_arn" {
  description = "ARN of the Product Service target group"
  value       = aws_lb_target_group.product.arn
}

output "order_target_group_arn" {
  description = "ARN of the Order Service target group"
  value       = aws_lb_target_group.order.arn
}

output "inventory_target_group_arn" {
  description = "ARN of the Inventory Service target group"
  value       = aws_lb_target_group.inventory.arn
}
