# ============================================================
# variables.tf
# ============================================================

variable "vault_root_token" {
  type        = string
  description = "Vault Dev 模式的 root token（教学占位符，仅用于本地一次性容器，绝不能在真实环境这样使用 root token）"
  default     = "root-token-demo"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "演示用的数据库密码（教学占位符，非真实密码）"
  default     = "demo-password"
  sensitive   = true
}
