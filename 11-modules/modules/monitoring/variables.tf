# ============================================================
# modules/monitoring/variables.tf
# ============================================================

variable "folder_title" {
  type        = string
  description = "Grafana Folder 名称"
}

variable "dashboard_json" {
  type        = string
  description = "已经渲染好的 Dashboard JSON 字符串（调用方负责用 templatefile() 处理好占位符）"
}
