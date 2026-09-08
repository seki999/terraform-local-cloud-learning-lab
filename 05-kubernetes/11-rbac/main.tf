# ============================================================
# main.tf —— RBAC：ServiceAccount / Role / RoleBinding /
#                  ClusterRole / ClusterRoleBinding
# ------------------------------------------------------------
# RBAC（Role-Based Access Control）回答一个问题："谁（Subject）
# 能对哪些资源（Resource）执行哪些操作（Verb）？"
# Kubernetes 里"谁"可以是用户、用户组，也可以是本实验演示的
# ServiceAccount（供集群内的 Pod 使用的身份）。
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-rbac"
  }
}

# --------------------------------------------------------------
# ServiceAccount：Pod 的"身份证"。每个 Namespace 都有一个
# 自动创建的 "default" ServiceAccount，但生产实践中应该为不同用途的
# 应用创建专属 ServiceAccount，配合最小权限原则单独授权。
# --------------------------------------------------------------
resource "kubernetes_service_account" "reader" {
  metadata {
    name      = "pod-reader-sa"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

# --------------------------------------------------------------
# Role：定义"在某个 Namespace 内，能对哪些资源做哪些操作"
# ——注意 Role 是**命名空间级别**的权限声明，只在它所在的
# Namespace 内生效。
# --------------------------------------------------------------
resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  rule {
    api_groups = [""] # "" 表示 core API group（Pod、ConfigMap、Secret 等核心资源都在这里）
    resources  = ["pods", "configmaps"]
    verbs      = ["get", "list", "watch"] # 只读权限，符合"最小权限原则"
  }
}

# --------------------------------------------------------------
# RoleBinding：把 Role（权限的定义）和 Subject（谁）绑定起来。
# 没有 RoleBinding，单独的 Role 不会对任何人生效——
# 这种"定义"和"绑定"分离的设计，让同一个 Role 可以被复用、
# 绑定给多个不同的 ServiceAccount/用户。
# --------------------------------------------------------------
resource "kubernetes_role_binding" "pod_reader_binding" {
  metadata {
    name      = "pod-reader-binding"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.reader.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

# --------------------------------------------------------------
# ClusterRole + ClusterRoleBinding：和 Role/RoleBinding 的结构一样，
# 但作用域是**整个集群**，不局限于单个 Namespace——
# 常用于"跨 Namespace 才有意义"的资源（比如 Node，Node 不属于
# 任何 Namespace）或"需要在所有 Namespace 生效"的权限。
# --------------------------------------------------------------
resource "kubernetes_cluster_role" "node_viewer" {
  metadata {
    name = "learning-node-viewer"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "node_viewer_binding" {
  metadata {
    name = "learning-node-viewer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.node_viewer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.reader.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

# 一个使用上面这个 ServiceAccount 的 Pod，用于亲手验证权限边界
resource "kubernetes_pod" "rbac_test" {
  metadata {
    name      = "rbac-test"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    service_account_name = kubernetes_service_account.reader.metadata[0].name

    container {
      name    = "kubectl"
      image   = "bitnami/kubectl:latest"
      command = ["sh", "-c", "sleep 3600"]
    }
  }
}
