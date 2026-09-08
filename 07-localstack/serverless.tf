# ============================================================
# serverless.tf —— IAM Role + Lambda + API Gateway
# ------------------------------------------------------------
# 完整链路：
#   HTTP 请求 -> API Gateway -> Lambda -> DynamoDB / S3 / SQS
# ============================================================

# --------------------------------------------------------------
# archive_file 数据源：在 apply 时把 lambda/handler.py 打包成
# Lambda 要求的 zip 格式——这是"用代码管理 Lambda 部署包"的标准做法，
# 不需要手工维护一个 zip 文件、不需要额外的构建脚本。
# --------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

# --------------------------------------------------------------
# IAM Role：Lambda 执行时使用的身份。assume_role_policy 声明
# "谁能扮演这个角色"——这里是 lambda.amazonaws.com 这个 AWS 服务，
# 也就是"允许 Lambda 服务本身来扮演这个角色去执行函数"。
# --------------------------------------------------------------
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_prefix}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  depends_on = [null_resource.wait_for_localstack]
}

# --------------------------------------------------------------
# IAM Policy：这个角色实际被允许做什么——遵循最小权限原则，
# 只授予 handler.py 真正用到的三个操作，而不是笼统的
# "*Access" 或 "AdministratorAccess"（这是真实项目里最常见的
# IAM 反模式，本地学习也应该养成对应的良好习惯）。
# --------------------------------------------------------------
resource "aws_iam_role_policy" "lambda_permissions" {
  name = "${var.project_prefix}-lambda-permissions"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.records.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.archive.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.records_queue.arn
      },
      {
        # Lambda 需要能写 CloudWatch Logs 才能让 `aws logs` /
        # LocalStack 日志查询正常工作，这是几乎每个 Lambda 角色
        # 都需要的"标配"权限。
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "process_request" {
  function_name = "${var.project_prefix}-process-request"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  # source_code_hash：每次 handler.py 内容变化，这个哈希值就会变化，
  # Terraform 借此精确判断"代码是否真的变了、需不需要重新部署"，
  # 而不需要每次都强制重新上传整个 zip。

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.records.name
      BUCKET_NAME = aws_s3_bucket.archive.bucket
      QUEUE_URL   = aws_sqs_queue.records_queue.id
    }
  }

  timeout = 30
}

# --------------------------------------------------------------
# API Gateway（REST API，v1）：把 HTTP 请求转发给上面的 Lambda。
# --------------------------------------------------------------
resource "aws_api_gateway_rest_api" "api" {
  name       = "${var.project_prefix}-api"
  depends_on = [null_resource.wait_for_localstack]
}

resource "aws_api_gateway_resource" "records" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "records"
}

resource "aws_api_gateway_method" "post_records" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.records.id
  http_method   = "POST"
  authorization = "NONE"
  # authorization = "NONE"：教学环境不配置任何鉴权，
  # 真实项目里这里通常会是 "AWS_IAM" / 自定义 Lambda Authorizer / Cognito 等。
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.records.id
  http_method = aws_api_gateway_method.post_records.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  # AWS_PROXY（Lambda 代理集成）：API Gateway 把原始 HTTP 请求
  # 几乎原封不动地转发给 Lambda（封装成 event 参数），
  # Lambda 的返回值也必须是特定结构（statusCode/headers/body）
  # ——这正是 handler.py 里返回值格式的由来。
  uri = aws_lambda_function.process_request.invoke_arn
}

# --------------------------------------------------------------
# 授权 API Gateway 调用这个 Lambda——和 SNS -> SQS 的场景类似，
# "配置了集成"不代表"自动有权限调用"，Lambda 这一侧同样需要一份
# 显式的基于资源的策略（resource-based policy）。
# --------------------------------------------------------------
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_request.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]

  triggers = {
    # API Gateway 的 Deployment 是"某一时刻配置的快照"，
    # 光是修改 method/integration 不会自动生成新的 Deployment。
    # 用 triggers 强制 Terraform 在相关资源变化时重新创建 Deployment
    # ——这是社区里应对"API Gateway 需要显式重新部署"这一 AWS 原生
    # 限制的标准写法。
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.records.id,
      aws_api_gateway_method.post_records.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}
