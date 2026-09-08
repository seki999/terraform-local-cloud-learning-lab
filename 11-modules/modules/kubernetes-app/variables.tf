# ============================================================
# modules/kubernetes-app/variables.tf
# ============================================================

variable "app_name" {
  type        = string
  description = "应用名称，同时用作 Deployment/Service 名和 app label 的值"
}

variable "namespace" {
  type        = string
  description = "部署到哪个 Namespace（调用方负责保证这个 Namespace 已存在）"
}

variable "image" {
  type = string
}

variable "replicas" {
  type    = number
  default = 1
}

variable "container_port" {
  type    = number
  default = 80
}
