# ============================================================
# variables.tf
# ============================================================

variable "localstack_services" {
  type        = string
  description = "LocalStack 容器要启动哪些模拟服务（逗号分隔），对应 SERVICES 环境变量"
  default     = "s3,dynamodb,sqs,sns,lambda,apigateway,iam,sts,logs,events,secretsmanager"
}

variable "project_prefix" {
  type        = string
  description = "本章所有资源名称的统一前缀，避免和其他章节/其他人的实验冲突"
  default     = "learning-lab"
}
