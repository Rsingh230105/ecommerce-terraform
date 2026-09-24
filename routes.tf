# ------------------------------------------------------------
# Public Route Table
# ------------------------------------------------------------
# Public subnets need a route to the Internet Gateway.
# This allows public-facing resources such as the ALB to
# communicate with the internet.

resource "aws_route_table" "public" {
  # Create the route table inside our main VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}


# ------------------------------------------------------------
# Public Internet Route
# ------------------------------------------------------------
# 0.0.0.0/0 means all IPv4 internet traffic.
# The Internet Gateway handles this traffic.

resource "aws_route" "public_internet" {
  # Use the public route table.
  route_table_id = aws_route_table.public.id

  # Send all internet-bound traffic through the IGW.
  destination_cidr_block = "0.0.0.0/0"

  # Our VPC Internet Gateway.
  gateway_id = aws_internet_gateway.main.id
}


# ------------------------------------------------------------
# Associate Public Subnet 1 with Public Route Table
# ------------------------------------------------------------

resource "aws_route_table_association" "public_1" {
  # Public subnet that belongs to AZ 1.
  subnet_id = aws_subnet.public_1.id

  # Public route table.
  route_table_id = aws_route_table.public.id
}


# ------------------------------------------------------------
# Associate Public Subnet 2 with Public Route Table
# ------------------------------------------------------------

resource "aws_route_table_association" "public_2" {
  # Public subnet that belongs to AZ 2.
  subnet_id = aws_subnet.public_2.id

  # Public route table.
  route_table_id = aws_route_table.public.id
}


# ------------------------------------------------------------
# Private Route Table
# ------------------------------------------------------------
# Private subnets will use the NAT Gateway for outbound internet
# access without giving the resources public IP addresses.

resource "aws_route_table" "private" {
  # Create the private route table inside our VPC.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}


# ------------------------------------------------------------
# Associate Private Subnet 1
# ------------------------------------------------------------

resource "aws_route_table_association" "private_1" {
  # Private subnet in AZ 1.
  subnet_id = aws_subnet.private_1.id

  # Private route table.
  route_table_id = aws_route_table.private.id
}


# ------------------------------------------------------------
# Associate Private Subnet 2
# ------------------------------------------------------------

resource "aws_route_table_association" "private_2" {
  # Private subnet in AZ 2.
  subnet_id = aws_subnet.private_2.id

  # Private route table.
  route_table_id = aws_route_table.private.id
}