# ------------------------------------------------------------
# Elastic IP for NAT Gateway
# ------------------------------------------------------------
# NAT Gateway needs a public Elastic IP so private resources
# can access the internet.

resource "aws_eip" "nat" {
  # Create the EIP for the NAT Gateway.
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}


# ------------------------------------------------------------
# NAT Gateway
# ------------------------------------------------------------
# NAT Gateway provides outbound internet access to private
# subnets without exposing private resources directly.

resource "aws_nat_gateway" "main" {
  # Use the Elastic IP created above.
  allocation_id = aws_eip.nat.id

  # NAT Gateway itself must live in a public subnet.
  subnet_id = aws_subnet.public_1.id

  # Make sure the Internet Gateway exists before NAT creation.
  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat"
    Project     = var.project_name
    Environment = var.environment
  }
}


# ------------------------------------------------------------
# Private Internet Route
# ------------------------------------------------------------
# All outbound internet traffic from the private subnets
# goes through the NAT Gateway.

resource "aws_route" "private_internet" {
  # Use the private route table.
  route_table_id = aws_route_table.private.id

  # All IPv4 internet traffic.
  destination_cidr_block = "0.0.0.0/0"

  # Send traffic through the NAT Gateway.
  nat_gateway_id = aws_nat_gateway.main.id
}