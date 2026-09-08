# ============================================================
# main.tf —— 本章的核心资源与数据源
# ------------------------------------------------------------
# 阅读顺序建议：结合 README.md 的"六、Terraform 代码讲解"部分对照阅读，
# 不要只看代码本身——本文件里的每一段注释都在解释"为什么"，
# 而不是重复代码已经说明的"是什么"。
# ============================================================

# --------------------------------------------------------------
# data source：读取一个已经存在、但不由本配置创建的文件。
# 这里的 seed.txt 是本章目录自带的一个普通文本文件（不是 Terraform 生成的）。
# data source 和 resource 最本质的区别：Terraform 不会尝试创建/删除/修改
# 这个文件，它只是"读一下当前内容，供后面的表达式引用"。
# 如果你手工编辑 seed.txt 的内容，下次 terraform plan 会看到 data source
# 读到的值变了，从而影响引用它的下游资源——这也是"data source 参与
# 依赖图"的体现。
# --------------------------------------------------------------
data "local_file" "seed" {
  filename = "${path.module}/seed.txt"
  # path.module 是 Terraform 内置的路径引用，代表"当前这份 .tf 文件
  # 所在的目录"，无论最终执行 terraform 命令时的工作目录是哪里，
  # 这个引用始终指向本模块自身所在的路径——这是编写可移植配置的关键技巧。
}

# --------------------------------------------------------------
# for_each 演示：为 team_members 里的每一个人生成一个专属欢迎文件。
#
# for_each 的取值来源是 locals.tf 里算好的 welcome_messages（一个 map），
# Terraform 会为这个 map 的每一个 key 创建一个资源实例，
# 在 State 里的地址形如 local_file.welcome["alice"]。
#
# 对比下面的 count 版本（server_registry），你会发现：
# 如果将来从 team_members 里删除 "bob"，这里只会精确销毁
# local_file.welcome["bob"] 这一个实例，不会牵连 alice/carol——
# 这正是 docs/02-terraform-fundamentals.md 里解释的
# "for_each 用字符串 key 寻址，比 count 的数字索引更安全"。
# --------------------------------------------------------------
resource "local_file" "welcome" {
  for_each = local.welcome_messages

  filename = "${path.module}/generated/welcome-${each.key}.txt"
  # each.key   —— 当前迭代到的 map key（这里是成员名字，如 "alice"）
  # each.value —— 当前迭代到的 map value（这里是拼好的欢迎语句）
  content = <<-EOT
    ${each.value}
    ---
    附加标签: ${local.tag_summary}
    种子文件内容: ${trimspace(data.local_file.seed.content)}
  EOT

  # lifecycle 元参数块：任何 resource 类型都可以加这个块，
  # 它不影响资源本身的业务参数，只影响 Terraform "如何"执行变更。
  lifecycle {
    # create_before_destroy = true：当这个资源需要被"替换"时
    # （比如 filename 变了，Terraform 判定必须先删后建），
    # 默认顺序是"先销毁旧的，再创建新的"；开启此项后顺序反过来：
    # 先创建新文件，成功后再删除旧文件。
    # 对本地文件来说这只是演示语法；但对于"不能有片刻中断"的资源
    # （比如对外提供服务的容器/负载均衡器），这个顺序的差异至关重要。
    create_before_destroy = true
  }
}

# --------------------------------------------------------------
# count 演示：生成 var.server_count 个"编号服务器"。
#
# 用 random_pet 给每个编号服务器分配一个随机可读的名字（比如 "loyal-puma"），
# random Provider 只是在内存里做随机计算，不连接任何外部系统。
#
# 这里特意用 count 而不是 for_each，因为这些服务器彼此之间没有
# "业务身份"的区别——它们只是"我要 N 份同样规格的东西"，
# count.index（0, 1, 2, ...）恰好能满足"给每份编号"的需求。
# --------------------------------------------------------------
resource "random_pet" "server" {
  count  = var.server_count
  length = 2 # 生成的名字由 2 个单词组成，例如 "quiet-owl"
}

resource "local_file" "server_registry" {
  count = var.server_count

  filename = "${path.module}/generated/server-${count.index}.txt"
  content  = <<-EOT
    server_index = ${count.index}
    server_name  = ${random_pet.server[count.index].id}
    environment  = ${var.environment}
    is_production = ${local.is_production}
  EOT
  # random_pet.server[count.index] —— 用 count.index 精确引用
  # 上面那个 random_pet 资源里"同一个编号"的实例，
  # 这就是隐式依赖的来源：Terraform 看到这里引用了
  # random_pet.server，会自动推断"必须先创建 random_pet.server
  # 才能创建这个 local_file"，无需手写 depends_on。
}

# --------------------------------------------------------------
# 演示一个纯粹靠随机数生成、体现"幂等性边界"的资源：
# random_string 在每次 apply 时只会计算一次并写入 State，
# 之后只要配置不变，重复 apply 不会重新生成新的随机值
# ——这正是"幂等性"在带随机性的资源上的具体体现：
# 幂等性保证的是"配置不变则结果不变"，而不是"每次都重新计算"。
# --------------------------------------------------------------
resource "random_string" "admin_suffix" {
  length  = 4
  special = false
  upper   = false

  lifecycle {
    # prevent_destroy = true 的效果：只要这个 resource block
    # 还留在配置里，任何试图销毁它的操作（包括 terraform destroy）
    # 都会被 Terraform 主动拒绝并报错退出。
    #
    # 这里特意打开它是为了让你在 README 的"常见错误"小节里
    # 亲手触发一次这个报错、理解它的行为；实际执行 terraform destroy
    # 清理本章资源前，需要先把这一行注释掉（README 会提示你何时这样做）。
    prevent_destroy = false
    # 注：默认设为 false（不生效）是为了不影响本章"可以正常 destroy"
    # 的教学目标；动手练习里会引导你临时改成 true 观察效果。
  }
}
