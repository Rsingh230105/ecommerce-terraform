resource "aws_service_discovery_http_namespace" "service_connect" {
  name        = "${var.project_name}-${var.environment}-service-connect"
  description = "ECS Service Connect namespace for ${var.project_name}-${var.environment}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "service-connect"
  }
}
