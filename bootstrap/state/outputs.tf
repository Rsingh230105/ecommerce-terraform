output "state_bucket_name" {
  description = "Name to use in the S3 backend configuration"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the protected Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}
