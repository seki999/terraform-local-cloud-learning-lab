# ============================================================
# variables.tf
# ============================================================

variable "namespace_name" {
  type        = string
  description = "本章资源所在的 Namespace"
  default     = "terraform-learning"
}

variable "ssd_workload_replicas" {
  type        = number
  description = "被 nodeSelector 强制调度到 disktype=ssd 节点的副本数"
  default     = 2

  validation {
    condition     = var.ssd_workload_replicas >= 1 && var.ssd_workload_replicas <= 4
    error_message = "ssd_workload_replicas 必须在 1 到 4 之间。"
  }
}

variable "spread_workload_replicas" {
  type        = number
  description = "用 Pod 反亲和策略强制打散到不同节点的副本数"
  default     = 2
}
