# ============================================================
# versions.tf
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

# ------------------------------------------------------------
# provider "kubernetes" 配置块
# ------------------------------------------------------------
# 和 Docker Provider 不同，Kubernetes Provider 需要明确知道：
#   1. 连哪个集群的 API Server（config_path 指向的 kubeconfig 文件里
#      记录了 API Server 地址、CA 证书等连接信息）；
#   2. 用 kubeconfig 里的哪一个 context（一个 kubeconfig 文件可以同时
#      记录多个集群的连接信息，比如你的电脑上可能同时有 minikube 和
#      Kind 两个集群的 context——config_context 决定 Terraform 具体用哪一个）。
#
# 这里显式写 config_context = "minikube"，是为了避免"kubectl 当前
# context切换到了别的集群，Terraform 却在操作错误集群"这类事故——
# 见 docs/05-debugging-guide.md 第 4 条。
# ------------------------------------------------------------
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}
