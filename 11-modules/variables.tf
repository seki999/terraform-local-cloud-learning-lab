# ============================================================
# variables.tf —— root module
# ============================================================

variable "namespace_name" {
  type    = string
  default = "learning-11-modules"
}

variable "enable_monitoring_module" {
  type        = bool
  description = "是否演示 monitoring module（需要先完成 06-helm + 08-monitoring，并保持 kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 运行）"
  default     = false
}

variable "grafana_url" {
  type    = string
  default = "http://127.0.0.1:3000"
}

variable "grafana_admin_password" {
  type      = string
  default   = "demo-password"
  sensitive = true
}
