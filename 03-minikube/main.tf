# ============================================================
# main.tf —— Terraform 管理 Minikube 上的 Kubernetes 对象
# ------------------------------------------------------------
# 资源依赖链条（从上到下）：
#   Namespace
#     ├── ConfigMap（网页内容）
#     ├── Secret（API Key）
#     └── PersistentVolumeClaim（持久化目录）
#            │
#            ▼
#        Deployment（挂载上面三者）
#            │
#            ▼
#        Service（稳定的集群内访问入口）
#            │
#            ▼
#        Ingress（集群外部 HTTP 入口）
# ============================================================

# --------------------------------------------------------------
# Namespace：本章所有资源的逻辑隔离边界。
# 概念详解见 docs/06-kubernetes-basics.md 第 4 节。
# --------------------------------------------------------------
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name
    labels = {
      "managed-by" = "terraform"
      "chapter"    = "03-minikube"
    }
  }
}

# --------------------------------------------------------------
# ConfigMap：存放非敏感的配置数据——这里是一整个 index.html。
# ConfigMap 的核心价值：把"配置"和"镜像"解耦，同一个 nginx 镜像
# 通过挂载不同的 ConfigMap 就能展示不同内容，而不需要重新构建镜像。
# --------------------------------------------------------------
resource "kubernetes_config_map" "web_content" {
  metadata {
    name      = "web-content"
    namespace = kubernetes_namespace.this.metadata[0].name
    # 引用 kubernetes_namespace.this.metadata[0].name 而不是直接写
    # var.namespace_name 字符串，是为了让 Terraform 建立"ConfigMap
    # 依赖 Namespace"的隐式依赖——保证先创建 Namespace、
    # 且如果 Namespace 被重建，Terraform 能感知到下游需要联动处理。
  }

  data = {
    "index.html" = <<-EOT
      <!DOCTYPE html>
      <html>
        <head><title>Terraform + Minikube</title></head>
        <body>
          <h1>${var.welcome_message}</h1>
          <p>environment = ${var.environment}</p>
          <p>该页面内容完全由 Kubernetes ConfigMap 提供，
             未来即使替换整个应用镜像，只要挂载路径不变，这个页面依然生效。</p>
        </body>
      </html>
    EOT
  }
}

# --------------------------------------------------------------
# Secret：存放敏感信息（这里是一个演示用的 API Key）。
# 和 ConfigMap 结构几乎一样，区别在于：
#   - kubectl get secret 默认不会直接显示明文内容（会被 base64 编码展示）；
#   - Kubernetes 在 etcd 里对 Secret 的存储可以配置静态加密（本地
#     Minikube 默认不开启，生产集群通常会开启）。
# 但和 Terraform State 的关系类似 09-vault-basics.md 里的结论——
# Secret 的值最终仍然会以明文形式出现在 Terraform State 里。
# --------------------------------------------------------------
resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "app-secret"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    api_key = var.api_key
  }

  type = "Opaque" # Opaque 表示"通用、无特定结构"的 Secret 类型
}

# --------------------------------------------------------------
# PersistentVolumeClaim：向集群"申请"一块持久化存储。
# PVC 本身不是存储，而是一份"申请书"；真正的存储由 StorageClass
# 背后的 Provisioner（Minikube 默认是基于 hostPath 的
# storage-provisioner addon）动态创建出一个 PersistentVolume 来满足它。
# --------------------------------------------------------------
resource "kubernetes_persistent_volume_claim" "web_data" {
  metadata {
    name      = "web-data"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    # ReadWriteOnce：同一时间只能被一个 Node 上的 Pod 挂载读写。
    # 这是 hostPath 类型存储的天然限制，也是最常见的 PVC 访问模式。

    resources {
      requests = {
        storage = var.pvc_size
      }
    }

    storage_class_name = var.storage_class
  }

  wait_until_bound = true
  # wait_until_bound = true（默认值，这里显式写出便于讲解）：
  # apply 会一直等到这个 PVC 的 status 变成 Bound 才继续，
  # 而不是"提交了申请就当作完成"。如果 StorageClass 不存在
  # 或 Provisioner 故障，这一步会一直等待直到超时报错——
  # 这其实是 Terraform 在帮你提前发现"存储没有正确配置"的问题。
}

# --------------------------------------------------------------
# Deployment：管理 Pod 的期望副本数、滚动升级策略。
# 详见 docs/06-kubernetes-basics.md 第 5 节的三层关系讲解。
# --------------------------------------------------------------
resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      app = "web"
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = "web"
      }
      # selector 决定了这个 Deployment（通过 ReplicaSet）"认领"哪些 Pod。
      # 它必须和下面 template.metadata.labels 完全匹配，
      # 否则 Kubernetes API 会直接拒绝这个 Deployment。
    }

    template {
      metadata {
        labels = {
          app = "web"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          env {
            name = "API_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secret.metadata[0].name
                key  = "api_key"
              }
            }
            # value_from + secret_key_ref：让容器在启动时从 Secret 里
            # 读取这个环境变量的值，而不是把值直接写死在 Deployment
            # 的 env 定义里——这是 Kubernetes 原生支持的"Secret 注入"方式。
          }

          volume_mount {
            name       = "web-content"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }

          volume_mount {
            name       = "web-data"
            mount_path = "/var/log/nginx"
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            # requests：调度器保证这个 Pod 至少能拿到的资源量，
            #           用来决定这个 Pod 能被调度到哪个 Node（Node 剩余
            #           可分配资源必须 >= 所有 requests 总和）。
            # limits：这个 Pod 实际运行时允许使用的资源上限，
            #         超过 memory limit 会被 OOMKilled，
            #         超过 cpu limit 只会被限流（不会被杀死）。
            # 详细专题见 05-kubernetes/13-probes-resources/README.md。
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 10
            # Liveness Probe：探测失败达到阈值次数后，kubelet 会重启
            # 这个容器——用来处理"进程还活着，但已经死锁/无响应"的情况。
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 1
            period_seconds        = 5
            # Readiness Probe：探测失败时，Service 会把这个 Pod 从
            # "可接收流量"的端点列表里摘除（但不会重启容器）——
            # 用来处理"进程活着，但还没准备好处理请求"的情况
            # （比如正在加载配置、预热缓存）。
          }
        }

        volume {
          name = "web-content"
          config_map {
            name = kubernetes_config_map.web_content.metadata[0].name
          }
        }

        volume {
          name = "web-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.web_data.metadata[0].name
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------
# Service：为上面的 Deployment 管理的 Pod 提供一个稳定的集群内入口。
# 详见 docs/06-kubernetes-basics.md 第 6 节。
# --------------------------------------------------------------
resource "kubernetes_service" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    selector = {
      app = "web"
      # Service 靠这个 selector 找到该转发流量给哪些 Pod——
      # 只要 Pod 的 label 里有 app=web，无论 Pod 怎么被重建、
      # IP 怎么变化，都会被这个 Service 自动纳入。
    }

    port {
      port        = 80 # Service 自己对外暴露的端口
      target_port = 80 # 转发到 Pod 内部的哪个端口
    }

    type = "ClusterIP" # 默认类型：只能在集群内部访问
  }
}

# --------------------------------------------------------------
# Ingress：集群外部 HTTP 入口，把 var.ingress_host 的请求路由到上面的 Service。
# 前置条件：需要先执行 `minikube addons enable ingress`
# （见 README 执行步骤），否则不会有任何 Ingress Controller
# 去"实现"这条规则——Ingress 资源本身只是一份路由声明，
# 真正生效需要有 Controller 在监听并配置反向代理。
# --------------------------------------------------------------
resource "kubernetes_ingress_v1" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    # "nginx" 对应 Minikube ingress addon 安装的 ingress-nginx
    # Controller 所声明的 IngressClass 名称。

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.web.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
