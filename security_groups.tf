# ============================================================
# SECURITY GROUPS
# ============================================================
# We use three security groups:
#
# 1. ALB Security Group
#    → Public entry point for HTTP traffic.
#
# 2. ECS Security Group
#    → Controls traffic to our application containers.
#
# 3. RDS Security Group
#    → Controls PostgreSQL database access.
#
# Traffic flow:
#
# Internet
#    ↓
# ALB :80
#    ↓
# ECS :8000 / :8001 / :8002
#    ↓
# RDS :5432
# ============================================================


# ------------------------------------------------------------
# ALB Security Group
# ------------------------------------------------------------
# This security group controls the public Application Load
# Balancer.

resource "aws_security_group" "alb" {
  # Name of the ALB security group.
  name = "${var.project_name}-${var.environment}-alb-sg"

  # Human-readable description.
  description = "Security group for the public Application Load Balancer"

  # Create the security group inside our e-commerce VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = "alb"
  }
}


# ------------------------------------------------------------
# ECS Security Group
# ------------------------------------------------------------
# This security group controls traffic reaching our ECS
# application containers.

resource "aws_security_group" "ecs" {
  # Name of the ECS security group.
  name = "${var.project_name}-${var.environment}-ecs-sg"

  description = "Security group for ECS application tasks"

  # ECS tasks will run inside our e-commerce VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = "ecs"
  }
}


# ------------------------------------------------------------
# RDS Security Group
# ------------------------------------------------------------
# This security group controls PostgreSQL database access.

resource "aws_security_group" "rds" {
  # Name of the RDS security group.
  name = "${var.project_name}-${var.environment}-rds-sg"

  description = "Security group for RDS PostgreSQL"

  # RDS will run inside our e-commerce VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}


# ============================================================
# ALB INBOUND RULES
# ============================================================


# ------------------------------------------------------------
# Internet -> ALB :80
# ------------------------------------------------------------
# Allow public HTTP traffic to reach the ALB.

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  # Apply the rule to the ALB security group.
  security_group_id = aws_security_group.alb.id

  # HTTP uses TCP.
  ip_protocol = "tcp"

  # Public HTTP port.
  from_port = 80
  to_port   = 80

  # Allow HTTP traffic from anywhere on the internet.
  # HTTPS/TLS can be added later with ACM.
  cidr_ipv4 = "0.0.0.0/0"

  description = "Allow HTTP traffic from the internet"
}


# ============================================================
# ALB -> ECS INBOUND RULES
# ============================================================
# Only the ALB security group is allowed to reach ECS.
#
# Direct internet traffic to ECS is NOT allowed.


# ------------------------------------------------------------
# ALB -> Product ECS :8000
# ------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "product_from_alb" {
  # Apply the rule to the ECS security group.
  security_group_id = aws_security_group.ecs.id

  # Product Service uses TCP.
  ip_protocol = "tcp"

  # Product Service container port.
  from_port = var.product_service_port
  to_port   = var.product_service_port

  # Only the ALB security group can access this port.
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow Product Service traffic from ALB"
}


# ------------------------------------------------------------
# ALB -> Order ECS :8001
# ------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "order_from_alb" {
  # Apply the rule to the ECS security group.
  security_group_id = aws_security_group.ecs.id

  # Order Service uses TCP.
  ip_protocol = "tcp"

  # Order Service container port.
  from_port = var.order_service_port
  to_port   = var.order_service_port

  # Only the ALB security group can access this port.
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow Order Service traffic from ALB"
}


# ------------------------------------------------------------
# ALB -> Inventory ECS :8002
# ------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "inventory_from_alb" {
  # Apply the rule to the ECS security group.
  security_group_id = aws_security_group.ecs.id

  # Inventory Service uses TCP.
  ip_protocol = "tcp"

  # Inventory Service currently runs on port 8002.
  from_port = var.inventory_service_port
  to_port   = var.inventory_service_port

  # Only the ALB security group can access this port.
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow Inventory Service traffic from ALB"
}


# ============================================================
# RDS INBOUND RULE
# ============================================================


# ------------------------------------------------------------
# ECS -> RDS PostgreSQL :5432
# ------------------------------------------------------------
# Only ECS application tasks can connect to PostgreSQL.

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  # Apply the rule to the RDS security group.
  security_group_id = aws_security_group.rds.id

  # PostgreSQL uses TCP.
  ip_protocol = "tcp"

  # PostgreSQL default port.
  from_port = 5432
  to_port   = 5432

  # Only resources using the ECS security group can connect.
  referenced_security_group_id = aws_security_group.ecs.id

  description = "Allow PostgreSQL traffic from ECS tasks"
}


# ============================================================
# ALB OUTBOUND RULES
# ============================================================
# ALB only needs to send application traffic to ECS.
#
# We reference the ECS security group instead of allowing
# traffic to the complete VPC CIDR.


# ------------------------------------------------------------
# ALB -> Product ECS :8000
# ------------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "alb_to_product" {
  # Apply the rule to the ALB security group.
  security_group_id = aws_security_group.alb.id

  # Product traffic uses TCP.
  ip_protocol = "tcp"

  # Product Service port.
  from_port = var.product_service_port
  to_port   = var.product_service_port

  # Only ECS resources using the ECS security group are allowed.
  referenced_security_group_id = aws_security_group.ecs.id

  description = "Allow ALB to reach Product Service"
}


# ------------------------------------------------------------
# ALB -> Order ECS :8001
# ------------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "alb_to_order" {
  # Apply the rule to the ALB security group.
  security_group_id = aws_security_group.alb.id

  # Order traffic uses TCP.
  ip_protocol = "tcp"

  # Order Service port.
  from_port = var.order_service_port
  to_port   = var.order_service_port

  # Only ECS resources using the ECS security group are allowed.
  referenced_security_group_id = aws_security_group.ecs.id

  description = "Allow ALB to reach Order Service"
}


# ------------------------------------------------------------
# ALB -> Inventory ECS :8002
# ------------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "alb_to_inventory" {
  # Apply the rule to the ALB security group.
  security_group_id = aws_security_group.alb.id

  # Inventory traffic uses TCP.
  ip_protocol = "tcp"

  # Inventory Service port.
  from_port = var.inventory_service_port
  to_port   = var.inventory_service_port

  # Only ECS resources using the ECS security group are allowed.
  referenced_security_group_id = aws_security_group.ecs.id

  description = "Allow ALB to reach Inventory Service"
}


# ============================================================
# ECS OUTBOUND RULES
# ============================================================
# ECS tasks run in private subnets.
#
# They need:
# - HTTPS for AWS/external services.
# - DNS to resolve service names.
# - PostgreSQL access to RDS.


# ------------------------------------------------------------
# ECS -> Internet :443
# ------------------------------------------------------------
# Private ECS tasks use the NAT Gateway for outbound internet
# access. This can be used for AWS APIs and external HTTPS APIs.

resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  # Apply the rule to ECS tasks.
  security_group_id = aws_security_group.ecs.id

  # HTTPS uses TCP.
  ip_protocol = "tcp"

  from_port = 443
  to_port   = 443

  # Allow outbound HTTPS traffic.
  cidr_ipv4 = "0.0.0.0/0"

  description = "Allow ECS tasks to access HTTPS services"
}


# ------------------------------------------------------------
# ECS -> VPC DNS :53 UDP
# ------------------------------------------------------------
# ECS tasks need DNS resolution to reach AWS services and
# other domain-based endpoints.

resource "aws_vpc_security_group_egress_rule" "ecs_dns_udp" {
  # Apply the rule to ECS tasks.
  security_group_id = aws_security_group.ecs.id

  # DNS uses UDP port 53 for normal queries.
  ip_protocol = "udp"

  from_port = 53
  to_port   = 53

  # Allow DNS resolution within our VPC.
  cidr_ipv4 = aws_vpc.main.cidr_block

  description = "Allow ECS DNS queries over UDP"
}


# ------------------------------------------------------------
# ECS -> VPC DNS :53 TCP
# ------------------------------------------------------------
# TCP DNS is needed for some DNS responses and fallback cases.

resource "aws_vpc_security_group_egress_rule" "ecs_dns_tcp" {
  # Apply the rule to ECS tasks.
  security_group_id = aws_security_group.ecs.id

  # DNS can also use TCP port 53.
  ip_protocol = "tcp"

  from_port = 53
  to_port   = 53

  # Allow DNS resolution within our VPC.
  cidr_ipv4 = aws_vpc.main.cidr_block

  description = "Allow ECS DNS queries over TCP"
}


# ------------------------------------------------------------
# ECS -> RDS PostgreSQL :5432
# ------------------------------------------------------------
# Application containers need database connectivity.

resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
  # Apply the rule to ECS tasks.
  security_group_id = aws_security_group.ecs.id

  # PostgreSQL uses TCP.
  ip_protocol = "tcp"

  from_port = 5432
  to_port   = 5432

  # Only RDS resources using the RDS security group are allowed.
  referenced_security_group_id = aws_security_group.rds.id

  description = "Allow ECS tasks to connect to RDS PostgreSQL"
}