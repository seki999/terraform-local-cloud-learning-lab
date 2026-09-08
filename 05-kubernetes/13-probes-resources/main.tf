# ============================================================
# main.tf —— Resource Request/Limit 与三种 Probe，QoS 等级演示
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-probes"
  }
}

# --------------------------------------------------------------
# QoS 等级一：Guaranteed —— requests 和 limits 完全相等
# （且每个容器都必须同时设置 cpu 和 memory 的 requests/limits）。
# 这是三个等级里最"安全"的一档：节点资源紧张、需要驱逐 Pod 时，
# kubelet 最后才会考虑驱逐 Guaranteed 等级的 Pod。
# --------------------------------------------------------------
resource "kubernetes_pod" "guaranteed" {
  metadata {
    name      = "qos-guaranteed"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    container {
      name  = "app"
      image = "nginx:1.27-alpine"
      resources {
        requests = { cpu = "100m", memory = "64Mi" }
        limits   = { cpu = "100m", memory = "64Mi" }
      }
    }
  }
}

# --------------------------------------------------------------
# QoS 等级二：Burstable —— 设置了 requests，但 limits 更高
# （或只设置了部分资源类型的 requests/limits）。
# 平时只占用 requests 的资源量，允许"突发"用到 limits 上限。
# --------------------------------------------------------------
resource "kubernetes_pod" "burstable" {
  metadata {
    name      = "qos-burstable"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    container {
      name  = "app"
      image = "nginx:1.27-alpine"
      resources {
        requests = { cpu = "50m", memory = "32Mi" }
        limits   = { cpu = "200m", memory = "128Mi" }
      }
    }
  }
}

# --------------------------------------------------------------
# QoS 等级三：BestEffort —— 完全不设置任何 requests/limits。
# 节点资源紧张时，这类 Pod 最先被驱逐——生产环境应避免让重要应用
# 处于这个等级（本项目前面章节的所有正式资源都刻意设置了
# requests/limits，只有这里为了演示对比才故意留空）。
# --------------------------------------------------------------
resource "kubernetes_pod" "besteffort" {
  metadata {
    name      = "qos-besteffort"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    container {
      name  = "app"
      image = "nginx:1.27-alpine"
      # 故意不写 resources block
    }
  }
}

# --------------------------------------------------------------
# 三种 Probe 综合演示：
#   startup_probe   —— 只在容器刚启动时生效，成功一次后就不再检查；
#                       在它成功之前，liveness/readiness 完全不会被执行。
#                       用于"启动特别慢"的应用，避免启动阶段被
#                       liveness probe 误杀。
#   liveness_probe  —— 持续检查，失败达到阈值则重启容器。
#   readiness_probe —— 持续检查，失败则把 Pod 从 Service 端点摘除
#                       （不重启容器）。
# --------------------------------------------------------------
resource "kubernetes_pod" "probes_demo" {
  metadata {
    name      = "probes-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    container {
      name  = "app"
      image = "nginx:1.27-alpine"

      resources {
        requests = { cpu = "50m", memory = "32Mi" }
        limits   = { cpu = "100m", memory = "64Mi" }
      }

      startup_probe {
        http_get {
          path = "/"
          port = 80
        }
        # failure_threshold * period_seconds = 给应用的最长启动等待时间。
        # 这里是 30 * 2 = 60 秒——如果 60 秒内都没有一次成功探测，
        # kubelet 才会判定启动失败并重启容器。
        failure_threshold = 30
        period_seconds     = 2
      }

      liveness_probe {
        http_get {
          path = "/"
          port = 80
        }
        period_seconds    = 10
        failure_threshold = 3
      }

      readiness_probe {
        http_get {
          path = "/"
          port = 80
        }
        period_seconds    = 5
        failure_threshold = 1
      }
    }
  }
}
