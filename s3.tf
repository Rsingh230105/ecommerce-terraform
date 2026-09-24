# ------------------------------------------------------------
# AWS Account Information
# ------------------------------------------------------------
# We use the AWS account ID in the bucket name so the name is
# unique across AWS accounts.
data "aws_caller_identity" "current" {}


# ------------------------------------------------------------
# S3 Bucket - Product Media
# ------------------------------------------------------------
# This bucket stores product images/media used by our services.

resource "aws_s3_bucket" "product_media" {
  # S3 bucket names must be globally unique.
  # The AWS account ID helps make this name unique.
  bucket = "${var.project_name}-${var.environment}-product-media-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "storage"
    Purpose     = "product-media"
  }
}


# ------------------------------------------------------------
# S3 Bucket Versioning
# ------------------------------------------------------------
# Versioning keeps previous versions of objects when they are
# updated or replaced.

resource "aws_s3_bucket_versioning" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  versioning_configuration {
    # Enable object versioning.
    status = "Enabled"
  }
}


# ------------------------------------------------------------
# S3 Server-Side Encryption
# ------------------------------------------------------------
# Encrypt objects at rest using S3-managed encryption.

resource "aws_s3_bucket_server_side_encryption_configuration" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  rule {
    apply_server_side_encryption_by_default {
      # AWS-managed S3 encryption key.
      sse_algorithm = "AES256"
    }
  }
}


# ------------------------------------------------------------
# S3 Public Access Block
# ------------------------------------------------------------
# Product media bucket should not be publicly accessible
# by default. Applications will access it using IAM permissions.

resource "aws_s3_bucket_public_access_block" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  # Block public ACL-based access.
  block_public_acls = true

  # Block public bucket policies.
  block_public_policy = true

  # Ignore public ACLs.
  ignore_public_acls = true

  # Restrict public bucket policies.
  restrict_public_buckets = true
}


# ------------------------------------------------------------
# S3 Object Ownership
# ------------------------------------------------------------
# BucketOwnerEnforced disables ACL-based ownership and makes
# the bucket owner own uploaded objects.

resource "aws_s3_bucket_ownership_controls" "product_media" {
  bucket = aws_s3_bucket.product_media.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}