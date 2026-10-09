resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_eip" "nat_2" {
  count  = var.environment == "prod" ? 1 : 0
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip-2"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.main,
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "secondary" {
  count         = var.environment == "prod" ? 1 : 0
  allocation_id = aws_eip.nat_2[0].id
  subnet_id     = aws_subnet.public_2.id

  depends_on = [
    aws_internet_gateway.main,
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-2"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table" "private_2" {
  count  = var.environment == "prod" ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt-2"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}

resource "aws_route" "private_internet_2" {
  count                  = var.environment == "prod" ? 1 : 0
  route_table_id         = aws_route_table.private_2[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.secondary[0].id
}
