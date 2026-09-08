# ============================================================
# variables.tf
# ============================================================

variable "namespace_name" {
  type        = string
  description = "本章所有资源所在的 Kubernetes Namespace 名称"
  default     = "terraform-learning"
}

variable "environment" {
  type        = string
  description = "环境标识，会写进 ConfigMap 里的欢迎页内容"
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment 必须是 dev / test / prod 之一。"
  }
}

variable "replica_count" {
  type        = number
  description = "Deployment 的副本数量"
  default     = 2

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 5
    error_message = "replica_count 必须在 1 到 5 之间（教学环境限制，避免占用过多本地资源）。"
  }
}

variable "welcome_message" {
  type        = string
  description = "首页展示的欢迎语"
  default     = "Hello from Terraform + Kubernetes (Minikube)!"
}

variable "api_key" {
  type        = string
  description = "演示 Secret 用的 API Key（教学占位符，非真实密钥）"
  default     = "demo-api-key"
  sensitive   = true
}

variable "pvc_size" {
  type        = string
  description = "PersistentVolumeClaim 请求的存储容量"
  default     = "1Gi"
}

variable "storage_class" {
  type        = string
  description = "PVC 使用的 StorageClass。Minikube 默认自带名为 \"standard\" 的 StorageClass（由内置的 storage-provisioner addon 提供，基于 hostPath 实现）。"
  default     = "standard"
}

variable "ingress_host" {
  type        = string
  description = "Ingress 规则绑定的域名（无需修改系统 hosts 文件，验证时用 curl --resolve 模拟域名解析，见 README）"
  default     = "web.local.learning-lab"
}
