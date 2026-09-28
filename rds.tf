# ============================================================
# RDS DB Subnet Group
# ============================================================
# RDS is deployed into PRIVATE subnets.
#
# We use two private subnets in different Availability Zones
# so that the RDS subnet group satisfies AWS requirements.
# ============================================================

resource "aws_db_subnet_group" "postgres" {
  name = "${var.project_name}-${var.environment}-postgres-subnet-group"

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


# ============================================================
# RDS PostgreSQL
# ============================================================
# Managed PostgreSQL database shared by the microservices.
#
# Product Service
# Order Service
# Inventory Service
#
# All connect through the RDS security group on port 5432.
# ============================================================

resource "aws_db_instance" "postgres" {

  # ----------------------------------------------------------
  # Identity
  # ----------------------------------------------------------

  identifier = "${var.project_name}-${var.environment}-postgres"


  # ----------------------------------------------------------
  # Database Engine
  # ----------------------------------------------------------

  engine = "postgres"

  # PostgreSQL version currently supported by RDS.
  engine_version = "17.11"


  # ----------------------------------------------------------
  # Compute
  # ----------------------------------------------------------
  # Keep the instance class configurable so dev/staging/prod
  # can use different sizes.

  instance_class = var.rds_instance_class


  # ----------------------------------------------------------
  # Storage
  # ----------------------------------------------------------

  allocated_storage = 20

  # RDS can automatically grow storage up to 50 GiB.
  max_allocated_storage = 50

  storage_type = "gp3"

  # Encrypt database storage at rest.
  storage_encrypted = true


  # ----------------------------------------------------------
  # Initial Database
  # ----------------------------------------------------------

  db_name = "ecommerce"

  username = "postgres"

  port = 5432


  # ----------------------------------------------------------
  # Password Management
  # ----------------------------------------------------------
  # RDS generates and manages the master password in
  # AWS Secrets Manager.
  #
  # ECS later receives username/password from this secret.

  manage_master_user_password = true


  # ----------------------------------------------------------
  # Network Security
  # ----------------------------------------------------------
  # RDS stays private and is NOT directly accessible from
  # the public internet.

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]


  # ----------------------------------------------------------
  # Backups
  # ----------------------------------------------------------
  # DEV  -> 0 days for cost saving.
  # PROD -> 7 days.
  #
  # RDS backup_retention_period = 0 disables automated backups.

  backup_retention_period = var.environment == "prod" ? 7 : 0


  # ----------------------------------------------------------
  # Maintenance
  # ----------------------------------------------------------

  auto_minor_version_upgrade = true

  apply_immediately = true


  # ----------------------------------------------------------
  # Availability
  # ----------------------------------------------------------
  # DEV  -> single AZ to reduce cost.
  # PROD -> Multi-AZ for higher availability.

  multi_az = var.environment == "prod"


  # ----------------------------------------------------------
  # Deletion Protection
  # ----------------------------------------------------------
  # DEV  -> Terraform destroy can remove the DB.
  # PROD -> Prevent accidental deletion.

  deletion_protection = var.environment == "prod"


  # ----------------------------------------------------------
  # Snapshot Behaviour
  # ----------------------------------------------------------
  # DEV  -> no final snapshot to simplify destroy.
  # PROD -> final snapshot should be retained.

  skip_final_snapshot = var.environment != "prod"

  copy_tags_to_snapshot = true


  # ----------------------------------------------------------
  # Tags
  # ----------------------------------------------------------

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Project     = var.project_name
    Environment = var.environment
    Service     = "rds"
  }
}