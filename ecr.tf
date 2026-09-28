# ============================================================
# ECR Repository - Product Service
# ============================================================
# Stores the Docker image of the Product Service.

resource "aws_ecr_repository" "product_service" {

  # Example:
  # ecommerce-dev-product-service
  name = "${var.project_name}-${var.environment}-product-service"

  # Do not allow an existing image tag to be overwritten.
  #
  # Use versioned tags:
  # v1.0.0
  # v1.0.1
  # v1.0.2
  image_tag_mutability = "IMMUTABLE"

  # DEV:
  # Terraform can delete repository even when images exist.
  #
  # PROD:
  # false -> repository must be emptied before deletion.
  force_delete = var.environment == "dev"

  # Scan every image when pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encrypt images at rest using AWS-managed encryption.
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Resource tags.
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}


# ============================================================
# ECR Repository - Order Service
# ============================================================
# Stores the Docker image of the Order Service.

resource "aws_ecr_repository" "order_service" {

  name = "${var.project_name}-${var.environment}-order-service"

  image_tag_mutability = "IMMUTABLE"

  force_delete = var.environment == "dev"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}


# ============================================================
# ECR Repository - Inventory Service
# ============================================================
# Stores the Docker image of the Inventory Service.

resource "aws_ecr_repository" "inventory_service" {

  name = "${var.project_name}-${var.environment}-inventory-service"

  image_tag_mutability = "IMMUTABLE"

  force_delete = var.environment == "dev"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}