# ============================================================
# variables.tf
# ============================================================

variable "grafana_url" {
  type        = string
  description = "Grafana 的访问地址（需要先启动 port-forward，见 README）"
  default     = "http://127.0.0.1:3000"
  # 用 127.0.0.1 而不是 localhost：Windows + Docker Desktop 上的
  # 已知 IPv6/IPv4 解析不一致问题，详见 docs/05-debugging-guide.md 第 12 条。
}

variable "grafana_admin_password" {
  type        = string
  description = "必须和 06-helm 章节里设置的 grafana_admin_password 一致"
  default     = "demo-password"
  sensitive   = true
}

variable "loki_chart_version" {
  type        = string
  description = "Loki Helm Chart 版本"
  default     = "7.3.0"
}
