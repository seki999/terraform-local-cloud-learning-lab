# ============================================================
# main.tf —— 被测试的对象本身
# ------------------------------------------------------------
# 这份配置故意保持简单（不依赖 Docker/Kubernetes），
# 让本章的重点完全落在"怎么测试 Terraform 配置"这件事本身，
# 而不是被测对象的复杂度上。
# ============================================================

resource "random_pet" "servers" {
  count  = var.replica_count
  length = 2
  prefix = var.name_prefix

  lifecycle {
    # postcondition：资源创建/更新**之后**做的断言，用来校验
    # Provider 实际返回的结果是否符合预期——这不是校验输入
    # （那是 variable 的 validation block 的职责），而是校验
    # "Provider 真正做出来的东西对不对"。
    postcondition {
      condition     = length(self.id) > 0
      error_message = "random_pet 生成的 id 不应该为空。"
    }
  }
}
