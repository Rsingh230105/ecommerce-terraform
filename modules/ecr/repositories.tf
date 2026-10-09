resource "aws_ecr_repository" "product_service" {
  name                 = "${var.project_name}-${var.environment}-product-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}

resource "aws_ecr_repository" "order_service" {
  name                 = "${var.project_name}-${var.environment}-order-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete

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

resource "aws_ecr_repository" "inventory_service" {
  name                 = "${var.project_name}-${var.environment}-inventory-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete

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
