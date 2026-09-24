# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------
# This VPC is the main private network for the e-commerce system.
# ECS, RDS, and other internal resources will live inside this VPC.

resource "aws_vpc" "main" {
  # Private IPv4 address range for the complete VPC.
  cidr_block = "10.0.0.0/16"

  # Enable DNS support so AWS resources can resolve DNS names.
  enable_dns_support = true

  # Enable DNS hostnames inside the VPC.
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}


# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------
# Provides internet connectivity for resources in public subnets.

resource "aws_internet_gateway" "main" {
  # Attach the Internet Gateway to our VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}