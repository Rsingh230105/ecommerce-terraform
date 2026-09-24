# ------------------------------------------------------------
# Availability Zones
# ------------------------------------------------------------
# We use two Availability Zones for better availability.
# AWS provides separate physical locations within the region.

data "aws_availability_zones" "available" {
  # Only return AZs that are currently available for use.
  state = "available"
}


# ------------------------------------------------------------
# Public Subnet - AZ 1
# ------------------------------------------------------------
# The Application Load Balancer will use public subnets.

resource "aws_subnet" "public_1" {
  # Create this subnet inside our main VPC.
  vpc_id = aws_vpc.main.id

  # First public subnet CIDR range.
  cidr_block = "10.0.1.0/24"

  # Use the first available Availability Zone.
  availability_zone = data.aws_availability_zones.available.names[0]

  # Automatically assign a public IPv4 address to instances
  # launched directly in this subnet.
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-1"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}


# ------------------------------------------------------------
# Public Subnet - AZ 2
# ------------------------------------------------------------

resource "aws_subnet" "public_2" {
  # Create the second public subnet in the same VPC.
  vpc_id = aws_vpc.main.id

  # Second public subnet CIDR range.
  cidr_block = "10.0.2.0/24"

  # Use the second Availability Zone.
  availability_zone = data.aws_availability_zones.available.names[1]

  # Public IP assignment for resources launched here.
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-2"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}


# ------------------------------------------------------------
# Private Subnet - AZ 1
# ------------------------------------------------------------
# ECS application tasks and RDS will use private subnets.

resource "aws_subnet" "private_1" {
  # Create this subnet inside our main VPC.
  vpc_id = aws_vpc.main.id

  # First private subnet CIDR range.
  cidr_block = "10.0.11.0/24"

  # Place this subnet in the first Availability Zone.
  availability_zone = data.aws_availability_zones.available.names[0]

  # Do not automatically assign public IPv4 addresses.
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-1"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}


# ------------------------------------------------------------
# Private Subnet - AZ 2
# ------------------------------------------------------------

resource "aws_subnet" "private_2" {
  # Create the second private subnet in our VPC.
  vpc_id = aws_vpc.main.id

  # Second private subnet CIDR range.
  cidr_block = "10.0.12.0/24"

  # Place this subnet in the second Availability Zone.
  availability_zone = data.aws_availability_zones.available.names[1]

  # Keep resources private.
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-2"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}