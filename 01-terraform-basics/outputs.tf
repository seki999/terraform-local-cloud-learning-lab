# ============================================================
# outputs.tf —— 把内部结果暴露给命令行 / 上层模块
# ------------------------------------------------------------
# output 块声明的值可以用 `terraform output` 查看，
# 也是子模块把内部资源属性"暴露"给调用它的 root module 的唯一方式
# （04-terraform-modules.md 会详细展开这一点）。
# ============================================================

output "workspace_label" {
  description = "当前 environment + Workspace 的组合标签"
  value       = local.workspace_label
}

output "welcome_files" {
  description = "为每个团队成员生成的欢迎文件路径（key 是成员名字）"
  value       = { for k, v in local_file.welcome : k => v.filename }
}

output "server_names" {
  description = "所有编号服务器分配到的随机名字（按 count.index 顺序排列）"
  value       = [for p in random_pet.server : p.id]
}

output "admin_username" {
  description = "演示：非敏感 output 可以正常在终端打印"
  value       = "admin-${random_string.admin_suffix.result}"
}

output "admin_password" {
  description = "演示 sensitive output：终端会显示 (sensitive value) 而不是明文"
  value       = var.admin_password
  sensitive   = true
  # 重要：sensitive = true 只影响 CLI 展示，不影响 State 文件里的存储方式。
  # 请阅读 README「九、Terraform State 变化」小节，里面有一个命令
  # 会直接从 terraform.tfstate 里把这个"敏感"密码用明文读出来，
  # 用来验证这个结论——请不要跳过这个实验。
}

output "is_production" {
  description = "演示条件表达式计算结果的 output"
  value       = local.is_production
}

output "short_team_member_names" {
  description = "演示 for 表达式 + if 过滤：长度不超过 4 的成员名字"
  value       = local.short_names
}
