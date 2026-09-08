# ============================================================
# modules/docker-network/variables.tf —— 这个 module 的输入
# ============================================================

variable "name" {
  type        = string
  description = "Docker 网络名称"
}
