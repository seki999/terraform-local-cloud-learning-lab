# ============================================================
# modules/docker-service/main.tf
# ------------------------------------------------------------
# 把"拉镜像 + 跑容器 + 加入网络"这一组合行为封装成一个 module，
# 对比 02-docker 章节手写的分散资源，调用方现在只需要传几个
# 关键参数（名字、镜像、网络、端口），不需要重复关心
# docker_image 和 docker_container 之间该怎么互相引用。
# ============================================================

resource "docker_image" "this" {
  name         = var.image
  keep_locally = var.keep_image_locally
}

resource "docker_container" "this" {
  name    = var.service_name
  image   = docker_image.this.image_id
  command = var.command
  env     = var.env

  dynamic "ports" {
    for_each = var.port_mappings
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  networks_advanced {
    name = var.network_name
  }
}
