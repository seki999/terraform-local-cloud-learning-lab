# ============================================================
# locals.tf —— 模块内部的"计算中间量"
# ------------------------------------------------------------
# locals 和 variables 的核心区别：
#   variable 是"外部输入"——调用者（命令行/tfvars/上层 module）可以赋值；
#   locals   是"内部计算结果"——只能在本模块内部由表达式算出来，
#            外部无法覆盖，也不会出现在 terraform plan 的"输入变量"提示里。
# 把重复用到的表达式、拼接逻辑抽成 locals，可以避免在多个 resource 里
# 重复写同一段逻辑，也让 resource 定义本身更易读。
# ============================================================

locals {
  # 字符串插值：${...} 语法把表达式的值嵌入字符串。
  # terraform.workspace 是一个内置引用，返回当前所在的 Workspace 名称
  # （未显式创建/切换过 Workspace 时，默认是 "default"）。
  workspace_label = "${var.environment}-${terraform.workspace}"

  # for 表达式（生成 map）：把 set(string) 转成 map(string)。
  # 语法：{ for <item> in <集合> : <key表达式> => <value表达式> }
  # 这里用每个成员的名字作为 key，生成一句欢迎语作为 value。
  welcome_messages = {
    for name in var.team_members :
    name => "Welcome, ${name}! Environment: ${var.environment} (workspace: ${terraform.workspace})"
  }

  # 条件表达式（三元运算符）：condition ? true_val : false_val
  # 用来演示"根据变量值分支计算"，不需要写 if/else 语句。
  is_production = var.environment == "prod"

  # for 表达式（带 if 过滤，生成 list）：只保留长度 <= 4 的名字。
  short_names = [for name in var.team_members : name if length(name) <= 4]

  # for 表达式：把 map(string) 类型的 extra_tags 转换成
  # "key=value" 格式的字符串列表，方便拼接进文件内容。
  tag_lines = [for k, v in var.extra_tags : "${k}=${v}"]

  # join() 把上面的 list 拼接成一行文本；如果 extra_tags 是空 map，
  # tag_lines 是空 list，join 的结果就是空字符串——这里演示了
  # locals 之间可以互相引用、层层组合计算。
  tag_summary = length(local.tag_lines) > 0 ? join(", ", local.tag_lines) : "(no tags)"
}
