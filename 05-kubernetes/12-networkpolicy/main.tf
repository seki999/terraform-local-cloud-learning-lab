# ============================================================
# main.tf —— NetworkPolicy：默认全通 vs 显式白名单隔离
# ------------------------------------------------------------
# 重要提示：请先阅读 README「⚠️ 关于 CNI 支持」一节。
# Kind 集群默认使用的 kindnet CNI **不支持**真正强制执行
# NetworkPolicy——本实验的资源依然可以被 Terraform 正常创建，
# 但不会产生实际的网络隔离效果，除非你按 README 里的进阶挑战
# 换用支持 NetworkPolicy 的 CNI（如 Calico）。
# 这里依然完整实现它，是因为：
#   1. 学习 NetworkPolicy 的 API/字段结构本身是有价值的；
#   2. 这个限制本身就是一个重要的、容易被忽视的真实知识点。
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-networkpolicy"
    labels = {
      purpose = "networkpolicy-demo"
    }
  }
}

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
          name  = "nginx"
          image = "nginx:1.27-alpine"
          port {
            container_port = 80
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
      target_port = 80
    }
  }
}

# --------------------------------------------------------------
# 第一步：默认拒绝所有入站流量。
# 一个"选中所有 Pod、但不声明任何 ingress 规则"的 NetworkPolicy，
# 等价于"这个 Namespace 里默认没有任何东西能主动连进来"。
# Kubernetes 的 NetworkPolicy 语义是"白名单"式的：
# 一旦有任何 NetworkPolicy 选中了某个 Pod，这个 Pod 就从
# "默认全通"变成"默认全拒，只允许被显式允许的流量"。
# --------------------------------------------------------------
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    pod_selector {} # 空的 pod_selector = 选中这个 Namespace 里的所有 Pod

    policy_types = ["Ingress"]
    # 只声明了 policy_types 但不写任何 ingress block，
    # 等价于"允许的入站规则集合是空集"——即默认拒绝所有入站流量。
  }
}

# --------------------------------------------------------------
# 第二步：只允许带有 role=allowed-client 标签的 Pod 访问 backend。
# 这是"默认拒绝 + 显式白名单"这套组合拳的第二部分。
# --------------------------------------------------------------
resource "kubernetes_network_policy" "allow_from_client" {
  metadata {
    name      = "allow-from-client"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = { app = "backend" }
    }

    ingress {
      from {
        pod_selector {
          match_labels = { role = "allowed-client" }
        }
      }

      ports {
        port     = 80
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

# 一个"被允许"的客户端 Pod
resource "kubernetes_pod" "allowed_client" {
  metadata {
    name      = "allowed-client"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      role = "allowed-client"
    }
  }
  spec {
    container {
      name    = "client"
      image   = "busybox:1.36"
      command = ["sh", "-c", "sleep 3600"]
    }
  }
}

# 一个"不被允许"的普通 Pod（没有 role=allowed-client 标签）
resource "kubernetes_pod" "blocked_client" {
  metadata {
    name      = "blocked-client"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    container {
      name    = "client"
      image   = "busybox:1.36"
      command = ["sh", "-c", "sleep 3600"]
    }
  }
}
