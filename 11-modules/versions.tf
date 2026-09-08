# ============================================================
# versions.tf —— root module
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.16"
    }
  }
}

provider "docker" {}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-terraform-lab"
}

# 只有 enable_monitoring_module = true 时才会真正用到这个 Provider
# （见 main.tf 里 module "dashboard" 的 count 开关），
# 但 provider 块本身不区分"用不用"，即使暂时不用也需要能够初始化——
# 这也是为什么它的地址允许指向一个可能还没启动 port-forward 的位置，
# 只要不真正创建 grafana_* 资源，Terraform 不会尝试连接它。
provider "grafana" {
  url  = var.grafana_url
  auth = "admin:${var.grafana_admin_password}"
}
