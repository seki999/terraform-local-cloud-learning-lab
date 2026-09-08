# ============================================================
# versions.tf
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.16"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-terraform-lab"
  }
}

# ------------------------------------------------------------
# provider "grafana"：注意这个 Provider 连接的不是 Kubernetes API，
# 而是 Grafana 自己的 HTTP API——所以它需要的是 Grafana 的访问地址
# 和一组管理员凭证，和前面章节里的 kubernetes/helm Provider
# 完全是"两个世界"。
#
# 因为 Grafana 跑在 Kind 集群内部，Terraform（跑在 Windows 宿主机上）
# 需要一条能到达它的路径——本章约定：apply 之前，你需要在另一个
# 终端保持运行：
#   kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# 这也是为什么 url 默认写 http://127.0.0.1:3000（不用 localhost，
# 原因见 docs/05-debugging-guide.md 第 12 条）。
# ------------------------------------------------------------
provider "grafana" {
  url  = var.grafana_url
  auth = "admin:${var.grafana_admin_password}"
}
