# ============================================================
# ECS FARGATE SERVICES
# ============================================================
#
# A task definition describes the container.
# An ECS service keeps the required number of tasks running.
#
# Architecture:
#
# ALB
#  |
#  +--> Product ECS Service
#  |
#  +--> Order ECS Service
#  |
#  +--> Inventory ECS Service
#
# All ECS tasks run in PRIVATE subnets.
# ============================================================


# ------------------------------------------------------------
# Product ECS Service
# ------------------------------------------------------------

resource "aws_ecs_service" "product" {

  # ECS service name.
  name = "${var.project_name}-${var.environment}-product"

  # ECS cluster where this service will run.
  cluster = aws_ecs_cluster.main.id

  # Use the Product task-definition blueprint.
  task_definition = aws_ecs_task_definition.product.arn

  lifecycle {
    # CI deploys newer revisions; Terraform keeps managing the other service settings.
    ignore_changes = [task_definition]
  }

  # Keep one Product task running in development.
  desired_count = var.product_desired_count

  # Use AWS Fargate instead of managing EC2 servers.
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  # Give the Product container time to become healthy
  # before ECS starts treating health-check failures seriously.
  health_check_grace_period_seconds = 60

  # Automatically roll back when a deployment cannot become healthy.
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # ----------------------------------------------------------
  # Fargate Networking
  # ----------------------------------------------------------

  network_configuration {

    # Run Product tasks in private subnets.
    subnets = var.private_subnet_ids

    # Attach the ECS security group.
    security_groups = [
      var.ecs_security_group_id
    ]

    # Do NOT assign public IP addresses.
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_connect.arn

    service {
      port_name      = "http"
      discovery_name = "product-service"

      client_alias {
        dns_name = "product-service"
        port     = var.product_service_port
      }
    }
  }

  # ----------------------------------------------------------
  # ALB Connection
  # ----------------------------------------------------------

  load_balancer {

    # Send ALB traffic to the Product target group.
    target_group_arn = var.product_target_group_arn

    # Must match the task-definition container name.
    container_name = "product-service"

    # Product container port.
    container_port = var.product_service_port
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}


# ------------------------------------------------------------
# Order ECS Service
# ------------------------------------------------------------

resource "aws_ecs_service" "order" {

  # ECS service name.
  name = "${var.project_name}-${var.environment}-order"

  # Run inside the main ECS cluster.
  cluster = aws_ecs_cluster.main.id

  # Use the Order task-definition blueprint.
  task_definition = aws_ecs_task_definition.order.arn

  lifecycle {
    # CI deploys newer revisions; Terraform keeps managing the other service settings.
    ignore_changes = [task_definition]
  }

  # Keep one Order task running in development.
  desired_count = var.order_desired_count

  # Use AWS Fargate.
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  # Give the application time to start.
  health_check_grace_period_seconds = 60

  # Roll back an unhealthy deployment automatically.
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # ----------------------------------------------------------
  # Fargate Networking
  # ----------------------------------------------------------

  network_configuration {

    # Run Order tasks in private subnets.
    subnets = var.private_subnet_ids

    # Attach the ECS security group.
    security_groups = [
      var.ecs_security_group_id
    ]

    # Keep the Order service private.
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_connect.arn
  }

  # ----------------------------------------------------------
  # ALB Connection
  # ----------------------------------------------------------

  load_balancer {

    # Send ALB traffic to Order target group.
    target_group_arn = var.order_target_group_arn

    # Must match the task-definition container name.
    container_name = "order-service"

    # Order container port.
    container_port = var.order_service_port
  }

  depends_on = [
    aws_ecs_service.product
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}


# ------------------------------------------------------------
# Inventory ECS Service
# ------------------------------------------------------------

resource "aws_ecs_service" "inventory" {

  # ECS service name.
  name = "${var.project_name}-${var.environment}-inventory"

  # Run inside the main ECS cluster.
  cluster = aws_ecs_cluster.main.id

  # Use the Inventory task-definition blueprint.
  task_definition = aws_ecs_task_definition.inventory.arn

  lifecycle {
    # CI deploys newer revisions; Terraform keeps managing the other service settings.
    ignore_changes = [task_definition]
  }

  # Keep one Inventory API task running in development.
  desired_count = var.inventory_desired_count

  # Use AWS Fargate.
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  # Allow Inventory API time to pass health checks.
  health_check_grace_period_seconds = 60

  # Automatically roll back bad deployments.
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # ----------------------------------------------------------
  # Fargate Networking
  # ----------------------------------------------------------

  network_configuration {

    # Inventory tasks run in private subnets.
    subnets = var.private_subnet_ids

    # Attach ECS security group.
    security_groups = [
      var.ecs_security_group_id
    ]

    # No public IP.
    assign_public_ip = false
  }

  # ----------------------------------------------------------
  # ALB Connection
  # ----------------------------------------------------------

  load_balancer {

    # Send ALB requests to Inventory target group.
    target_group_arn = var.inventory_target_group_arn

    # Must match the task-definition container name.
    container_name = "inventory-service"

    # Your current Inventory Service runs on port 8002.
    container_port = var.inventory_service_port
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}
# ------------------------------------------------------------
# Order Outbox Publisher ECS Service
# ------------------------------------------------------------

resource "aws_ecs_service" "order_publisher" {
  name            = "${var.project_name}-${var.environment}-order-publisher"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order_publisher.arn

  lifecycle {
    # CI deploys newer revisions; Terraform keeps managing the other service settings.
    ignore_changes = [task_definition]
  }

  desired_count = var.order_publisher_desired_count

  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  network_configuration {
    subnets = var.private_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    assign_public_ip = false
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order-publisher"
  }
}
