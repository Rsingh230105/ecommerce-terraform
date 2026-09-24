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

  # Keep one Product task running in development.
  desired_count = var.product_desired_count

  # Use AWS Fargate instead of managing EC2 servers.
  launch_type = "FARGATE"

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
    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    # Attach the ECS security group.
    security_groups = [
      aws_security_group.ecs.id
    ]

    # Do NOT assign public IP addresses.
    assign_public_ip = false
  }

  # ----------------------------------------------------------
  # ALB Connection
  # ----------------------------------------------------------

  load_balancer {

    # Send ALB traffic to the Product target group.
    target_group_arn = aws_lb_target_group.product.arn

    # Must match the task-definition container name.
    container_name = "product-service"

    # Product container port.
    container_port = var.product_service_port
  }

  # Make sure the ALB listener exists before the ECS service.
  depends_on = [
    aws_lb_listener.http
  ]

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

  # Keep one Order task running in development.
  desired_count = var.order_desired_count

  # Use AWS Fargate.
  launch_type = "FARGATE"

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
    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    # Attach the ECS security group.
    security_groups = [
      aws_security_group.ecs.id
    ]

    # Keep the Order service private.
    assign_public_ip = false
  }

  # ----------------------------------------------------------
  # ALB Connection
  # ----------------------------------------------------------

  load_balancer {

    # Send ALB traffic to Order target group.
    target_group_arn = aws_lb_target_group.order.arn

    # Must match the task-definition container name.
    container_name = "order-service"

    # Order container port.
    container_port = var.order_service_port
  }

  # ALB listener must exist first.
  depends_on = [
    aws_lb_listener.http
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

  # Keep one Inventory API task running in development.
  desired_count = var.inventory_desired_count

  # Use AWS Fargate.
  launch_type = "FARGATE"

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
    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    # Attach ECS security group.
    security_groups = [
      aws_security_group.ecs.id
    ]

    # No public IP.
    assign_public_ip = false
  }

  # ----------------------------------------------------------
  # ALB Connection
  # ----------------------------------------------------------

  load_balancer {

    # Send ALB requests to Inventory target group.
    target_group_arn = aws_lb_target_group.inventory.arn

    # Must match the task-definition container name.
    container_name = "inventory-service"

    # Your current Inventory Service runs on port 8002.
    container_port = var.inventory_service_port
  }

  # Ensure ALB listener exists first.
  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}