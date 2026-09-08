# ============================================================
# localstack.tf —— 本地"AWS"：S3 + DynamoDB + SQS + Lambda
# ------------------------------------------------------------
# 端口用 4567（07-localstack 章节用的是 4566），避免两章的容器冲突。
# 这里刻意只实现资源本身，不重复 07-localstack 章节已经完整搭建
# 过的 API Gateway -> Lambda -> DynamoDB -> SQS 全链路，
# 让毕业实验的重点落在"多个领域被同一份 Terraform 配置统一编排"，
# 而不是重新造一遍第 7 章的轮子。
# ============================================================

resource "docker_image" "localstack" {
  name         = "localstack/localstack:3.8"
  keep_locally = true
}

resource "docker_container" "localstack" {
  name  = "localstack-graduation"
  image = docker_image.localstack.image_id

  ports {
    internal = 4566
    external = 4567
  }

  env = [
    "SERVICES=s3,dynamodb,sqs,lambda,iam,sts,logs",
    "DEBUG=0",
    "PERSISTENCE=0",
    "LAMBDA_EXECUTOR=docker",
  ]

  volumes {
    host_path      = "//var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  restart = "unless-stopped"
}

resource "time_sleep" "wait_for_localstack_container" {
  depends_on      = [docker_container.localstack]
  create_duration = "5s"
}

resource "null_resource" "wait_for_localstack" {
  depends_on = [time_sleep.wait_for_localstack_container]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = "SilentlyContinue"
      for ($i = 0; $i -lt 24; $i++) {
        try {
          $resp = Invoke-WebRequest -Uri "http://127.0.0.1:4567/_localstack/health" -UseBasicParsing -TimeoutSec 3
          if ($resp.StatusCode -eq 200) { Write-Host "LocalStack is ready."; exit 0 }
        } catch {}
        Start-Sleep -Seconds 5
      }
      Write-Error "LocalStack did not become ready in time."
      exit 1
    EOT
  }
}

resource "aws_s3_bucket" "app_data" {
  bucket = "graduation-app-data"

  # force_destroy：见 07-localstack/storage.tf 里的详细注释——
  # S3 bucket 默认拒绝删除非空的桶，本章 Lambda 会真的写对象进去，
  # 不加这个参数会导致 destroy 失败。
  force_destroy = true

  depends_on = [null_resource.wait_for_localstack]
}

resource "aws_dynamodb_table" "app_records" {
  name         = "graduation-records"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  depends_on = [null_resource.wait_for_localstack]
}

resource "aws_sqs_queue" "app_events" {
  name       = "graduation-events"
  depends_on = [null_resource.wait_for_localstack]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "graduation-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  depends_on = [null_resource.wait_for_localstack]
}

resource "aws_lambda_function" "hello" {
  function_name    = "graduation-hello"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 15
}
