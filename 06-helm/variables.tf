# ============================================================
# variables.tf
# ============================================================

variable "ingress_nginx_chart_version" {
  type        = string
  description = "ingress-nginx Chart 版本（写死具体版本，而不是留空拿最新版，避免'今天能跑、明天升级后跑不了'的漂移）"
  default     = "4.15.1"
}

variable "kube_prometheus_stack_chart_version" {
  type        = string
  description = "kube-prometheus-stack Chart 版本"
  default     = "90.0.0"
}

variable "grafana_admin_password" {
  type        = string
  description = "Grafana 管理员密码（教学占位符，非真实密码）"
  default     = "demo-password"
  sensitive   = true
}

variable "install_ingress_nginx" {
  type        = bool
  description = "是否安装 ingress-nginx。如果你已经在 05-kubernetes/10-ingress 用 kubectl apply 装过一份，建议先卸载那份或把这里设为 false，避免同一个 Namespace 里出现两套 ingress-nginx 控制器互相冲突。"
  default     = true
}
