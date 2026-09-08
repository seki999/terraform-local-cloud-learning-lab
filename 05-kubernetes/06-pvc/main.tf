# ============================================================
# main.tf —— PersistentVolumeClaim 动态供给全过程
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-pvc"
  }
}

# --------------------------------------------------------------
# 本实验故意不指定 storage_class_name，而是使用集群默认的
# StorageClass——Kind 集群默认自带一个叫 "standard" 的 StorageClass
# （由 local-path-provisioner 提供，基于宿主 Node 上的本地目录实现），
# 并且被标记为 default，所以留空也能正常动态供给。
# --------------------------------------------------------------
resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name      = "demo-data"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "500Mi"
      }
    }
  }

  # --------------------------------------------------------------
  # 重要陷阱：这里必须是 false，否则会死锁！
  #
  # Kind 集群默认的 "standard" StorageClass 用的是
  # volume_binding_mode = WaitForFirstConsumer——这意味着"在有一个
  # 真正使用这个 PVC 的 Pod 被调度之前，PVC 永远不会变成 Bound"
  # （因为 local-path-provisioner 需要先知道 Pod 被调度到了哪个
  # Node，才能在那个 Node 本地创建对应的存储目录）。
  #
  # 如果这里设成 true，Terraform 会在创建完 PVC 后立刻卡住等待它
  # 变成 Bound，但按依赖顺序，负责"消费"这个 PVC 的 Pod 还没被创建
  # ——于是出现"PVC 等 Pod，Pod 还没轮到创建"的死锁，
  # apply 会一直卡到超时报错（实测卡住 5 分钟后报
  # "client rate limiter Wait returned an error: context deadline exceeded"）。
  #
  # 这不是本项目独有的问题——任何使用 WaitForFirstConsumer 模式
  # StorageClass（包括不少真实云环境的默认 StorageClass）的场景，
  # 都需要注意这一点：wait_until_bound 应该设为 false，
  # 让 Terraform 正常往下创建 Pod，PVC 会在 Pod 被调度后自然变成 Bound
  # （可以之后用 `kubectl get pvc` 自行确认，而不是让 apply 卡住等它）。
  wait_until_bound = false
}

resource "kubernetes_pod" "writer" {
  metadata {
    name      = "pvc-writer"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    container {
      name    = "writer"
      image   = "busybox:1.36"
      command = ["sh", "-c", "echo \"written at $(date)\" >> /data/log.txt && sleep 3600"]

      volume_mount {
        name       = "data"
        mount_path = "/data"
      }
    }

    volume {
      name = "data"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.data.metadata[0].name
      }
    }
  }
}
