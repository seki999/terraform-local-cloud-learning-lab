# ============================================================
# main.tf —— DaemonSet：每个节点自动跑一份
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-daemonset"
  }
}

# --------------------------------------------------------------
# DaemonSet 不需要（也不支持）指定 replicas——它的副本数
# 永远自动等于"当前满足调度条件的 Node 数量"。这里没有加任何
# node_selector/affinity，所以它会被调度到集群里**每一个**
# 可调度的 Node 上（回顾 04-kind：control-plane 默认有污点，
# 所以即使这里没有排除它，它上面也不会跑这个 DaemonSet 的 Pod，
# 除非额外加 tolerations）。
#
# 对比 04-kind 里用 podAntiAffinity "手工"实现的打散效果——
# DaemonSet 是 Kubernetes 原生支持"每节点一份"场景的专用对象，
# 不需要你手写反亲和规则、也不需要关心当前有几个节点。
# 典型真实用途：日志采集 Agent（Fluentd/Filebeat）、
# 节点监控 Agent（Node Exporter，见 08-monitoring 章节）、
# 网络插件（CNI 组件本身也经常用 DaemonSet 部署）。
# --------------------------------------------------------------
resource "kubernetes_daemonset" "node_agent" {
  metadata {
    name      = "node-agent"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    selector {
      match_labels = { app = "node-agent" }
    }

    template {
      metadata {
        labels = { app = "node-agent" }
      }
      spec {
        container {
          name  = "agent"
          image = "busybox:1.36"
          command = [
            "sh", "-c",
            "while true; do echo \"$(date) agent alive on $(hostname)\"; sleep 30; done"
          ]

          resources {
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
          }
        }
      }
    }
  }
}
