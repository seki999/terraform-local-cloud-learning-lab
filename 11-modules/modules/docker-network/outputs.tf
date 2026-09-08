# ============================================================
# modules/docker-network/outputs.tf —— 这个 module 对外暴露什么
# ------------------------------------------------------------
# 只有写在这里的属性，调用方才能通过 module.<名字>.<output名>
# 引用到——这是 module 封装边界的具体体现。
# ============================================================

output "network_name" {
  description = "供其他资源的 networks_advanced.name 引用"
  value       = docker_network.this.name
}

output "network_id" {
  value = docker_network.this.id
}
