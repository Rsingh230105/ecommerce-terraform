output "product_media_bucket_name" {
  description = "Name of the Product Media S3 bucket"
  value       = aws_s3_bucket.product_media.id
}

output "product_media_bucket_arn" {
  description = "ARN of the Product Media S3 bucket"
  value       = aws_s3_bucket.product_media.arn
}
