# ============================================================
# main.tf —— Workspace 驱动的多环境配置
# ------------------------------------------------------------
# 核心手法：用 terraform.workspace 这个内置引用，从一张"环境配置表"
# 里查出当前 Workspace 对应的参数，而不是靠 -var 手动传参
# ——这样 `dev`/`test`/`prod-like` 三个 Workspace 即使共用同一份
# .tf 代码，也能自动表现出不同的"规格"。
# ============================================================

locals {
  # 这张表本身可以理解成"每个环境的期望状态定义"。
  # lookup() 的第三个参数是"找不到对应 key 时的兜底值"——
  # 这样即使有人创建了一个表里没列出的 Workspace（比如 "qa"），
  # 也不会直接报错，而是退回到一个安全的默认配置。
  env_configs = {
    dev = {
      replica_count = 1
      log_level     = "debug"
    }
    test = {
      replica_count = 2
      log_level     = "info"
    }
    "prod-like" = {
      replica_count = 3
      log_level     = "warn"
    }
  }

  current_env = lookup(local.env_configs, terraform.workspace, {
    replica_count = 1
    log_level     = "debug"
  })
}

resource "local_file" "env_summary" {
  filename = "${path.module}/generated/${terraform.workspace}-summary.txt"

  content = <<-EOT
    workspace     = ${terraform.workspace}
    replica_count = ${local.current_env.replica_count}
    log_level     = ${local.current_env.log_level}
  EOT
}
