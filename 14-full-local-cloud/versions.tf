# ============================================================
# versions.tf —— 毕业实验：统一编排 Kind + Vault
# LocalStack/AWS provider 已从主线毕业实验移除。
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-terraform-lab"
}

provider "docker" {}

provider "vault" {
  address = "http://127.0.0.1:8201"
  token   = var.vault_root_token
}
