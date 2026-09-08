# ============================================================
# versions.tf —— 毕业实验：统一编排 Kind + LocalStack + Vault
# （+ 可选 Monitoring，见 variables.tf 里 enable_monitoring 的说明）
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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-terraform-lab"
}

provider "docker" {}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3       = "http://127.0.0.1:4567"
    dynamodb = "http://127.0.0.1:4567"
    sqs      = "http://127.0.0.1:4567"
    lambda   = "http://127.0.0.1:4567"
    iam      = "http://127.0.0.1:4567"
    sts      = "http://127.0.0.1:4567"
  }
  # 注意端口是 4567，不是 07-localstack 章节用的 4566——
  # 本章的 LocalStack 容器故意用不同端口，避免和 07-localstack
  # 章节残留的容器/端口冲突，让本章可以独立于第 7 章运行。
}

provider "vault" {
  address = "http://127.0.0.1:8201"
  token   = var.vault_root_token
  # 同理，端口 8201 而不是 09-vault 章节的 8200，避免冲突。
}
