output "endpoint" {
  description = "DNS address of the PostgreSQL RDS instance"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "Port of the PostgreSQL RDS instance"
  value       = aws_db_instance.postgres.port
}

output "database_name" {
  description = "Initial database name"
  value       = aws_db_instance.postgres.db_name
}

output "master_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}
