# ============================================================
# main.tf —— ConfigMap 的两种消费方式：env vs 文件挂载
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-configmap"
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    # 这几个 key 会被当作环境变量整体注入（envFrom）
    LOG_LEVEL = "debug"
    APP_NAME  = "configmap-demo"

    # 这个 key 会被当作一个文件挂载进容器
    "app.conf" = <<-EOT
      # 这是一份被挂载进容器 /etc/app/app.conf 的配置文件
      log_level = debug
      app_name = configmap-demo
    EOT
  }
}

resource "kubernetes_pod" "demo" {
  metadata {
    name      = "configmap-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    container {
      name  = "demo"
      image = "nginx:1.27-alpine"

      # --------------------------------------------------------------
      # 消费方式一：envFrom —— 把 ConfigMap 里"所有 key"整体转成环境变量。
      # 好处是简单；缺点是 ConfigMap 里任何 key 的增删都会隐式影响
      # 容器的环境变量列表，不够精确可控。
      # --------------------------------------------------------------
      env_from {
        config_map_ref {
          name = kubernetes_config_map.app_config.metadata[0].name
        }
      }

      # --------------------------------------------------------------
      # 消费方式二：volume 挂载 —— 把 ConfigMap 里的 key 当作文件名，
      # value 当作文件内容，挂载成一个目录。
      # 好处是应用可以用"读配置文件"的传统方式读取配置，无需改造成
      # "读环境变量"；且 ConfigMap 更新后（本 Pod 场景下需要重建 Pod
      # 才会生效，但如果是 Deployment 管理的 Pod，kubelet 会在几十秒内
      # 自动同步挂载文件内容，无需重启容器——这是两种方式的另一个差异：
      # 文件内容支持"热更新"，而 env 环境变量只在容器启动那一刻确定，
      # 之后 ConfigMap 再怎么改，已经在运行的容器也看不到新值）。
      # --------------------------------------------------------------
      volume_mount {
        name       = "config-volume"
        mount_path = "/etc/app"
        read_only  = true
      }
    }

    volume {
      name = "config-volume"
      config_map {
        name = kubernetes_config_map.app_config.metadata[0].name
        items {
          key  = "app.conf"
          path = "app.conf"
        }
      }
    }
  }
}
