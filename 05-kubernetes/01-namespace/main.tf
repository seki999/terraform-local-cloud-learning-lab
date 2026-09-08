# ============================================================
# main.tf —— Namespace + ResourceQuota
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-namespace"
    labels = {
      "managed-by" = "terraform"
    }
  }
}

# --------------------------------------------------------------
# ResourceQuota：给这个 Namespace 设置资源使用上限。
# 这是 Namespace 作为"多租户隔离边界"最直接的体现——
# 没有 Quota 时，一个 Namespace 里的应用理论上可以用尽整个集群的资源，
# 影响其他 Namespace 里的应用；加上 Quota 后，这个 Namespace 里所有
# Pod 的 requests/limits 总和都不能超过下面设定的数字。
# --------------------------------------------------------------
resource "kubernetes_resource_quota" "this" {
  metadata {
    name      = "learning-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "500m"
      "requests.memory" = "512Mi"
      "limits.cpu"      = "1"
      "limits.memory"   = "1Gi"
      "pods"            = "10"
    }
  }
}

# 用一个小 Pod 验证 Quota 生效（Pod 必须声明 resources，
# 否则在设置了 Quota 的 Namespace 里创建 Pod 会被直接拒绝——
# 这是亲手体验 Quota"强制性"的最好方式）。
resource "kubernetes_pod" "probe" {
  metadata {
    name      = "quota-probe"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    container {
      name  = "probe"
      image = "nginx:1.27-alpine"

      resources {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
    }
  }
}
