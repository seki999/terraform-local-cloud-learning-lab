# ============================================================
# variables.tf —— 本模块的输入变量声明
# ------------------------------------------------------------
# variable 块只做一件事：声明"这个模块接受哪些外部输入、
# 每个输入的类型是什么、如果调用者不提供该用什么默认值"。
# 它本身不产生任何资源，纯粹是"参数定义"。
# ============================================================

variable "environment" {
  type        = string
  description = "当前环境标识，用于演示 validation。必须是 dev / test / prod 之一。"
  default     = "dev"

  # validation block：在 terraform plan 阶段就提前拦截明显错误的输入，
  # 而不是等到 apply 时被 Provider 报一个不知所云的 API 错误。
  # condition 是一个必须求值为 true 的布尔表达式；
  # 一旦为 false，Terraform 会直接报错并显示 error_message，
  # 中断执行，不会进入 plan 计算。
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment 的取值必须是 \"dev\"、\"test\" 或 \"prod\" 之一。"
  }
}

variable "team_members" {
  type        = set(string)
  description = "团队成员名单。用 set 而不是 list，是因为下面会对它做 for_each —— for_each 要求集合本身元素唯一、且不关心顺序，这正是 set 的语义。"
  default     = ["alice", "bob", "carol"]
}

variable "server_count" {
  type        = number
  description = "演示 count 元参数：要创建多少个「编号服务器」。这里用 count 而不是 for_each，是因为这些服务器本身没有业务身份，只是数量上的重复单元（对比 team_members 用 for_each，因为每个成员有名字、有身份）。"
  default     = 3

  validation {
    condition     = var.server_count >= 1 && var.server_count <= 10
    error_message = "server_count 必须在 1 到 10 之间（教学环境限制数量，避免生成过多文件）。"
  }
}

variable "admin_password" {
  type        = string
  description = "演示 sensitive 变量。这只是教学占位符密码，真实项目中不应该像这样把密码写进 default！"
  default     = "demo-password"

  # sensitive = true 的效果：在 terraform plan / apply 的终端输出中，
  # 这个值会被显示成 (sensitive value)，防止被"不小心看到"或截图泄露。
  # 但请务必阅读 README 里的重要提示：这不代表它不会出现在 State 文件里。
  sensitive = true
}

variable "extra_tags" {
  type        = map(string)
  description = "演示 map 类型和 nullable。这些标签会被合并进每个生成文件的内容里。"
  default     = {}

  # nullable = false：显式禁止调用者传入 null（即使类型允许）。
  # 默认情况下 Terraform 的变量是"nullable = true"，意味着即使你写了
  # default，调用者仍然可以显式传 null 把它"清空"，这可能不是你想要的行为
  # （比如这里如果 extra_tags 被设成 null，后面对它做 for-each 遍历会直接报错）。
  # 设置 nullable = false 后，Terraform 会在 null 被传入时自动退回使用 default。
  nullable = false
}
