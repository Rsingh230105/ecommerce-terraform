module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = module.networking.vpc_cidr_block

  product_service_port   = var.product_service_port
  order_service_port     = var.order_service_port
  inventory_service_port = var.inventory_service_port
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  force_delete = var.environment == "dev"
}

module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  environment           = var.environment
  instance_class        = var.rds_instance_class
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
}

module "messaging" {
  source = "./modules/messaging"

  project_name = var.project_name
  environment  = var.environment
}

moved {
  from = aws_cloudwatch_log_group.product_service
  to   = module.observability.aws_cloudwatch_log_group.product_service
}

moved {
  from = aws_cloudwatch_log_group.order_service
  to   = module.observability.aws_cloudwatch_log_group.order_service
}

moved {
  from = aws_cloudwatch_log_group.inventory_service
  to   = module.observability.aws_cloudwatch_log_group.inventory_service
}

module "observability" {
  source = "./modules/observability"

  project_name      = var.project_name
  environment       = var.environment
  retention_in_days = var.environment == "prod" ? 30 : 7
}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id

  product_service_port   = var.product_service_port
  order_service_port     = var.order_service_port
  inventory_service_port = var.inventory_service_port
  enable_https           = var.environment == "prod"
  certificate_arn        = var.acm_certificate_arn
}

module "iam" {
  source = "./modules/iam"

  project_name               = var.project_name
  environment                = var.environment
  inventory_queue_arn        = module.messaging.inventory_queue_arn
  order_events_topic_arn     = module.messaging.order_events_topic_arn
  database_master_secret_arn = module.database.master_secret_arn
}

module "ecs" {
  source = "./modules/ecs"

  project_name                    = var.project_name
  environment                     = var.environment
  aws_region                      = var.aws_region
  product_service_port            = var.product_service_port
  order_service_port              = var.order_service_port
  inventory_service_port          = var.inventory_service_port
  product_image_tag               = var.product_image_tag
  order_image_tag                 = var.order_image_tag
  inventory_image_tag             = var.inventory_image_tag
  product_ecs_task_cpu            = var.product_ecs_task_cpu
  product_ecs_task_memory         = var.product_ecs_task_memory
  order_ecs_task_cpu              = var.order_ecs_task_cpu
  order_ecs_task_memory           = var.order_ecs_task_memory
  inventory_ecs_task_cpu          = var.inventory_ecs_task_cpu
  inventory_ecs_task_memory       = var.inventory_ecs_task_memory
  order_publisher_ecs_task_cpu    = var.order_publisher_ecs_task_cpu
  order_publisher_ecs_task_memory = var.order_publisher_ecs_task_memory
  fargate_platform_version        = var.fargate_platform_version
  product_desired_count           = var.product_desired_count
  order_desired_count             = var.order_desired_count
  inventory_desired_count         = var.inventory_desired_count
  order_publisher_desired_count   = var.order_publisher_desired_count

  private_subnet_ids         = module.networking.private_subnet_ids
  ecs_security_group_id      = module.security.ecs_security_group_id
  product_target_group_arn   = module.alb.product_target_group_arn
  order_target_group_arn     = module.alb.order_target_group_arn
  inventory_target_group_arn = module.alb.inventory_target_group_arn

  product_ecr_repository_url   = module.ecr.product_service_repository_url
  order_ecr_repository_url     = module.ecr.order_service_repository_url
  inventory_ecr_repository_url = module.ecr.inventory_service_repository_url
  database_endpoint            = module.database.endpoint
  database_port                = module.database.port
  database_name                = module.database.database_name
  database_master_secret_arn   = module.database.master_secret_arn
  order_events_topic_arn       = module.messaging.order_events_topic_arn
  inventory_queue_url          = module.messaging.inventory_queue_url
  product_log_group_name       = module.observability.product_log_group_name
  order_log_group_name         = module.observability.order_log_group_name
  inventory_log_group_name     = module.observability.inventory_log_group_name

  task_execution_role_arn = module.iam.task_execution_role_arn
  product_task_role_arn   = module.iam.product_task_role_arn
  order_task_role_arn     = module.iam.order_task_role_arn
  inventory_task_role_arn = module.iam.inventory_task_role_arn

  depends_on = [
    module.alb,
    module.iam
  ]
}

moved {
  from = aws_iam_role.ecs_task_execution
  to   = module.iam.aws_iam_role.ecs_task_execution
}

moved {
  from = aws_iam_role_policy_attachment.ecs_task_execution
  to   = module.iam.aws_iam_role_policy_attachment.ecs_task_execution
}

moved {
  from = aws_iam_role.product_task
  to   = module.iam.aws_iam_role.product_task
}

moved {
  from = aws_iam_role.order_task
  to   = module.iam.aws_iam_role.order_task
}

moved {
  from = aws_iam_role.inventory_task
  to   = module.iam.aws_iam_role.inventory_task
}

moved {
  from = aws_iam_policy.inventory_sqs_consumer
  to   = module.iam.aws_iam_policy.inventory_sqs_consumer
}

moved {
  from = aws_iam_role_policy_attachment.inventory_sqs_consumer
  to   = module.iam.aws_iam_role_policy_attachment.inventory_sqs_consumer
}

moved {
  from = aws_iam_policy.order_sns_publish
  to   = module.iam.aws_iam_policy.order_sns_publish
}

moved {
  from = aws_iam_role_policy_attachment.order_sns_publish
  to   = module.iam.aws_iam_role_policy_attachment.order_sns_publish
}

moved {
  from = aws_iam_role_policy.ecs_execution_secret_access
  to   = module.iam.aws_iam_role_policy.ecs_execution_secret_access
}

moved {
  from = aws_ecs_cluster.main
  to   = module.ecs.aws_ecs_cluster.main
}

moved {
  from = aws_ecs_task_definition.product
  to   = module.ecs.aws_ecs_task_definition.product
}

moved {
  from = aws_ecs_task_definition.order
  to   = module.ecs.aws_ecs_task_definition.order
}

moved {
  from = aws_ecs_task_definition.inventory
  to   = module.ecs.aws_ecs_task_definition.inventory
}

moved {
  from = aws_ecs_task_definition.order_publisher
  to   = module.ecs.aws_ecs_task_definition.order_publisher
}

moved {
  from = aws_ecs_service.product
  to   = module.ecs.aws_ecs_service.product
}

moved {
  from = aws_ecs_service.order
  to   = module.ecs.aws_ecs_service.order
}

moved {
  from = aws_ecs_service.inventory
  to   = module.ecs.aws_ecs_service.inventory
}

moved {
  from = aws_ecs_service.order_publisher
  to   = module.ecs.aws_ecs_service.order_publisher
}

moved {
  from = aws_service_discovery_http_namespace.service_connect
  to   = module.ecs.aws_service_discovery_http_namespace.service_connect
}

moved {
  from = aws_lb.main
  to   = module.alb.aws_lb.main
}

moved {
  from = aws_lb_target_group.product
  to   = module.alb.aws_lb_target_group.product
}

moved {
  from = aws_lb_target_group.order
  to   = module.alb.aws_lb_target_group.order
}

moved {
  from = aws_lb_target_group.inventory
  to   = module.alb.aws_lb_target_group.inventory
}

moved {
  from = aws_lb_listener.http
  to   = module.alb.aws_lb_listener.http
}

moved {
  from = aws_lb_listener_rule.product
  to   = module.alb.aws_lb_listener_rule.product
}

moved {
  from = aws_lb_listener_rule.order
  to   = module.alb.aws_lb_listener_rule.order
}

moved {
  from = aws_lb_listener_rule.inventory
  to   = module.alb.aws_lb_listener_rule.inventory
}

moved {
  from = aws_s3_bucket.product_media
  to   = module.storage.aws_s3_bucket.product_media
}

moved {
  from = aws_s3_bucket_versioning.product_media
  to   = module.storage.aws_s3_bucket_versioning.product_media
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.product_media
  to   = module.storage.aws_s3_bucket_server_side_encryption_configuration.product_media
}

moved {
  from = aws_s3_bucket_public_access_block.product_media
  to   = module.storage.aws_s3_bucket_public_access_block.product_media
}

moved {
  from = aws_s3_bucket_ownership_controls.product_media
  to   = module.storage.aws_s3_bucket_ownership_controls.product_media
}

moved {
  from = aws_sns_topic.order_events
  to   = module.messaging.aws_sns_topic.order_events
}

moved {
  from = aws_sqs_queue.inventory_dlq
  to   = module.messaging.aws_sqs_queue.inventory_dlq
}

moved {
  from = aws_sqs_queue.inventory_queue
  to   = module.messaging.aws_sqs_queue.inventory_queue
}

moved {
  from = aws_sqs_queue_redrive_policy.inventory_queue
  to   = module.messaging.aws_sqs_queue_redrive_policy.inventory_queue
}

moved {
  from = aws_sqs_queue_redrive_allow_policy.inventory_dlq
  to   = module.messaging.aws_sqs_queue_redrive_allow_policy.inventory_dlq
}

moved {
  from = aws_sqs_queue_policy.inventory_queue
  to   = module.messaging.aws_sqs_queue_policy.inventory_queue
}

moved {
  from = aws_sns_topic_subscription.inventory_queue
  to   = module.messaging.aws_sns_topic_subscription.inventory_queue
}

moved {
  from = aws_db_subnet_group.postgres
  to   = module.database.aws_db_subnet_group.postgres
}

moved {
  from = aws_db_instance.postgres
  to   = module.database.aws_db_instance.postgres
}

moved {
  from = aws_ecr_repository.product_service
  to   = module.ecr.aws_ecr_repository.product_service
}

moved {
  from = aws_ecr_repository.order_service
  to   = module.ecr.aws_ecr_repository.order_service
}

moved {
  from = aws_ecr_repository.inventory_service
  to   = module.ecr.aws_ecr_repository.inventory_service
}

moved {
  from = aws_ecr_lifecycle_policy.product_service
  to   = module.ecr.aws_ecr_lifecycle_policy.product_service
}

moved {
  from = aws_security_group.alb
  to   = module.security.aws_security_group.alb
}

moved {
  from = aws_security_group.ecs
  to   = module.security.aws_security_group.ecs
}

moved {
  from = aws_security_group.rds
  to   = module.security.aws_security_group.rds
}

moved {
  from = aws_vpc_security_group_ingress_rule.alb_http
  to   = module.security.aws_vpc_security_group_ingress_rule.alb_http
}

moved {
  from = aws_vpc_security_group_ingress_rule.product_from_alb
  to   = module.security.aws_vpc_security_group_ingress_rule.product_from_alb
}

moved {
  from = aws_vpc_security_group_ingress_rule.ecs_service_connect_product
  to   = module.security.aws_vpc_security_group_ingress_rule.ecs_service_connect_product
}

moved {
  from = aws_vpc_security_group_ingress_rule.order_from_alb
  to   = module.security.aws_vpc_security_group_ingress_rule.order_from_alb
}

moved {
  from = aws_vpc_security_group_ingress_rule.inventory_from_alb
  to   = module.security.aws_vpc_security_group_ingress_rule.inventory_from_alb
}

moved {
  from = aws_vpc_security_group_ingress_rule.rds_from_ecs
  to   = module.security.aws_vpc_security_group_ingress_rule.rds_from_ecs
}

moved {
  from = aws_vpc_security_group_egress_rule.alb_to_product
  to   = module.security.aws_vpc_security_group_egress_rule.alb_to_product
}

moved {
  from = aws_vpc_security_group_egress_rule.alb_to_order
  to   = module.security.aws_vpc_security_group_egress_rule.alb_to_order
}

moved {
  from = aws_vpc_security_group_egress_rule.alb_to_inventory
  to   = module.security.aws_vpc_security_group_egress_rule.alb_to_inventory
}

moved {
  from = aws_vpc_security_group_egress_rule.ecs_https
  to   = module.security.aws_vpc_security_group_egress_rule.ecs_https
}

moved {
  from = aws_vpc_security_group_egress_rule.ecs_dns_udp
  to   = module.security.aws_vpc_security_group_egress_rule.ecs_dns_udp
}

moved {
  from = aws_vpc_security_group_egress_rule.ecs_dns_tcp
  to   = module.security.aws_vpc_security_group_egress_rule.ecs_dns_tcp
}

moved {
  from = aws_vpc_security_group_egress_rule.ecs_to_rds
  to   = module.security.aws_vpc_security_group_egress_rule.ecs_to_rds
}

moved {
  from = aws_vpc_security_group_egress_rule.ecs_service_connect_product
  to   = module.security.aws_vpc_security_group_egress_rule.ecs_service_connect_product
}

moved {
  from = aws_vpc.main
  to   = module.networking.aws_vpc.main
}

moved {
  from = aws_internet_gateway.main
  to   = module.networking.aws_internet_gateway.main
}

moved {
  from = aws_eip.nat
  to   = module.networking.aws_eip.nat
}

moved {
  from = aws_nat_gateway.main
  to   = module.networking.aws_nat_gateway.main
}

moved {
  from = aws_subnet.public_1
  to   = module.networking.aws_subnet.public_1
}

moved {
  from = aws_subnet.public_2
  to   = module.networking.aws_subnet.public_2
}

moved {
  from = aws_subnet.private_1
  to   = module.networking.aws_subnet.private_1
}

moved {
  from = aws_subnet.private_2
  to   = module.networking.aws_subnet.private_2
}

moved {
  from = aws_route_table.public
  to   = module.networking.aws_route_table.public
}

moved {
  from = aws_route.public_internet
  to   = module.networking.aws_route.public_internet
}

moved {
  from = aws_route_table_association.public_1
  to   = module.networking.aws_route_table_association.public_1
}

moved {
  from = aws_route_table_association.public_2
  to   = module.networking.aws_route_table_association.public_2
}

moved {
  from = aws_route_table.private
  to   = module.networking.aws_route_table.private
}

moved {
  from = aws_route_table_association.private_1
  to   = module.networking.aws_route_table_association.private_1
}

moved {
  from = aws_route_table_association.private_2
  to   = module.networking.aws_route_table_association.private_2
}

moved {
  from = aws_route.private_internet
  to   = module.networking.aws_route.private_internet
}
