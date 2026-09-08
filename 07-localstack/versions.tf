# ============================================================
# versions.tf
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "docker" {}

# ------------------------------------------------------------
# provider "aws" —— 本章的核心：让官方 AWS Provider 连接
# LocalStack，而不是真实 AWS。
#
# access_key / secret_key：LocalStack 默认不校验凭证内容是否真实
# 有效（任意非空字符串都能通过），这里写 "test"/"test" 只是为了
# 满足 AWS Provider "必须提供凭证"的基本校验，不代表任何真实身份。
#
# endpoints block：把这个 Provider 里用到的每一个 AWS 服务的
# API 地址，全部重定向到本地 LocalStack 容器暴露的
# http://127.0.0.1:4566（LocalStack 用同一个端口模拟所有服务，
# 通过请求里的信息内部路由到对应的模拟实现，这也是为什么下面
# 每个服务的 endpoint 都写的是同一个地址）。
#
# skip_*_validation / s3_use_path_style：绕过 AWS Provider
# 默认针对"真实 AWS"设计的一些校验和寻址行为，这些校验/行为假设
# 连接的是真实 AWS 的公网服务，对本地模拟环境没有意义甚至会报错
# （比如真实 S3 用基于域名的虚拟主机寻址，本地 LocalStack 更适合
# 用基于路径的寻址方式）。
#
# 这里统一用 127.0.0.1 而不是 localhost：在 Windows + Docker Desktop
# 上，"localhost" 有时会被 Go 编写的 Provider 解析成 IPv6 的 ::1，
# 而 Docker Desktop 对发布端口的 IPv6 环回转发并不总是可靠——
# 这是本项目在 09-vault 章节实测踩到、并在这里预先规避的坑，
# 完整背景见 docs/05-debugging-guide.md。
# ------------------------------------------------------------
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3             = "http://127.0.0.1:4566"
    dynamodb       = "http://127.0.0.1:4566"
    sqs            = "http://127.0.0.1:4566"
    sns            = "http://127.0.0.1:4566"
    lambda         = "http://127.0.0.1:4566"
    apigateway     = "http://127.0.0.1:4566"
    iam            = "http://127.0.0.1:4566"
    sts            = "http://127.0.0.1:4566"
    cloudwatch     = "http://127.0.0.1:4566"
    cloudwatchlogs = "http://127.0.0.1:4566"
    events         = "http://127.0.0.1:4566"
    secretsmanager = "http://127.0.0.1:4566"
  }
}
