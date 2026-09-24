# ------------------------------------------------------------
# ECR Repository - Product Service
# ------------------------------------------------------------
# Stores the Docker image of the Product Service.

resource "aws_ecr_repository" "product_service" {
  # Repository name is generated from project and environment.
  # Example: ecommerce-dev-product-service
  name = "${var.project_name}-${var.environment}-product-service"

  # Prevent accidental replacement of an existing image tag.
  # A new deployment should use a new tag.
  image_tag_mutability = "IMMUTABLE"

  # Automatically scan each pushed image for vulnerabilities.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encrypt images using AWS-managed ECR encryption.
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Add useful AWS tags for identification and cost tracking.
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}


# ------------------------------------------------------------
# ECR Repository - Order Service
# ------------------------------------------------------------
# Stores the Docker image of the Order Service.

resource "aws_ecr_repository" "order_service" {
  # Repository name: ecommerce-dev-order-service
  name = "${var.project_name}-${var.environment}-order-service"

  # Keep image tags immutable.
  image_tag_mutability = "IMMUTABLE"

  # Scan Docker images when they are pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encrypt images at rest.
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}


# ------------------------------------------------------------
# ECR Repository - Inventory Service
# ------------------------------------------------------------
# Stores the Docker image of the Inventory Service.

resource "aws_ecr_repository" "inventory_service" {
  # Repository name: ecommerce-dev-inventory-service
  name = "${var.project_name}-${var.environment}-inventory-service"

  # Prevent overwriting an existing image tag.
  image_tag_mutability = "IMMUTABLE"

  # Scan every pushed image for known vulnerabilities.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Use AWS-managed encryption.
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}