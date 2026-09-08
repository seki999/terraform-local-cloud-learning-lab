# ============================================================
# modules/docker-network/main.tf
# ------------------------------------------------------------
# 这是本项目里最简单的一个 module——只包一个资源。
# 即使只包一个资源，把它抽成 module 依然有价值：调用方不需要
# 知道"底层是 docker_network 资源"这个实现细节，只需要知道
# "给我一个名字，我给你一个网络"，这就是模块化封装的核心好处。
#
# 注意：这个 module 目录里没有 required_providers/provider 配置块
# ——child module 不需要（通常也不应该）自己声明 provider 配置，
# Provider 的连接信息由调用方（root module）统一提供，
# child module 只是"消费"调用方已经配置好的 Provider。
# ============================================================

resource "docker_network" "this" {
  name = var.name
}
