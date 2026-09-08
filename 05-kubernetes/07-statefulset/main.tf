# ============================================================
# main.tf —— StatefulSet：有序编号 Pod 与稳定网络标识
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-statefulset"
  }
}

# --------------------------------------------------------------
# StatefulSet 依赖一个 Headless Service 才能生效——
# 每个 Pod 的稳定 DNS 名字（web-0.web-headless.<ns>.svc.cluster.local）
# 正是通过这个 Headless Service 提供的。
# 详见 03-service 章节对 Headless Service 的讲解。
# --------------------------------------------------------------
resource "kubernetes_service" "headless" {
  metadata {
    name      = "web-headless"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector   = { app = "web-sts" }
    cluster_ip = "None"
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_stateful_set" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    service_name = kubernetes_service.headless.metadata[0].name
    replicas     = 3

    selector {
      match_labels = { app = "web-sts" }
    }

    template {
      metadata {
        labels = { app = "web-sts" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "data"
            mount_path = "/usr/share/nginx/html"
          }
        }
      }
    }

    # --------------------------------------------------------------
    # volume_claim_template：StatefulSet 特有的机制——
    # 不是共享一个 PVC，而是**为每一个副本自动创建一个独立的 PVC**
    # （命名规则是 <volumeClaimTemplate名>-<StatefulSet名>-<序号>，
    # 比如 data-web-0、data-web-1、data-web-2）。
    # 这就是为什么 StatefulSet 适合"每个副本都需要自己独立持久化数据"
    # 的场景（比如数据库集群的每个节点），而普通 Deployment + 单个 PVC
    # 做不到这一点（多个 Pod 同时挂载同一个 ReadWriteOnce PVC 会冲突）。
    # --------------------------------------------------------------
    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "200Mi"
          }
        }
      }
    }
  }
}
