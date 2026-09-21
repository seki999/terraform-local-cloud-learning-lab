# ============================================================
# dashboard-resources.tf
# ------------------------------------------------------------
# 这一文件专门用于“把 Kubernetes Dashboard 里常见的资源类型都做出来”。
#
# 设计原则：
#   1. 03-minikube/main.tf 保留原来的 Web 应用主线；
#   2. 本文件增加 Dashboard 学习用资源；
#   3. 某些资源（Pod / ReplicaSet / EndpointSlice / PV 等）由 Kubernetes
#      Controller 或 Minikube 自动派生，不需要也不应该全部手工创建；
#   4. 这些资源都使用很小的本地资源量，适合单节点 Minikube 学习环境。
# ============================================================

locals {
  dashboard_labels = {
    "managed-by" = "terraform"
    "chapter"    = "03-minikube"
    "purpose"    = "dashboard-learning"
  }
}

# ------------------------------------------------------------
# Config / Policy: ResourceQuota
# Dashboard: Namespace -> Resource Quotas
# ------------------------------------------------------------
resource "kubernetes_resource_quota_v1" "dashboard_demo" {
  metadata {
    name      = "dashboard-demo-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    hard = {
      "pods"                   = "30"
      "services"               = "20"
      "persistentvolumeclaims" = "10"
      "configmaps"             = "30"
      "secrets"                = "30"
    }
  }
}

# ------------------------------------------------------------
# Config / Policy: LimitRange
# 给没有显式 resources 的 Pod 自动补一个很小的默认值。
# ------------------------------------------------------------
resource "kubernetes_limit_range_v1" "dashboard_demo" {
  metadata {
    name      = "dashboard-demo-limits"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = "100m"
        memory = "128Mi"
      }

      default_request = {
        cpu    = "25m"
        memory = "32Mi"
      }
    }
  }
}

# ------------------------------------------------------------
# Access Control: ServiceAccount
# Dashboard: Service Accounts
# ------------------------------------------------------------
resource "kubernetes_service_account_v1" "dashboard_reader" {
  metadata {
    name      = "dashboard-reader"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }
}

# Namespace-scoped Role
resource "kubernetes_role_v1" "dashboard_reader" {
  metadata {
    name      = "dashboard-reader"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "configmaps", "secrets", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "dashboard_reader" {
  metadata {
    name      = "dashboard-reader"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.dashboard_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.dashboard_reader.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

# Cluster-scoped, read-only RBAC demo.
resource "kubernetes_cluster_role_v1" "dashboard_cluster_reader" {
  metadata {
    name   = "terraform-learning-cluster-reader"
    labels = local.dashboard_labels
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "namespaces", "persistentvolumes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "dashboard_cluster_reader" {
  metadata {
    name   = "terraform-learning-cluster-reader"
    labels = local.dashboard_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.dashboard_cluster_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.dashboard_reader.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

# ------------------------------------------------------------
# Workload: standalone Pod
# Dashboard: Pods
# ------------------------------------------------------------
resource "kubernetes_pod_v1" "standalone" {
  metadata {
    name      = "standalone-pod"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = merge(local.dashboard_labels, {
      app = "standalone-pod"
    })
  }

  spec {
    container {
      name    = "busybox"
      image   = "busybox:1.36"
      command = ["sh", "-c", "while true; do echo standalone-pod-is-running; sleep 30; done"]

      resources {
        requests = {
          cpu    = "10m"
          memory = "16Mi"
        }
        limits = {
          cpu    = "50m"
          memory = "32Mi"
        }
      }
    }
  }
}

# ------------------------------------------------------------
# Workload: StatefulSet + Headless Service
# Dashboard: Stateful Sets / Pods / Services
# ------------------------------------------------------------
resource "kubernetes_service_v1" "stateful_headless" {
  metadata {
    name      = "stateful-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    cluster_ip = "None"

    selector = {
      app = "stateful-demo"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "80"
    }
  }
}

resource "kubernetes_stateful_set_v1" "demo" {
  metadata {
    name      = "stateful-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    service_name = kubernetes_service_v1.stateful_headless.metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app = "stateful-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "stateful-demo"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "20m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

# ------------------------------------------------------------
# Workload: DaemonSet
# 单节点 Minikube 中通常会看到 1 个对应 Pod。
# ------------------------------------------------------------
resource "kubernetes_daemon_set_v1" "demo" {
  metadata {
    name      = "daemon-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    selector {
      match_labels = {
        app = "daemon-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "daemon-demo"
        }
      }

      spec {
        container {
          name    = "busybox"
          image   = "busybox:1.36"
          command = ["sh", "-c", "while true; do echo daemon-running-on-$NODE_NAME; sleep 60; done"]

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
            limits = {
              cpu    = "50m"
              memory = "32Mi"
            }
          }
        }
      }
    }
  }
}

# ------------------------------------------------------------
# Workload: Job
# ------------------------------------------------------------
resource "kubernetes_job_v1" "demo" {
  metadata {
    name      = "job-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    template {
      metadata {
        labels = {
          app = "job-demo"
        }
      }

      spec {
        restart_policy = "Never"

        container {
          name    = "job"
          image   = "busybox:1.36"
          command = ["sh", "-c", "echo 'Hello from Kubernetes Job'; sleep 5"]

          resources {
            requests = {
              cpu    = "5m"
              memory = "8Mi"
            }
            limits = {
              cpu    = "25m"
              memory = "16Mi"
            }
          }
        }
      }
    }

    backoff_limit = 1
  }

  wait_for_completion = false
}

# ------------------------------------------------------------
# Workload: CronJob
# 每 5 分钟生成一次 Job，方便在 Dashboard 里观察父子关系。
# ------------------------------------------------------------
resource "kubernetes_cron_job_v1" "demo" {
  metadata {
    name      = "cron-demo"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    schedule                      = "*/5 * * * *"
    concurrency_policy            = "Forbid"
    successful_jobs_history_limit = 2
    failed_jobs_history_limit     = 2

    job_template {
      metadata {}

      spec {
        template {
          metadata {}

          spec {
            restart_policy = "Never"

            container {
              name    = "cron"
              image   = "busybox:1.36"
              command = ["sh", "-c", "date; echo 'Hello from CronJob'"]

              resources {
                requests = {
                  cpu    = "5m"
                  memory = "8Mi"
                }
                limits = {
                  cpu    = "25m"
                  memory = "16Mi"
                }
              }
            }
          }
        }
      }
    }
  }
}

# ------------------------------------------------------------
# Service: NodePort
# 除原来的 ClusterIP Service 以外，再演示 NodePort。
# ------------------------------------------------------------
resource "kubernetes_service_v1" "web_nodeport" {
  metadata {
    name      = "web-nodeport"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    selector = {
      app = "web"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "80"
    }

    type = "NodePort"
  }
}

# ------------------------------------------------------------
# Networking: NetworkPolicy
# 只选择 stateful-demo，并允许所有 ingress/egress。
# 目的是让 Dashboard 中出现 NetworkPolicy，同时不破坏主 Web 应用流量。
# ------------------------------------------------------------
resource "kubernetes_network_policy_v1" "stateful_demo" {
  metadata {
    name      = "stateful-demo-policy"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    pod_selector {
      match_labels = {
        app = "stateful-demo"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {}
    egress {}
  }
}

# ------------------------------------------------------------
# Availability: PodDisruptionBudget
# ------------------------------------------------------------
resource "kubernetes_pod_disruption_budget_v1" "web" {
  metadata {
    name      = "web-pdb"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        app = "web"
      }
    }
  }
}

# ------------------------------------------------------------
# Autoscaling: HPA v2
# HPA 的 CPU 指标依赖 metrics-server。
# README / open-dashboard.ps1 中提供了启用方法。
# ------------------------------------------------------------
resource "kubernetes_horizontal_pod_autoscaler_v2" "web" {
  metadata {
    name      = "web-hpa"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.dashboard_labels
  }

  spec {
    min_replicas = 1
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.web.metadata[0].name
    }

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}
