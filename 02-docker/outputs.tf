# ============================================================
# outputs.tf
# ============================================================

output "network_name" {
  description = "本章创建的 user-defined 网络名称"
  value       = docker_network.app_network.name
}

output "default_bridge_driver" {
  description = "演示 data source：查询到的默认 bridge 网络的驱动类型"
  value       = data.docker_network.default_bridge.driver
}

output "postgres_volume_name" {
  description = "PostgreSQL 数据卷名称"
  value       = docker_volume.postgres_data.name
}

output "nginx_url" {
  description = "浏览器访问入口（对应 nginx_port_mappings 里的第一个 external 端口）"
  value       = "http://localhost:${var.nginx_port_mappings[0].external}"
}

output "nginx_health_url" {
  description = "nginx 自身健康检查端点"
  value       = "http://localhost:${var.nginx_port_mappings[0].external}/nginx-health"
}

output "container_ids" {
  description = "四个容器的 Docker 内部 ID，方便和 `docker ps` 的输出对照"
  value = {
    nginx    = docker_container.nginx.id
    webapp   = docker_container.webapp.id
    redis    = docker_container.redis.id
    postgres = docker_container.postgres.id
  }
}
