resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for the public Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = "alb"
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS application tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = "ecs"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTP traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count             = var.environment == "prod" ? 1 : 0
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTPS traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "product_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.product_service_port
  to_port                      = var.product_service_port
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow Product Service traffic from ALB"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_service_connect_product" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.product_service_port
  to_port                      = var.product_service_port
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow ECS tasks to reach Product Service through Service Connect"
}

resource "aws_vpc_security_group_ingress_rule" "order_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.order_service_port
  to_port                      = var.order_service_port
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow Order Service traffic from ALB"
}

resource "aws_vpc_security_group_ingress_rule" "inventory_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.inventory_service_port
  to_port                      = var.inventory_service_port
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow Inventory Service traffic from ALB"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow PostgreSQL traffic from ECS tasks"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_product" {
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.product_service_port
  to_port                      = var.product_service_port
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow ALB to reach Product Service"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_order" {
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.order_service_port
  to_port                      = var.order_service_port
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow ALB to reach Order Service"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_inventory" {
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.inventory_service_port
  to_port                      = var.inventory_service_port
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow ALB to reach Inventory Service"
}

resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow ECS tasks to access HTTPS services"
}

resource "aws_vpc_security_group_egress_rule" "ecs_dns_udp" {
  security_group_id = aws_security_group.ecs.id
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = var.vpc_cidr
  description       = "Allow ECS DNS queries over UDP"
}

resource "aws_vpc_security_group_egress_rule" "ecs_dns_tcp" {
  security_group_id = aws_security_group.ecs.id
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = var.vpc_cidr
  description       = "Allow ECS DNS queries over TCP"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.rds.id
  description                  = "Allow ECS tasks to connect to RDS PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "ecs_service_connect_product" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.product_service_port
  to_port                      = var.product_service_port
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow ECS Service Connect traffic to Product Service"
}
