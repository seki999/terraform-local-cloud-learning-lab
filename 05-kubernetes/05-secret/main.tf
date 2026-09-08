# ============================================================
# main.tf —— Secret：env / volume 消费 + State 明文陷阱
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-secret"
  }
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    username = "app_user"
    password = var.db_password
  }

  type = "Opaque"
}

resource "kubernetes_pod" "demo" {
  metadata {
    name      = "secret-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    container {
      name  = "demo"
      image = "nginx:1.27-alpine"

      env {
        name = "DB_PASSWORD"
        value_from {
          secret_key_ref {
            name = kubernetes_secret.db_credentials.metadata[0].name
            key  = "password"
          }
        }
      }

      volume_mount {
        name       = "secret-volume"
        mount_path = "/etc/secret"
        read_only  = true
      }
    }

    volume {
      name = "secret-volume"
      secret {
        secret_name = kubernetes_secret.db_credentials.metadata[0].name
      }
    }
  }
}
