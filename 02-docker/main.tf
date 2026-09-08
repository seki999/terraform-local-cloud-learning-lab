# ============================================================
# main.tf —— Terraform 管理 Docker 网络 / 镜像 / 容器 / 卷
# ------------------------------------------------------------
# 架构（详见 README 的架构图）：
#
#   docker_network.app_network
#          │
#          ├── docker_container.postgres  (数据持久化, docker_volume)
#          ├── docker_container.redis     (无状态缓存, 仅供内部访问)
#          ├── docker_container.webapp    (示例应用, 对外通过 nginx 暴露)
#          └── docker_container.nginx     (反向代理, 唯一对外暴露端口的容器)
#
# 依赖顺序: network → (postgres, redis, webapp 并行) → nginx
# ============================================================

# --------------------------------------------------------------
# data source：只读查询 Docker 自带的默认 bridge 网络。
# 对比下面我们自己创建的 app_network——默认 bridge 网络不支持
# 基于容器名的 DNS 服务发现，这也是为什么真实项目几乎总是自己创建
# 一个 user-defined 网络，而不是把容器都扔进默认 bridge 网络里。
# --------------------------------------------------------------
data "docker_network" "default_bridge" {
  name = "bridge"
}

# --------------------------------------------------------------
# 创建一个 user-defined bridge 网络。
# 之后连进这个网络的容器，可以直接用"容器名"当作主机名互相访问
# （比如 nginx 配置里的 proxy_pass http://webapp:5678 ——
# "webapp" 就是下面 docker_container.webapp 的 name），
# 完全不需要关心对方的真实 IP，这是 Docker 内置 DNS 提供的能力。
# 这和 Kubernetes Service 靠 DNS 名字找 Pod 是同一个思路的简化版
# （对照 docs/06-kubernetes-basics.md 第 6 节）。
# --------------------------------------------------------------
resource "docker_network" "app_network" {
  name = "terraform-learning-network"
}

# --------------------------------------------------------------
# 独立的具名卷，用来持久化 PostgreSQL 的数据目录。
# 如果不用具名卷、只用容器内部的匿名存储，容器一旦被销毁重建
# （比如镜像升级触发的替换），数据会随之丢失——这正是
# "容器应该是无状态、可随时替换的"这个理念下，
# 有状态数据必须被"移出容器生命周期"的原因。
# --------------------------------------------------------------
resource "docker_volume" "postgres_data" {
  name = "terraform-learning-postgres-data"
}

# --------------------------------------------------------------
# docker_image 资源：负责"确保某个镜像已经被拉取到本地"。
# 这是一个和 docker_container 分离的独立资源，原因是：
# 镜像拉取（下载）和容器运行（生命周期管理）是两件不同的事情，
# 拆开之后 Terraform 可以精确判断"镜像变了要不要重新拉取"，
# 而不用每次都和容器创建逻辑耦合在一起。
#
# keep_locally 参数：默认情况下 terraform destroy 时，Provider 会
# 尝试把它拉取过的镜像也一并删除；设为 true 后，
# destroy 只清理 Terraform 创建的容器/网络/卷，镜像继续留在本地，
# 下次重新 apply 就不用重新下载，对反复练习的学习场景很友好。
# --------------------------------------------------------------
resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = var.keep_images_locally
}

resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = var.keep_images_locally
}

resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = var.keep_images_locally
}

resource "docker_image" "webapp" {
  # hashicorp/http-echo 是一个几 MB 的极简 HTTP 服务器，
  # 启动后对任何请求都返回一段固定文本，很适合用来演示
  # "有一个 Web App 容器"而不需要自己写代码构建镜像。
  name         = "hashicorp/http-echo:latest"
  keep_locally = var.keep_images_locally
}

# --------------------------------------------------------------
# templatefile() 函数：读取一个模板文件，用给定的变量渲染成最终文本。
# 这里渲染出 nginx 的反向代理配置，upstream_host 硬编码指向
# webapp 容器的 Docker DNS 名字 + 端口。
# --------------------------------------------------------------
locals {
  nginx_conf_rendered = templatefile("${path.module}/templates/nginx.conf.tftpl", {
    upstream_host = "webapp:5678"
    environment   = var.environment
  })
}

# --------------------------------------------------------------
# PostgreSQL 容器：演示 volumes 挂载、环境变量、内部专用（不发布端口）。
# --------------------------------------------------------------
resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres.image_id
  # docker_image.postgres.image_id 是 docker_image 资源的计算属性
  # （拉取完成后由 Docker daemon 返回的镜像 ID）。
  # 这里引用它而不是直接写字符串 "postgres:16-alpine"，
  # 是为了让 Terraform 建立"容器依赖镜像"的隐式依赖——
  # 保证先拉镜像、再创建容器，且镜像变化时容器会被感知到。

  restart = var.restart_policy

  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    # 敏感信息通过 env 传入容器——这是最基础的做法，
    # 09-vault 章节会展示更安全的替代方案（运行时从 Vault 读取，
    # 而不是像这里一样明文出现在 Terraform 配置/State 里）。
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.app_network.name
    # 容器加入这个网络后，其他同网络容器可以用 "postgres" 这个
    # 容器名当主机名连接它（比如 webapp 若要连数据库，
    # 连接串写 host=postgres 即可，不需要写死 IP）。
  }
}

# --------------------------------------------------------------
# Redis 容器：无状态缓存服务，同样只在内部网络可见，不对外发布端口。
# --------------------------------------------------------------
resource "docker_container" "redis" {
  name    = "redis"
  image   = docker_image.redis.image_id
  restart = var.restart_policy

  networks_advanced {
    name = docker_network.app_network.name
  }
}

# --------------------------------------------------------------
# Web App 容器：演示 command（覆盖镜像默认启动命令）和 env。
# --------------------------------------------------------------
resource "docker_container" "webapp" {
  name    = "webapp"
  image   = docker_image.webapp.image_id
  restart = var.restart_policy

  command = [
    "-listen=:5678",
    "-text=Hello from Terraform-managed Docker Lab! environment=${var.environment}",
  ]

  env = [
    "APP_ENV=${var.environment}",
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }
}

# --------------------------------------------------------------
# nginx 容器：唯一对外暴露端口的容器，反向代理到 webapp。
#
# dynamic "ports" block：ports 是 docker_container 资源内部的
# 嵌套 block（不是顶层 resource），当端口映射数量需要由变量
# （var.nginx_port_mappings，一个 list(object)）动态决定时，
# 用 dynamic 循环生成任意数量的 ports 子块，
# 等价于对列表里每一项手写一个 ports { ... }。
# --------------------------------------------------------------
resource "docker_container" "nginx" {
  name    = "nginx"
  image   = docker_image.nginx.image_id
  restart = var.restart_policy

  dynamic "ports" {
    for_each = var.nginx_port_mappings
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }
  # 上面这段等价于（当 var.nginx_port_mappings 只有默认这一项时）：
  #   ports {
  #     internal = 80
  #     external = 8080
  #   }
  # 但用 dynamic 写法后，只需要修改 variables.tf 里的默认值 / tfvars，
  # 不需要改动这段资源代码本身就能增删端口映射。

  upload {
    file    = "/etc/nginx/conf.d/default.conf"
    content = local.nginx_conf_rendered
    # upload block 把渲染好的文本内容直接写入容器内的指定路径，
    # 效果类似 `docker cp`，但作为容器创建的一部分声明式完成。
    # 好处是不需要在 Windows 宿主机上维护一个供 bind mount 的目录，
    # 避免了 Windows/WSL2 路径转换的额外复杂度。
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  # --------------------------------------------------------------
  # 显式依赖：nginx 的配置文件里用字符串 "webapp:5678" 引用了
  # webapp 容器，但这只是一段普通文本（模板渲染的产物），
  # Terraform 无法从字符串内容里"看出"这是一个资源引用，
  # 所以不会自动推断依赖关系。如果不加 depends_on，
  # Terraform 有可能先启动 nginx、后启动 webapp，
  # 短暂时间内 nginx 反代会失败（虽然 nginx 重启策略最终能恢复，
  # 但这不是我们想要的确定性行为）。
  # 这里用 depends_on 显式声明："必须先有 webapp 容器，才创建 nginx"。
  # --------------------------------------------------------------
  depends_on = [docker_container.webapp]
}
