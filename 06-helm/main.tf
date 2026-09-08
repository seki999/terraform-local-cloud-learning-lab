# ============================================================
# main.tf —— 用 Terraform Helm Provider 部署两个真实的社区 Chart
# ============================================================

# --------------------------------------------------------------
# helm_release：Terraform 里对应"一次 helm install"的资源。
# 核心字段：
#   repository —— Chart 仓库地址（对应 `helm repo add`）；
#   chart      —— 仓库里的 Chart 名字；
#   version    —— **务必写死具体版本**（这里显式用变量传入，而不是
#                 留空让 Helm 拿"最新版"）——否则同一份 Terraform 配置，
#                 今天 apply 和三个月后 apply 可能装出完全不同版本的
#                 Chart，这是"版本约束"思想（呼应 versions.tf 里
#                 Provider 的版本约束）在 Helm Chart 层面的延伸；
#   values     —— 传入 values.yaml 内容（可以传多个文件，
#                 后面的文件覆盖前面的同名字段，和 Terraform 变量
#                 优先级的"后者覆盖前者"是同一种设计思路）。
# --------------------------------------------------------------
resource "helm_release" "ingress_nginx" {
  count = var.install_ingress_nginx ? 1 : 0
  # count 用一个条件表达式控制"要不要创建这个资源"——
  # 这是 count 的一个常见用法："0 或 1"，实现"资源开关"的效果，
  # 比用一整个额外的 if/else 结构更简洁。

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_chart_version

  namespace        = "ingress-nginx"
  create_namespace = true
  # create_namespace：让 Helm 自己创建目标 Namespace，
  # 不需要我们额外写一个 kubernetes_namespace 资源
  # ——这是 Helm Provider 和 Kubernetes Provider 分工上的一个小差异，
  # 提醒你 Helm Release 本身也在管理"它需要的周边资源"。

  values = [
    file("${path.module}/values/ingress-nginx-values.yaml")
  ]

  timeout = 300
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_chart_version

  namespace        = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/values/kube-prometheus-stack-values.yaml")
  ]

  # set_sensitive：和 values 文件里的字段合并，但专门用于"不希望明文
  # 出现在 values 文件里"的敏感值——效果类似 Terraform 变量的
  # sensitive = true，会在 plan/apply 的终端输出里隐藏具体值。
  # 注意：和 01-terraform-basics 里验证过的结论一样，这依然只影响
  # CLI 展示，Helm 自己也会把这个值存进集群里的 Release Secret，
  # 同样存在"State/Secret 里是明文"的问题，不是绝对安全的方案。
  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  timeout = 600
  # kube-prometheus-stack 包含的组件较多（Prometheus/Grafana/
  # Alertmanager/node-exporter/kube-state-metrics 等），
  # 镜像拉取 + 启动时间比单个 Chart 长，适当调大超时时间。
}
