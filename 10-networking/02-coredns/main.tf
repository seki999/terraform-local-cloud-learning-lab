# ============================================================
# main.tf —— Kubernetes 内部 DNS（CoreDNS）观察实验
# ------------------------------------------------------------
# 本实验不直接管理 CoreDNS 本身（它是集群自带的 kube-system 组件），
# 而是创建几种不同类型的 Service，用同一个 nslookup 工具观察
# CoreDNS 对它们分别解析出什么样的 DNS 记录——用真实查询结果
# 直观区分 A 记录和 CNAME 记录。
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-10-coredns"
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    replicas = 1
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

# 普通 ClusterIP Service —— CoreDNS 会为它生成一条 A 记录，
# 指向这个 Service 自己的虚拟 IP。
resource "kubernetes_service" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "web" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# --------------------------------------------------------------
# ExternalName Service —— 这是最能体现"Kubernetes Service 本质上
# 是一层 DNS 抽象"的例子：它不做任何流量转发、不分配虚拟 IP，
# CoreDNS 只是为它生成一条指向外部域名的 **CNAME 记录**。
# 集群内任何 Pod 访问 "external-example.<ns>.svc.cluster.local"，
# 实际上会被解析成 "example.com"，再走正常的外部 DNS 解析流程。
# --------------------------------------------------------------
resource "kubernetes_service" "external_example" {
  metadata {
    name      = "external-example"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "example.com"
  }
}
