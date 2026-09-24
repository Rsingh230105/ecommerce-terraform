# ------------------------------------------------------------
# RDS DB Subnet Group
# ------------------------------------------------------------
# RDS needs subnets in at least two Availability Zones.
# We use our two PRIVATE subnets so the database is not
# directly exposed to the public internet.

resource "aws_db_subnet_group" "postgres" {
  # Create a descriptive subnet group name.
  name = "${var.project_name}-${var.environment}-postgres-subnet-group"

  # Put RDS inside our two private subnets.
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}


# ------------------------------------------------------------
# RDS PostgreSQL Instance
# ------------------------------------------------------------
# This is the managed PostgreSQL database for our e-commerce
# microservices.

resource "aws_db_instance" "postgres" {
  # Unique identifier of the RDS instance.
  identifier = "${var.project_name}-${var.environment}-postgres"

  # PostgreSQL database engine.
  engine = "postgres"

  # Pin the PostgreSQL major/minor version for predictable deployments.
  # AWS currently lists PostgreSQL 17.11 for RDS.
  engine_version = "17.11"

  # Small development instance to keep the learning environment
  # relatively low-cost. Increase this for production workloads.
  instance_class = "db.t3.micro"

  # Initial database storage in GiB.
  allocated_storage = 20

  # Allow RDS to automatically increase storage when required,
  # up to 50 GiB.
  max_allocated_storage = 50

  # Standard General Purpose SSD storage.
  storage_type = "gp3"

  # Encrypt database storage at rest.
  storage_encrypted = true

  # Database name created when the instance is initialized.
  db_name = "ecommerce"

  # Master username used by the application/database administration.
  username = "postgres"

  # Let RDS generate and manage the master password in
  # AWS Secrets Manager instead of hardcoding a password.
  manage_master_user_password = true

  # PostgreSQL default port.
  port = 5432

  # Keep the database private.
  publicly_accessible = false

  # Use our private RDS subnet group.
  db_subnet_group_name = aws_db_subnet_group.postgres.name

  # Allow only our ECS security group to connect to PostgreSQL.
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  # Keep automated backups for 7 days.
  backup_retention_period = 7

  # Apply minor version patches automatically.
  auto_minor_version_upgrade = true

  # Do not create a Multi-AZ standby for this learning/dev setup.
  multi_az = false

  # Copy tags to automated/manual snapshots.
  copy_tags_to_snapshot = true

  # Useful for development so Terraform doesn't wait for
  # maintenance windows for normal changes.
  apply_immediately = true

  # Dev environment setting:
  # allow Terraform to destroy the database without requiring
  # deletion protection.
  deletion_protection = false

  # Do not require a final snapshot when destroying this dev DB.
  # Production databases should normally use a final snapshot.
  skip_final_snapshot = true

  # Tags help identify the database in AWS.
  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}