# ------------------------------------------------------------
# IAM Policy Document for the Inventory SQS Queue
# ------------------------------------------------------------

data "aws_iam_policy_document" "inventory_queue_policy" {

  # Allow only Amazon SNS to send messages to this SQS queue.
  statement {
    sid    = "AllowSNSToSendMessage"
    effect = "Allow"

    # AWS SNS service is the principal allowed to send messages.
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    # SNS only needs permission to send messages.
    actions = [
      "sqs:SendMessage"
    ]

    # Permission applies only to our Inventory SQS queue.
    resources = [
      aws_sqs_queue.inventory_queue.arn
    ]

    # Only our specific SNS topic can use this permission.
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        aws_sns_topic.order_events.arn
      ]
    }
  }
}


# ------------------------------------------------------------
# Attach the Policy to the Inventory SQS Queue
# ------------------------------------------------------------

resource "aws_sqs_queue_policy" "inventory_queue" {

  # Attach the policy to the main Inventory queue.
  queue_url = aws_sqs_queue.inventory_queue.id

  # Use the IAM policy document created above.
  policy = data.aws_iam_policy_document.inventory_queue_policy.json
}


# ------------------------------------------------------------
# SNS Topic -> Inventory SQS Subscription
# ------------------------------------------------------------

resource "aws_sns_topic_subscription" "inventory_queue" {

  # SNS topic that publishes Order events.
  topic_arn = aws_sns_topic.order_events.arn

  # SQS queue that receives the events.
  protocol = "sqs"

  endpoint = aws_sqs_queue.inventory_queue.arn

  # Send the original JSON message directly to SQS.
  # This avoids the SNS notification envelope we saw during CLI testing.
  raw_message_delivery = true

  # Make sure the SQS policy exists before creating the subscription.
  depends_on = [
    aws_sqs_queue_policy.inventory_queue
  ]
}