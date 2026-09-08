# ============================================================
# loki.tf —— 部署 Loki（日志存储与查询系统）
# ------------------------------------------------------------
# 复用 06-helm 章节安装的 Helm Provider 用法，把 Loki 加进同一个
# "monitoring" Namespace，方便集群内的 Grafana 直接通过 Service DNS
# 名字访问它，不需要额外的网络打通。
# ============================================================

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_chart_version

  namespace        = "monitoring"
  create_namespace = false
  # create_namespace = false：本章假设 06-helm 已经创建过 "monitoring"
  # Namespace（由 kube-prometheus-stack 的 Release 创建）。
  # 如果 06-helm 还没跑过，请先完成那一章，或把这里改成 true。

  values = [
    file("${path.module}/loki-values.yaml")
  ]

  timeout = 300
}
