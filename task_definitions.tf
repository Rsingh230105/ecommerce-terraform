# ============================================================
# ECS TASK DEFINITIONS
# ============================================================
#
# We have three microservices:
#
# 1. Product Service
# 2. Order Service
# 3. Inventory Service
#
# Every task definition describes:
#
# - Docker image
# - CPU and memory
# - Container port
# - IAM roles
# - Environment variables
# - Secrets
# - CloudWatch logging
# - Fargate runtime
#
# Architecture:
#
# ECR
#  ↓
# ECS Task Definition
#  ↓
# ECS Fargate Service
#  ↓
# Private Subnet
#  ↓
# ALB
#
# ============================================================


# Product Service Task Definition
# Product Service handles product-related application APIs
# and stores product data in PostgreSQL.
resource "aws_ecs_task_definition" "product" {
  # Task definition family name.
  # ECS creates revisions under this family.
  family = "${var.project_name}-${var.environment}-product"

  # This task definition is designed for AWS Fargate.
  requires_compatibilities = ["FARGATE"]

  # Fargate uses AWS VPC networking.
  network_mode = "awsvpc"

  # CPU assigned to the task.
  cpu = var.product_ecs_task_cpu

  # Memory assigned to the task in MB.
  memory = var.product_ecs_task_memory

  # ----------------------------------------------------------
  # IAM ROLE: EXECUTION ROLE
  # ----------------------------------------------------------
  # ECS/Fargate uses this role to:
  # - Pull the Docker image from ECR
  # - Send logs to CloudWatch
  # - Read secrets when ECS injects them
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  # ----------------------------------------------------------
  # IAM ROLE: APPLICATION TASK ROLE
  # ----------------------------------------------------------
  # Product application code uses this role for AWS API calls.
  # Product-specific S3 permission is attached to this role.
  task_role_arn = aws_iam_role.product_task.arn

  # ----------------------------------------------------------
  # Container Definition
  # ----------------------------------------------------------
  # ECS expects container definitions as JSON.
  container_definitions = jsonencode([
    {
      # Container name.
      # This must match the ECS service load_balancer block.
      name = "product-service"

      # Pull Product Service image from our ECR repository.
      #
      # Example:
      # ecommerce-dev-product-service:v1
      image = "${aws_ecr_repository.product_service.repository_url}:${var.product_image_tag}"

      # This is the main application container.
      essential = true

      # --------------------------------------------------------
      # Port Mapping
      # --------------------------------------------------------
      # Product Service listens on port 8000.
      portMappings = [
        {
          name          = "http"
          containerPort = var.product_service_port
          hostPort      = var.product_service_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      # --------------------------------------------------------
      # Normal Environment Variables
      # --------------------------------------------------------
      # These values are not secrets.
      environment = [
        {
          # PostgreSQL hostname inside the VPC.
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          # PostgreSQL port.
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          # PostgreSQL database name.
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          # AWS region used by the application.
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]

      # --------------------------------------------------------
      # Sensitive Environment Variables
      # --------------------------------------------------------
      # DB username and password are NOT hardcoded.
      # ECS retrieves them from the RDS-managed Secrets Manager
      # secret.
      secrets = [
        {
          # Inject the username JSON key from the secret.
          name = "DB_USER"

          # Secrets Manager JSON-key format:
          # secret-arn:json-key::
          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:username::"
        },
        {
          # Inject the password JSON key from the secret.
          name = "DB_PASSWORD"

          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
        }
      ]

      # --------------------------------------------------------
      # CloudWatch Logging
      # --------------------------------------------------------
      # Container stdout/stderr logs are sent to CloudWatch.
      logConfiguration = {
        logDriver = "awslogs"

        options = {
          # Product Service log group.
          awslogs-group = aws_cloudwatch_log_group.product_service.name

          # AWS region for the log group.
          awslogs-region = var.aws_region

          # Prefix for ECS log streams.
          awslogs-stream-prefix = "ecs"
        }
      }

      # Give the application time to gracefully stop.
      stopTimeout = 30
    }
  ])

  # ----------------------------------------------------------
  # Fargate Runtime Platform
  # ----------------------------------------------------------
  # Linux containers running on x86_64 architecture.
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # Make sure ECS has permission to read the RDS secret
  # before registering this task definition.
  depends_on = [
    aws_iam_role_policy.ecs_execution_secret_access
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "product"
  }
}


# ------------------------------------------------------------
# Order Service Task Definition
# ------------------------------------------------------------
# Order Service handles orders and publishes order events
# to the SNS Order Events topic.

resource "aws_ecs_task_definition" "order" {

  # Task definition family name.
  family = "${var.project_name}-${var.environment}-order"

  # Run this task using AWS Fargate.
  requires_compatibilities = ["FARGATE"]

  # Fargate networking mode.
  network_mode = "awsvpc"

  # Development CPU allocation.
  cpu = var.order_ecs_task_cpu

  # Development memory allocation.
  memory = var.order_ecs_task_memory

  # Role used by ECS/Fargate infrastructure.
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  # Role used by Order application code.
  # This role has SNS publish permission.
  task_role_arn = aws_iam_role.order_task.arn

  # JSON container definition.
  container_definitions = jsonencode([
    {
      # Container name.
      name = "order-service"

      # Pull Order Service image from ECR.
      image = "${aws_ecr_repository.order_service.repository_url}:${var.order_image_tag}"

      # This container is required for the task to stay healthy.
      essential = true

      # --------------------------------------------------------
      # Port Mapping
      # --------------------------------------------------------
      # Order Service uses port 8001.
      portMappings = [
        {
          containerPort = var.order_service_port
          hostPort      = var.order_service_port
          protocol      = "tcp"
        }
      ]

      # --------------------------------------------------------
      # Normal Environment Variables
      # --------------------------------------------------------
      environment = [
        {
          # PostgreSQL hostname.
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          # PostgreSQL port.
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          # Database name.
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          # Private Service Connect endpoint for Product Service.
          #
          # Order calls:
          #   http://product-service:8000/products/{product_id}
          #
          # This traffic stays inside the ECS/VPC environment
          # and does not use the public ALB.
          name  = "PRODUCT_SERVICE_URL"
          value = "http://product-service:8000"
        },
        {
          # SNS topic used by Order Service to publish events.
          name  = "SNS_ORDER_EVENTS_TOPIC_ARN"
          value = aws_sns_topic.order_events.arn
        },
        {
          # AWS region used by boto3/AWS SDK.
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]

      # --------------------------------------------------------
      # Database Secrets
      # --------------------------------------------------------
      secrets = [
        {
          # Database username from Secrets Manager.
          name = "DB_USER"

          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:username::"
        },
        {
          # Database password from Secrets Manager.
          name = "DB_PASSWORD"

          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
        }
      ]

      # --------------------------------------------------------
      # CloudWatch Logs
      # --------------------------------------------------------
      logConfiguration = {
        logDriver = "awslogs"

        options = {
          # Order Service log group.
          awslogs-group = aws_cloudwatch_log_group.order_service.name

          # AWS region.
          awslogs-region = var.aws_region

          # ECS stream prefix.
          awslogs-stream-prefix = "ecs"
        }
      }

      # Graceful shutdown timeout.
      stopTimeout = 30
    }
  ])

  # Fargate Linux/x86_64 runtime.
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # Ensure secret-reading permission exists before
  # registering this task definition.
  depends_on = [
    aws_iam_role_policy.ecs_execution_secret_access
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
  }
}


# ------------------------------------------------------------
# Inventory Service Task Definition
# ------------------------------------------------------------
# Inventory Service provides the HTTP Inventory API and will
# later consume Order events from SQS.

resource "aws_ecs_task_definition" "inventory" {

  # Task definition family.
  family = "${var.project_name}-${var.environment}-inventory"

  # Run using AWS Fargate.
  requires_compatibilities = ["FARGATE"]

  # Fargate networking.
  network_mode = "awsvpc"

  # Development CPU allocation.
  cpu = var.inventory_ecs_task_cpu

  # Development memory allocation.
  memory = var.inventory_ecs_task_memory

  # ECS/Fargate infrastructure role.
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  # Inventory application role.
  # This role has SQS consumer permissions.
  task_role_arn = aws_iam_role.inventory_task.arn

  # JSON container definition.
  container_definitions = jsonencode([
    {
      # Container name.
      name = "inventory-service"

      # Pull Inventory Service image from ECR.
      image = "${aws_ecr_repository.inventory_service.repository_url}:${var.inventory_image_tag}"

      # This container is required.
      essential = true

      # --------------------------------------------------------
      # Port Mapping
      # --------------------------------------------------------
      # Your Inventory Service currently runs on port 8002.
      portMappings = [
        {
          containerPort = var.inventory_service_port
          hostPort      = var.inventory_service_port
          protocol      = "tcp"
        }
      ]

      # --------------------------------------------------------
      # Normal Environment Variables
      # --------------------------------------------------------
      environment = [
        {
          # PostgreSQL hostname.
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          # PostgreSQL port.
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          # Ecommerce database.
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          # AWS region used by boto3.
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          # Main Inventory SQS queue URL.
          #
          # The Inventory worker will use this URL to receive
          # ORDER_CREATED events.
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.inventory_queue.url
        }
      ]

      # --------------------------------------------------------
      # Database Secrets
      # --------------------------------------------------------
      secrets = [
        {
          # Database username.
          name = "DB_USER"

          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:username::"
        },
        {
          # Database password.
          name = "DB_PASSWORD"

          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
        }
      ]

      # --------------------------------------------------------
      # CloudWatch Logs
      # --------------------------------------------------------
      logConfiguration = {
        logDriver = "awslogs"

        options = {
          # Inventory log group.
          awslogs-group = aws_cloudwatch_log_group.inventory_service.name

          # AWS region.
          awslogs-region = var.aws_region

          # ECS stream prefix.
          awslogs-stream-prefix = "ecs"
        }
      }

      # Give the Inventory container time to shut down cleanly.
      stopTimeout = 30
    }
  ])

  # Fargate Linux/x86_64 runtime.
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # Make sure ECS can read the database secret.
  depends_on = [
    aws_iam_role_policy.ecs_execution_secret_access
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
  }
}
# ------------------------------------------------------------
# Order Outbox Publisher ECS Task Definition
# ------------------------------------------------------------

resource "aws_ecs_task_definition" "order_publisher" {
  family                   = "${var.project_name}-${var.environment}-order-publisher"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.order_publisher_ecs_task_cpu
  memory = var.order_publisher_ecs_task_memory

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.order_task.arn

  container_definitions = jsonencode([
    {
      name      = "order-publisher"
      image     = "${aws_ecr_repository.order_service.repository_url}:${var.order_image_tag}"
      essential = true

      # Override the Dockerfile ENTRYPOINT so this task runs
      # the Outbox Publisher instead of FastAPI/Uvicorn.
      entryPoint = ["python"]
      command    = ["-m", "app.outbox_publisher"]

      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "SNS_ORDER_EVENTS_TOPIC_ARN"
          value = aws_sns_topic.order_events.arn
        }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.order_service.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "outbox-publisher"
        }
      }

      stopTimeout = 30
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  depends_on = [
    aws_iam_role_policy.ecs_execution_secret_access
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order-publisher"
  }
}
