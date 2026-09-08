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
# 注意 config_context 是 "kind-terraform-lab"——Kind 有一个约定：
# 集群名叫 X 时，kubectl context 自动被命名为 "kind-X"
# （区别于 Minikube 的 context 直接叫 "minikube"）。
# ------------------------------------------------------------
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-terraform-lab"
}
