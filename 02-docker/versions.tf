# ============================================================
# versions.tf —— 本章第一次出现"需要真正配置"的 Provider
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    # 注意 source 是 "kreuzwerker/docker"，不是 "hashicorp/docker"——
    # Docker 官方没有由 HashiCorp 维护的 Provider，社区里事实标准是
    # kreuzwerker 团队维护的这一个。这是初学者最容易踩的一个坑
    # （见 docs/05-debugging-guide.md 第 1 条）。
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# ------------------------------------------------------------
# provider "docker" 配置块
# ------------------------------------------------------------
# 和上一章的 local/random 不同，Docker Provider 需要知道"连哪个 Docker
# daemon"。kreuzwerker/docker Provider 在没有显式指定 host 参数时，
# 会按操作系统自动探测默认的 Docker socket/命名管道：
#   - Windows（Docker Desktop）: npipe:////./pipe/docker_engine
#   - Linux                    : unix:///var/run/docker.sock
#   - macOS（Docker Desktop）   : unix:///var/run/docker.sock（走 VM 转发）
#
# 也就是说，只要你的 Docker Desktop 已经启动，下面这个空的 provider 块
# 就足够工作——这也是为什么本章不需要在这里写任何凭证：
# Docker Provider 信任的是"你本机能不能连上 Docker daemon"，
# 而不是某种账号密码。
# ------------------------------------------------------------
provider "docker" {}
