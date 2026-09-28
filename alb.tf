# ============================================================
# APPLICATION LOAD BALANCER
# ============================================================
#
# Public traffic flow:
#
# Internet
#    ↓
# ALB :80
#    │
#    ├── /products/*  → Product Target Group → Product ECS
#    ├── /orders/*    → Order Target Group   → Order ECS
#    └── /inventory/* → Inventory Target Group → Inventory ECS
#
# ECS tasks remain inside private subnets.
# ============================================================


# ------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------
# The ALB is public and receives HTTP traffic from users.

resource "aws_lb" "main" {

  # ALB name.
  name = "${var.project_name}-${var.environment}-alb"

  # Make the ALB accessible from the internet.
  internal = false

  # Create an Application Load Balancer.
  load_balancer_type = "application"

  # ALB must exist in public subnets.
  # Two subnets provide Availability Zone redundancy.
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  # Security group controls incoming and outgoing ALB traffic.
  security_groups = [
    aws_security_group.alb.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Project     = var.project_name
    Environment = var.environment
    Service     = "alb"
  }
}


# ============================================================
# PRODUCT TARGET GROUP
# ============================================================
# ALB forwards /products/* requests to this target group.

resource "aws_lb_target_group" "product" {
  # Target group name.
  name = "${var.project_name}-${var.environment}-product"

  # Product application port.
  port = var.product_service_port

  # IMPORTANT:
  # IP targets are used because ECS Fargate with awsvpc networking
  # registers each task using its private IP address.
  target_type = "ip"

  # Target group belongs to our e-commerce VPC.
  vpc_id = aws_vpc.main.id

  # Application uses HTTP inside the VPC.
  protocol = "HTTP"

  health_check {
    # Product service readiness endpoint.
    path = "/ready"

    protocol = "HTTP"
    matcher  = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}


# ============================================================
# ORDER TARGET GROUP
# ============================================================
# ALB forwards /orders/* requests to this target group.

resource "aws_lb_target_group" "order" {
  # Target group name.
  name = "${var.project_name}-${var.environment}-order"

  # Order application port.
  port = var.order_service_port

  # Fargate tasks are registered using private IP addresses.
  target_type = "ip"

  # IMPORTANT:
  # Explicitly connect this target group to our VPC.
  vpc_id = aws_vpc.main.id

  protocol = "HTTP"

  health_check {
    # Order service health endpoint.
    path = "/health"

    protocol = "HTTP"
    matcher  = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}

# ============================================================
# INVENTORY TARGET GROUP
# ============================================================
# ALB forwards /inventory/* requests to Inventory Service.

resource "aws_lb_target_group" "inventory" {
  # Target group name.
  name = "${var.project_name}-${var.environment}-inventory"

  # Your Inventory Service currently runs on port 8002.
  port = var.inventory_service_port

  # Fargate tasks are registered using private IP addresses.
  target_type = "ip"

  # IMPORTANT:
  # Explicitly connect this target group to our VPC.
  vpc_id = aws_vpc.main.id

  protocol = "HTTP"

  health_check {
    # Your Inventory API already has GET /health.
    path = "/ready"

    protocol = "HTTP"
    matcher  = "200"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}


# ============================================================
# ALB HTTP LISTENER
# ============================================================
# The listener receives public HTTP traffic on port 80.

resource "aws_lb_listener" "http" {

  # Attach listener to our ALB.
  load_balancer_arn = aws_lb.main.arn

  # Public HTTP port.
  port = 80

  protocol = "HTTP"

  # If no routing rule matches, return 404.
  # This avoids sending unknown routes to an application.
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = "404"

      message_body = jsonencode({
        error = "Route not found"
      })
    }
  }
}


# ============================================================
# PRODUCT ROUTING RULE
# ============================================================
# /products/* → Product ECS Service

resource "aws_lb_listener_rule" "product" {

  # Use the ALB HTTP listener.
  listener_arn = aws_lb_listener.http.arn

  # Rule priority must be unique.
  priority = 10

  # Forward matching requests to Product target group.
  action {
    type = "forward"

    target_group_arn = aws_lb_target_group.product.arn
  }

  condition {
    path_pattern {
      values = [
        "/products",
        "/products/*"
      ]
    }
  }
}


# ============================================================
# ORDER ROUTING RULE
# ============================================================
# /orders/* → Order ECS Service

resource "aws_lb_listener_rule" "order" {

  # Use the ALB HTTP listener.
  listener_arn = aws_lb_listener.http.arn

  # Unique listener rule priority.
  priority = 20

  # Forward matching requests to Order target group.
  action {
    type = "forward"

    target_group_arn = aws_lb_target_group.order.arn
  }

  condition {
    path_pattern {
      values = [
        "/orders",
        "/orders/*"
      ]
    }
  }
}


# ============================================================
# INVENTORY ROUTING RULE
# ============================================================
# /inventory/* → Inventory ECS Service

resource "aws_lb_listener_rule" "inventory" {

  # Use the ALB HTTP listener.
  listener_arn = aws_lb_listener.http.arn

  # Unique listener rule priority.
  priority = 30

  # Forward matching requests to Inventory target group.
  action {
    type = "forward"

    target_group_arn = aws_lb_target_group.inventory.arn
  }

  condition {
    path_pattern {
      values = [
        "/inventory",
        "/inventory/*"
      ]
    }
  }
}
