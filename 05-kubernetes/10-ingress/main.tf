# ============================================================
# main.tf —— Ingress：多路径路由到不同 Service
# ------------------------------------------------------------
# 前置条件：ingress-nginx Controller 已安装
# （运行 scripts/install-ingress-nginx.ps1）。
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-ingress"
  }
}

# 两个独立的后端应用，用不同的返回文本区分
resource "kubernetes_deployment" "app_a" {
  metadata {
    name      = "app-a"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "app-a" }
    }
    template {
      metadata {
        labels = { app = "app-a" }
      }
      spec {
        container {
          name    = "http-echo"
          image   = "hashicorp/http-echo:latest"
          args    = ["-listen=:5678", "-text=response from app-a"]
          port {
            container_port = 5678
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "app_b" {
  metadata {
    name      = "app-b"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "app-b" }
    }
    template {
      metadata {
        labels = { app = "app-b" }
      }
      spec {
        container {
          name    = "http-echo"
          image   = "hashicorp/http-echo:latest"
          args    = ["-listen=:5678", "-text=response from app-b"]
          port {
            container_port = 5678
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_a" {
  metadata {
    name      = "app-a"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "app-a" }
    port {
      port        = 80
      target_port = 5678
    }
  }
}

resource "kubernetes_service" "app_b" {
  metadata {
    name      = "app-b"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "app-b" }
    port {
      port        = 80
      target_port = 5678
    }
  }
}

# --------------------------------------------------------------
# 一个 Ingress 资源，两条基于路径前缀的路由规则：
#   /app-a  -> Service app-a
#   /app-b  -> Service app-b
# 这演示了 Ingress 相比 NodePort/单个 Service 的核心价值：
# **一个入口、一个公网 IP/端口，就能路由到任意多个后端服务**，
# 不需要为每个服务单独暴露端口。
# --------------------------------------------------------------
resource "kubernetes_ingress_v1" "multi_path" {
  metadata {
    name      = "multi-path"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/app-a"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app_a.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/app-b"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app_b.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
