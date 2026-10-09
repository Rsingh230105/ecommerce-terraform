# ------------------------------------------------------------
# IAM Policy for Inventory SQS Consumer
# ------------------------------------------------------------
# This policy gives the Inventory application only the SQS
# permissions it needs to consume messages from the Inventory queue.

resource "aws_iam_policy" "inventory_sqs_consumer" {
  # Create a descriptive policy name.
  name = "${var.project_name}-${var.environment}-inventory-sqs-consumer"

  description = "Allow Inventory Service to consume messages from the Inventory SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        # Read messages from the queue.
        # Delete successfully processed messages.
        # Get queue information.
        # Change visibility timeout when needed during processing.
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]

        # IMPORTANT:
        # Allow access only to our Inventory queue.
        # We are not giving access to all SQS queues (*).
        Resource = var.inventory_queue_arn
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
    Purpose     = "sqs-consumer"
  }
}


# ------------------------------------------------------------
# Attach Inventory SQS Policy to ECS Task Role
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "inventory_sqs_consumer" {
  # Our application container uses this ECS task role.
  role = aws_iam_role.inventory_task.name
  # Attach only the Inventory SQS consumer permissions.
  policy_arn = aws_iam_policy.inventory_sqs_consumer.arn
}

# ------------------------------------------------------------
# Order Service - SNS Publish Policy
# ------------------------------------------------------------
# Order Service publishes order events to the SNS topic.

resource "aws_iam_policy" "order_sns_publish" {
  # Descriptive policy name.
  name = "${var.project_name}-${var.environment}-order-sns-publish"

  description = "Allow Order Service to publish events to the Order Events SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        # Order Service only needs to publish messages.
        Action = [
          "sns:Publish"
        ]

        # Restrict access to our specific SNS topic.
        Resource = var.order_events_topic_arn
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "order"
    Purpose     = "sns-publisher"
  }
}


# ------------------------------------------------------------
# Attach SNS Publish Policy to Order Task Role
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "order_sns_publish" {
  # Order container receives the SNS publish permission.
  role = aws_iam_role.order_task.name

  # Attach the Order SNS policy.
  policy_arn = aws_iam_policy.order_sns_publish.arn
}

# ------------------------------------------------------------
# ECS Task Execution Role - RDS Secret Access
# ------------------------------------------------------------
# ECS needs permission to read the RDS-managed Secrets Manager
# secret when injecting DB credentials into the container.
#
# This permission is for the ECS/Fargate agent.
# It is NOT the application's task-role permission.

resource "aws_iam_role_policy" "ecs_execution_secret_access" {
  # Attach this inline policy to the ECS Task Execution Role.
  role = aws_iam_role.ecs_task_execution.id

  # Descriptive policy name.
  name = "${var.project_name}-${var.environment}-ecs-secret-access"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        # Allow ECS to retrieve the database secret.
        Action = [
          "secretsmanager:GetSecretValue"
        ]

        # IMPORTANT:
        # Allow access only to the secret created by RDS.
        Resource = var.database_master_secret_arn
      }
    ]
  })
}