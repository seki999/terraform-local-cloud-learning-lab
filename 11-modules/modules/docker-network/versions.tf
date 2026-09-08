# ============================================================
# modules/docker-network/versions.tf
# ------------------------------------------------------------
# 重要：child module 即使不写 provider {} 配置块（配置由 root module
# 统一提供），也**必须**声明 required_providers——尤其是像
# kreuzwerker/docker 这种不在默认的 hashicorp/ 命名空间下的 Provider。
#
# 如果漏掉这个声明，Terraform 会假设这个 module 里用到的 "docker"
# Provider 来自默认命名空间 "hashicorp/docker"（一个根本不存在、
# 或者和这里语义完全不同的 Provider），导致
# "Failed to query available provider packages" 报错——这是本项目
# 实测踩到的坑：一开始只在 root module 的 versions.tf 里声明了
# kreuzwerker/docker，忘记在每个用到它的 child module 里重复声明，
# 结果 `terraform init` 直接失败。
# ============================================================

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
