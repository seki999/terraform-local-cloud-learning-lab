# ============================================================
# modules/kubernetes-app/main.tf
# ------------------------------------------------------------
# 把"Deployment + Service"这个几乎每个应用都要重复一遍的组合
# 封装成一个 module。注意这个 module 故意不创建 Namespace——
# Namespace 的生命周期通常比单个应用更"高层"（多个应用可能共享
# 同一个 Namespace），由调用方负责创建、把名字传进来，
# 这是一个关于"module 的边界应该划在哪里"的设计决策示范。
# ============================================================

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels    = { app = var.app_name }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = var.app_name }
    }

    template {
      metadata {
        labels = { app = var.app_name }
      }
      spec {
        container {
          name  = var.app_name
          image = var.image
          port {
            container_port = var.container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }
  spec {
    selector = { app = var.app_name }
    port {
      port        = 80
      target_port = var.container_port
    }
  }
}
