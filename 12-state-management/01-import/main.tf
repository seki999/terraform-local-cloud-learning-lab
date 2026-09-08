# ============================================================
# main.tf —— import 实验：把一个手工创建的容器纳入 Terraform 管理
# ------------------------------------------------------------
# 这份资源定义描述的是"我们希望 Terraform 认领的那个手工创建的
# 容器，长什么样子"。在执行 `terraform import` 之前，这只是一份
# 普通的配置，Terraform State 里完全没有它的记录；import 之后，
# Terraform 会把 State 里这个地址和真实存在的容器关联起来。
# ============================================================

resource "docker_container" "manual_nginx" {
  name  = "manually-created-nginx"
  image = "nginx:1.27-alpine"
  env   = []

  # 注意这里是两个 ports block，而不是一个！
  # 这是本项目实测在 import 后反复调整才发现的细节：Docker Desktop
  # 在你只写 `-p 8099:80`（没有指定绑定哪个宿主机 IP）时，实际会
  # 同时在 IPv4 的 0.0.0.0 和 IPv6 的 :: 上各发布一份端口映射
  # （用 `docker inspect manually-created-nginx --format
  # '{{json .NetworkSettings.Ports}}'` 能直接看到两条记录）。
  # 如果只写一个不带 ip 的 ports block，`terraform plan` 会显示
  # 要销毁重建整个容器——因为 Terraform 发现"真实状态有两条端口
  # 记录，配置里只描述了一条，对不上"。这正是 import 工作流里
  # "反复调整配置直到 plan 显示 No changes"这一步要处理的典型情况。
  ports {
    internal = 80
    external = 8099
    ip       = "0.0.0.0"
  }
  ports {
    internal = 80
    external = 8099
    ip       = "::"
  }
}
