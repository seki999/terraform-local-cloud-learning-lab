# ============================================================
# messaging.tf —— SQS + SNS，以及 SNS -> SQS 的扇出（fan-out）订阅
# ============================================================

resource "aws_sqs_queue" "records_queue" {
  name       = "${var.project_prefix}-records-queue"
  depends_on = [null_resource.wait_for_localstack]
}

resource "aws_sns_topic" "notifications" {
  name       = "${var.project_prefix}-notifications"
  depends_on = [null_resource.wait_for_localstack]
}

# --------------------------------------------------------------
# 独立的第二个队列，专门用来演示 SNS -> SQS 扇出模式
# （和上面 Lambda 直接写入的 records_queue 是两条完全独立的链路，
# 分开是为了让"API Gateway -> Lambda -> ... -> SQS"和
# "SNS -> SQS"这两个知识点互不干扰、可以分别验证）。
# --------------------------------------------------------------
resource "aws_sqs_queue" "notifications_queue" {
  name       = "${var.project_prefix}-notifications-queue"
  depends_on = [null_resource.wait_for_localstack]
}

# --------------------------------------------------------------
# SQS 队列策略：允许 SNS Topic 向这个队列发送消息。
# 这是真实 AWS 里经常被忽略、导致"订阅了但收不到消息"的一步——
# SNS -> SQS 的扇出并不是"订阅了就自动有权限"，SQS 队列本身
#需要一份显式的基于资源的策略（resource-based policy），
# 声明"我允许这个 SNS Topic 调用 sqs:SendMessage"。
# --------------------------------------------------------------
resource "aws_sqs_queue_policy" "allow_sns" {
  queue_url  = aws_sqs_queue.notifications_queue.id
  depends_on = [null_resource.wait_for_localstack]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.notifications_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.notifications.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "notifications_to_sqs" {
  topic_arn  = aws_sns_topic.notifications.arn
  protocol   = "sqs"
  endpoint   = aws_sqs_queue.notifications_queue.arn
  depends_on = [aws_sqs_queue_policy.allow_sns]
}
