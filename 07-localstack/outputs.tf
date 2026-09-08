# ============================================================
# outputs.tf
# ============================================================

output "api_invoke_url" {
  description = "LocalStack 上 REST API 的调用地址（注意路径格式和真实 AWS 不同，见 README）"
  value       = "http://127.0.0.1:4566/restapis/${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_stage.dev.stage_name}/_user_request_/records"
}

output "curl_example" {
  description = "验证整条链路的示例命令"
  value       = "curl -X POST -H \"Content-Type: application/json\" -d '{\\\"message\\\":\\\"hello\\\"}' \"http://127.0.0.1:4566/restapis/${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_stage.dev.stage_name}/_user_request_/records\""
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.records.name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.archive.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.records_queue.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.notifications.arn
}

output "notifications_queue_url" {
  value = aws_sqs_queue.notifications_queue.id
}
