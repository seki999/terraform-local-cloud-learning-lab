# ============================================================
# modules/monitoring/main.tf
# ------------------------------------------------------------
# 把"Folder + Dashboard"这一对经常一起出现的 Grafana 资源封装成
# module。注意这里完全没有出现 provider "grafana" 配置——
# 这个 module 依赖调用方（root module）已经配置好默认的 grafana
# provider，Terraform 会自动把 root module 里未加 alias 的默认
# provider 配置"传递"给它调用的所有子 module，不需要在这里、
# 也不建议在这里重复声明一份 provider 配置。
# ============================================================

resource "grafana_folder" "this" {
  title = var.folder_title
}

resource "grafana_dashboard" "this" {
  folder      = grafana_folder.this.uid
  config_json = var.dashboard_json
}
