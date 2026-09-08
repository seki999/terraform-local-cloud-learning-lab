# ============================================================
# main.tf —— 三种 Service 类型对比
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-service"
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 2
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
          image = "nginx:1.27-alpine"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------
# ClusterIP（默认类型）：只能在集群内部访问，是构建内部微服务
# 通信的标准方式，也是本项目前面章节一直在用的类型。
# --------------------------------------------------------------
resource "kubernetes_service" "clusterip" {
  metadata {
    name      = "web-clusterip"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "web" }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

# --------------------------------------------------------------
# NodePort：在**每个** Node 上都开放同一个端口（30000-32767 范围），
# 集群外部可以通过"任意 Node 的 IP + 这个端口"访问到 Service——
# 这是没有云负载均衡器时，最原始的"对外暴露"方式
# （对比 Ingress：NodePort 无法基于域名/路径做七层路由）。
# --------------------------------------------------------------
resource "kubernetes_service" "nodeport" {
  metadata {
    name      = "web-nodeport"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "web" }
    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }
    type = "NodePort"
  }
}

# --------------------------------------------------------------
# Headless Service（clusterIP = "None"）：不分配虚拟 IP，
# DNS 查询这个 Service 名字时，直接返回**所有匹配 Pod 的 IP 列表**，
# 而不是一个统一的虚拟 IP。这是 StatefulSet（见 07-statefulset）
# 依赖的机制——客户端需要直接感知到"有哪些具体的 Pod"，
# 而不是被一个虚拟 IP 屏蔽掉细节。
# --------------------------------------------------------------
resource "kubernetes_service" "headless" {
  metadata {
    name      = "web-headless"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector   = { app = "web" }
    cluster_ip = "None"
    port {
      port        = 80
      target_port = 80
    }
  }
}
