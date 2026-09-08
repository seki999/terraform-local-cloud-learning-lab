# ============================================================
# main.tf —— Deployment 滚动升级策略
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-deployment"
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    replicas = 3

    # --------------------------------------------------------------
    # strategy block：控制"旧版本 Pod 换成新版本 Pod"的具体节奏。
    # max_surge：滚动升级过程中，允许比 replicas 多出多少个 Pod
    #            （先多拉起新版本，再关旧版本，让总量短暂超过 replicas）；
    # max_unavailable：滚动升级过程中，允许比 replicas 少多少个可用 Pod
    #                  （0 表示"任何时刻都不能少于期望副本数"，
    #                  即必须先拉起新 Pod 并就绪后才能关一个旧 Pod）。
    # --------------------------------------------------------------
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = { app = "web" }
    }

    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:${var.nginx_version}"

          port {
            container_port = 80
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 1
            period_seconds        = 3
          }
        }
      }
    }
  }
}
