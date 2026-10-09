resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = var.environment == "prod"
  subnets                    = var.public_subnet_ids
  security_groups            = [var.alb_security_group_id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Project     = var.project_name
    Environment = var.environment
    Service     = "alb"
  }
}

resource "aws_lb_target_group" "product" {
  name        = "${var.project_name}-${var.environment}-product"
  port        = var.product_service_port
  target_type = "ip"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"

  health_check {
    path                = "/ready"
    protocol            = "HTTP"
    matcher             = "200"
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

resource "aws_lb_target_group" "order" {
  name        = "${var.project_name}-${var.environment}-order"
  port        = var.order_service_port
  target_type = "ip"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
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

resource "aws_lb_target_group" "inventory" {
  name        = "${var.project_name}-${var.environment}-inventory"
  port        = var.inventory_service_port
  target_type = "ip"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"

  health_check {
    path                = "/ready"
    protocol            = "HTTP"
    matcher             = "200"
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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "fixed-response"

    dynamic "redirect" {
      for_each = var.enable_https ? [true] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "fixed_response" {
      for_each = var.enable_https ? [] : [true]

      content {
        content_type = "application/json"
        status_code  = "404"
        message_body = jsonencode({
          error = "Route not found"
        })
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

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

resource "aws_lb_listener_rule" "product" {
  listener_arn = var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product.arn
  }

  condition {
    path_pattern {
      values = ["/products", "/products/*"]
    }
  }
}

resource "aws_lb_listener_rule" "order" {
  listener_arn = var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order.arn
  }

  condition {
    path_pattern {
      values = ["/orders", "/orders/*"]
    }
  }
}

resource "aws_lb_listener_rule" "inventory" {
  listener_arn = var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inventory.arn
  }

  condition {
    path_pattern {
      values = ["/inventory", "/inventory/*"]
    }
  }
}
