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
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "docker" {}

# ------------------------------------------------------------
# provider "vault"：连接本地用 Docker 跑起来的开发模式 Vault。
# token 用的是 Dev 模式下写死的 root token（教学占位符，
# 见 variables.tf 里的说明）——在真实生产环境，任何自动化工具
# 用来初始化 Vault 结构的凭证，都应该是权限受控、可轮换、
# 有完整审计记录的，而不是像这里一样直接用 root token。
# ------------------------------------------------------------
provider "vault" {
  address = "http://127.0.0.1:8200"
  # 注意：这里用 127.0.0.1 而不是 localhost。
  # 在 Windows + Docker Desktop 上，"localhost" 有时会被解析成 IPv6
  # 的 ::1，而 Docker Desktop 对发布端口的 IPv6 环回转发并不总是
  # 可靠（这是本项目实测踩到的坑：PowerShell 的 Invoke-WebRequest
  # 默认优先走 IPv4 所以能连通，但 Vault Provider 底层 Go HTTP
  # 客户端解析 "localhost" 走了 IPv6，导致 connection refused）。
  # 显式写 127.0.0.1 强制走 IPv4，绕开这个不确定性。
  # 完整背景见 docs/05-debugging-guide.md。
  token = var.vault_root_token
}
