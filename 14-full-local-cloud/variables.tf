# ============================================================
# variables.tf
# ============================================================

variable "namespace_name" {
  type    = string
  default = "graduation-project"
}

variable "vault_root_token" {
  type      = string
  default   = "root-token-graduation"
  sensitive = true
}

variable "db_password" {
  type        = string
  description = "最终会被 Vault 保管，并通过 data source 读出、写进 Kubernetes Secret 的密码"
  default     = "demo-password"
  sensitive   = true
}

variable "frontend_replicas" {
  type    = number
  default = 2
}
