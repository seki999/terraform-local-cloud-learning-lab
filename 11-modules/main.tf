# ============================================================
# main.tf —— root module：组合调用四个 child module
# ============================================================

# --------------------------------------------------------------
# 一、docker-network module：只调用一次，作为下面两个
# docker-service module 实例共享的网络。
# --------------------------------------------------------------
module "network" {
  source = "./modules/docker-network"
  name   = "learning-modules-network"
}

# --------------------------------------------------------------
# 二、docker-service module：调用两次，使用完全相同的 module 代码，
# 只是传入不同的参数——这就是"module 组合与复用"最直接的体现。
# 对比 02-docker 章节手写的分散资源定义，这里增加第三个服务
# 只需要再调用一次 module，不需要重复编写 docker_image +
# docker_container 的完整定义。
# --------------------------------------------------------------
module "web" {
  source = "./modules/docker-service"

  service_name = "modules-demo-web"
  image        = "nginx:1.27-alpine"
  network_name = module.network.network_name
  # ^ 引用上面 module "network" 的 output——这是 module 之间依赖/
  # 组合（Composition）的标准写法，Terraform 会自动推断出
  # "web 这个 module 依赖 network 这个 module"。

  port_mappings = [
    { internal = 80, external = 8090 }
  ]
}

module "api" {
  source = "./modules/docker-service"

  service_name = "modules-demo-api"
  image        = "hashicorp/http-echo:latest"
  network_name = module.network.network_name
  command      = ["-listen=:5678", "-text=hello from the api module instance"]
  # 注意这里完全没有配置 port_mappings（默认空列表）——
  # 这个"服务"只在 learning-modules-network 内部可见，
  # 演示同一个 module 也能优雅地表达"不对外暴露端口"这种场景。
}

# --------------------------------------------------------------
# 三、kubernetes-app module：Namespace 由 root module 直接创建
# （前面 modules/kubernetes-app/main.tf 里解释过这个边界划分的理由）。
# --------------------------------------------------------------
resource "kubernetes_namespace" "modules_demo" {
  metadata {
    name = var.namespace_name
  }
}

module "k8s_frontend" {
  source = "./modules/kubernetes-app"

  app_name       = "frontend"
  namespace      = kubernetes_namespace.modules_demo.metadata[0].name
  image          = "nginx:1.27-alpine"
  replicas       = 2
  container_port = 80
}

# --------------------------------------------------------------
# 四、monitoring module：默认关闭（见 variables.tf 里
# enable_monitoring_module 的说明），避免本章的基础演示强制依赖
# 06-helm/08-monitoring 这两个更重的前置章节。
# --------------------------------------------------------------
module "dashboard" {
  count  = var.enable_monitoring_module ? 1 : 0
  source = "./modules/monitoring"

  folder_title = "Modules Chapter Demo"

  dashboard_json = jsonencode({
    title         = "Modules Chapter - Hello Dashboard"
    uid           = "learning-modules-hello"
    schemaVersion = 39
    panels = [
      {
        id      = 1
        type    = "text"
        title   = "Hello from a Terraform Module"
        gridPos = { h = 8, w = 24, x = 0, y = 0 }
        options = {
          mode    = "markdown"
          content = "这个 Dashboard 是由 `modules/monitoring` 这个 module 创建的，证明 Grafana 配置同样可以被封装成可复用 module。"
        }
      }
    ]
  })
}
