resource "aws_db_subnet_group" "postgres" {
  name       = "${var.project_name}-${var.environment}-postgres-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "17.11"
  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "ecommerce"
  username = "postgres"
  port     = 5432

  manage_master_user_password = true

  publicly_accessible = false

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [var.rds_security_group_id]

  backup_retention_period = var.environment == "prod" ? 30 : 0

  auto_minor_version_upgrade = true
  apply_immediately          = var.environment != "prod"

  multi_az              = var.environment == "prod"
  deletion_protection   = var.environment == "prod"
  skip_final_snapshot   = var.environment != "prod"
  copy_tags_to_snapshot = true

  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.instance_class != "db.t3.micro"
      error_message = "Production must use a database instance class selected for the expected workload; db.t3.micro is a development default."
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}
