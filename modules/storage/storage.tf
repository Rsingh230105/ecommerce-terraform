data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "product_media" {
  bucket = "${var.project_name}-${var.environment}-product-media-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "storage"
    Purpose     = "product-media"
  }
}

resource "aws_s3_bucket_versioning" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
