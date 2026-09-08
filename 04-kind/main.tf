# ============================================================
# main.tf —— 用 Terraform 演示 Kubernetes 调度（Scheduling）
# ------------------------------------------------------------
# 本章重点不是"部署一个新应用"，而是精确控制 Pod 被调度到
# *哪个* Node 上——这是理解多节点集群和单节点集群本质区别的关键。
# 详见 docs/06-kubernetes-basics.md 第 3 节"Pod 如何被调度到 Node"。
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name
  }
}

# --------------------------------------------------------------
# 实验一：nodeSelector —— 最简单粗暴的调度约束。
#
# kind-config.yaml 里我们给一个 worker 节点打了标签 disktype=ssd，
# 另一个打了 disktype=hdd。下面这个 Deployment 要求它的所有 Pod
# 只能调度到带有 disktype=ssd 标签的节点——如果集群里没有任何
# 节点满足这个条件，Pod 会一直停留在 Pending 状态
# （这也是"动手练习"里会让你故意体验的情况）。
# --------------------------------------------------------------
resource "kubernetes_deployment" "ssd_only" {
  metadata {
    name      = "ssd-only-workload"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      app = "ssd-only-workload"
    }
  }

  spec {
    replicas = var.ssd_workload_replicas

    selector {
      match_labels = {
        app = "ssd-only-workload"
      }
    }

    template {
      metadata {
        labels = {
          app = "ssd-only-workload"
        }
      }

      spec {
        # node_selector：Kubernetes 调度器的最基础匹配方式——
        # 只考虑 label 完全匹配这里声明的所有键值对的 Node。
        # 语义上等价于 SQL 里的 WHERE label = 'value' AND ...，
        # 不支持"或""不等于"这类复杂逻辑
        # （更复杂的逻辑需要用下面实验二里的 affinity）。
        node_selector = {
          disktype = "ssd"
        }

        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "32Mi"
            }
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------
# 实验二：Pod 反亲和性（Pod Anti-Affinity）—— 更灵活的调度约束。
#
# 这个 Deployment 要求：任何两个属于 app=spread-workload 的 Pod，
# 不能被调度到同一个 Node 上（topology_key = "kubernetes.io/hostname"
# 表示"以 Node 为单位判断唯一性"）。这样即使你把副本数改到很大，
# Kubernetes 也会尽量把它们分散到不同节点——这是很多"高可用"应用
# （比如一个数据库的多个副本）的标准配置模式：避免"一个 Node 挂了，
# 所有副本一起挂掉"的单点故障。
#
# required_during_scheduling_ignored_during_execution：
#   "required"（必须满足，不满足就不调度，对比 preferred 是"尽量满足"）
#   "ignored_during_execution"（如果 Pod 已经在运行，之后节点标签变化
#   导致条件不再满足，也不会因此驱逐这个 Pod——只在"调度那一刻"生效）。
# --------------------------------------------------------------
resource "kubernetes_deployment" "spread" {
  metadata {
    name      = "spread-workload"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      app = "spread-workload"
    }
  }

  spec {
    replicas = var.spread_workload_replicas

    selector {
      match_labels = {
        app = "spread-workload"
      }
    }

    template {
      metadata {
        labels = {
          app = "spread-workload"
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"

              label_selector {
                match_expressions {
                  key      = "app"
                  operator = "In"
                  values   = ["spread-workload"]
                }
              }
            }
          }
        }

        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "32Mi"
            }
          }
        }
      }
    }
  }
}
