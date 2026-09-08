# ============================================================
# versions.tf —— Terraform 自身的元配置
# ------------------------------------------------------------
# 这是一份 Terraform 配置里"最先被读"的文件（按约定俗成的命名，
# Terraform 实际上会读取目录下所有 .tf 文件并合并解析，文件名
# 本身对 Terraform 没有特殊含义，"versions.tf" 只是社区约定的命名习惯）。
# ============================================================

terraform {
  # required_version 限定"这份配置只能被哪个版本区间的 Terraform CLI 执行"。
  # 写法上 ">= 1.7.0" 表示"至少 1.7.0，不设上限"。
  # 为什么要写这个约束？因为不同大版本之间 HCL 语法或行为可能有细微变化，
  # 显式声明可以让别人（或未来的你）一眼看出这份配置是在什么版本上写的、
  # 测试过的，避免用过旧版本的 CLI 跑出诡异的兼容性问题。
  required_version = ">= 1.7.0"

  required_providers {
    # random Provider：本章用它生成"看起来像资源"的随机值（宠物名、随机字符串），
    # 不需要任何真实系统，纯粹在本地计算生成，非常适合"零依赖"的第一课。
    random = {
      source  = "hashicorp/random" # Provider 在 Terraform Registry 上的完整地址
      version = "~> 3.6"           # 版本约束："3.6.x 及以上的 3.x"，不允许跳到 4.0
    }

    # local Provider：用来管理本地文件系统上的文件（创建/读取文本文件）。
    # 它没有任何"云"的概念，操作对象就是你磁盘上的文件——
    # 这让它成为演示 resource/data source 生命周期的最佳教具：
    # 你可以直接打开生成的文件，用肉眼确认 Terraform 到底做了什么。
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# ------------------------------------------------------------
# 为什么这里没有 provider "random" {} / provider "local" {} 配置块？
#
# provider 配置块用来传递"这个 Provider 需要知道的连接信息"
# （比如 Docker Provider 需要知道连哪个 Docker daemon，
# AWS Provider 需要知道 region、access key）。
# random 和 local 这两个 Provider 完全不需要连接任何外部系统，
# 没有任何需要配置的参数，所以可以完全省略 provider 块——
# Terraform 会使用它们的"零值默认配置"。
# 在 02-docker 章节你会看到第一个真正需要配置的 provider 块。
# ------------------------------------------------------------
