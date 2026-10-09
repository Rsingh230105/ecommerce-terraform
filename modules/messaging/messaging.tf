resource "aws_sns_topic" "order_events" {
  name = "${var.project_name}-${var.environment}-order-events"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "messaging"
  }
}

resource "aws_sqs_queue" "inventory_dlq" {
  name                      = "${var.project_name}-${var.environment}-inventory-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
    Purpose     = "dead-letter-queue"
  }
}

resource "aws_sqs_queue" "inventory_queue" {
  name                       = "${var.project_name}-${var.environment}-inventory-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 10
  sqs_managed_sse_enabled    = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "inventory"
    Purpose     = "main-queue"
  }
}

resource "aws_sqs_queue_redrive_policy" "inventory_queue" {
  queue_url = aws_sqs_queue.inventory_queue.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.inventory_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "inventory_dlq" {
  queue_url = aws_sqs_queue.inventory_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.inventory_queue.arn]
  })
}

data "aws_iam_policy_document" "inventory_queue" {
  statement {
    sid    = "AllowSNSToSendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.inventory_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.order_events.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "inventory_queue" {
  queue_url = aws_sqs_queue.inventory_queue.id
  policy    = data.aws_iam_policy_document.inventory_queue.json
}

resource "aws_sns_topic_subscription" "inventory_queue" {
  topic_arn            = aws_sns_topic.order_events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.inventory_queue.arn
  raw_message_delivery = true

  depends_on = [
    aws_sqs_queue_policy.inventory_queue,
  ]
}
