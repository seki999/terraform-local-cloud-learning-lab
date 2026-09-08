# ============================================================
# k8s-app.tf —— Kind 集群里的应用层：frontend / backend / redis / postgres
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name
  }
}

# --------------------------------------------------------------
# 把从 Vault 读出来的密码，写进 Kubernetes Secret——
# 这是本章"统一编排"最关键的一条连接线：Vault 是密码的
# 事实来源，Kubernetes Secret 只是它在这个应用里的具体消费形式。
# --------------------------------------------------------------
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    username = data.vault_kv_secret_v2.db_credentials.data["username"]
    password = data.vault_kv_secret_v2.db_credentials.data["password"]
  }
}

resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "redis" }
    }
    template {
      metadata {
        labels = { app = "redis" }
      }
      spec {
        container {
          name  = "redis"
          image = "redis:7-alpine"
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "redis" }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_data" {
  metadata {
    name      = "postgres-data"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "500Mi" }
    }
  }
  # 注意：Kind 默认 StorageClass 是 WaitForFirstConsumer 模式，
  # 这里必须是 false——完整原因见
  # 05-kubernetes/06-pvc/README.md 里记录的真实踩坑过程。
  wait_until_bound = false
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "postgres" }
    }
    template {
      metadata {
        labels = { app = "postgres" }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          env {
            name  = "POSTGRES_DB"
            value = "app_db"
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "pgdata"
            # sub_path：避免 postgres 在卷的根目录发现 "lost+found"
            # 之类的既有内容而拒绝启动——把数据实际写进卷内的一个
            # 子目录，这是本地 hostPath/local-path 存储上运行
            # PostgreSQL 时的一个常见实践技巧。
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# --------------------------------------------------------------
# backend：只是一个 http-echo，模拟"真正会去连 redis/postgres 的
# 应用后端"——本章重点是编排关系本身，不是实现一个真实业务逻辑。
# --------------------------------------------------------------
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "backend" }
    }
    template {
      metadata {
        labels = { app = "backend" }
      }
      spec {
        container {
          name  = "backend"
          image = "hashicorp/http-echo:latest"

          # 重要：这里必须用 args，不能用 command！
          # 这是本项目实测踩过的坑，和 02-docker 章节的 Docker
          # Provider 用法很容易混淆：
          #   - Kubernetes 的 `command` 字段会**覆盖镜像的 ENTRYPOINT**
          #     （相当于 docker run --entrypoint）；
          #   - Kubernetes 的 `args` 字段才是**追加在 ENTRYPOINT 后面
          #     的参数**（相当于 Docker 的 CMD）。
          # http-echo 镜像的 ENTRYPOINT 就是它自己的可执行文件，
          # 这里的 "-listen=:5678" 等应该作为参数追加，而不是替换掉
          # ENTRYPOINT——写成 command 会导致容器尝试把
          # "-listen=:5678" 当成可执行文件来运行，直接报
          # "executable file not found in $PATH" 并 CrashLoopBackOff。
          args = ["-listen=:5678", "-text=backend ok: redis+postgres+vault-secret all wired up"]

          port {
            container_port = 5678
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "backend" }
    port {
      port        = 80
      target_port = 5678
    }
  }
}

# --------------------------------------------------------------
# frontend：nginx 反向代理到 backend，对外用 NodePort 暴露
# （Kind 集群没有云负载均衡器，NodePort 是最简单的本地验证方式）。
# --------------------------------------------------------------
resource "kubernetes_config_map" "frontend_conf" {
  metadata {
    name      = "frontend-conf"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  data = {
    "default.conf" = <<-EOT
      server {
        listen 80;
        location / {
          proxy_pass http://backend:80;
        }
      }
    EOT
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = var.frontend_replicas
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        labels = { app = "frontend" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "conf"
            mount_path = "/etc/nginx/conf.d"
          }
        }
        volume {
          name = "conf"
          config_map {
            name = kubernetes_config_map.frontend_conf.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "frontend" }
    type     = "NodePort"
    port {
      port        = 80
      target_port = 80
      node_port   = 30100
    }
  }
}
