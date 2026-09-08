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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

# ------------------------------------------------------------
# provider "helm" 需要一个嵌套的 kubernetes 配置块——
# Helm 本质上也是通过 Kubernetes API Server 工作的（它把 Chart
# 渲染成一批标准的 Kubernetes manifest，再像 kubectl apply 一样
# 提交给 API Server，同时在集群里维护一份 Release 的"账本"
# 记录哪些资源属于哪个 Release），所以 Helm Provider 同样需要
# 知道连哪个集群、哪个 context。
# ------------------------------------------------------------
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-terraform-lab"
  }
}

# 同时保留一个 kubernetes provider，供本章验证/清理时按需引用
# （比如用 data source 查询 Helm 创建出来的资源）。
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-terraform-lab"
}
