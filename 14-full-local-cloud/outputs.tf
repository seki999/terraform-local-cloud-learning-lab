# ============================================================
# outputs.tf
# ============================================================

output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}

output "frontend_port_forward_command" {
  value = "kubectl port-forward -n ${var.namespace_name} svc/frontend 8100:80"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_data.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.app_records.name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.app_events.id
}

output "lambda_function_name" {
  value = aws_lambda_function.hello.function_name
}

output "vault_addr" {
  value = "http://127.0.0.1:8201"
}

output "vault_secret_path" {
  value = "graduation-secret/data/app/database"
}
