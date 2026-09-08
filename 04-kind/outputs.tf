# ============================================================
# outputs.tf
# ============================================================

output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}

output "check_ssd_scheduling_command" {
  description = "验证 ssd-only-workload 的 Pod 是否都被调度到了 disktype=ssd 的节点"
  value       = "kubectl get pods -n ${var.namespace_name} -l app=ssd-only-workload -o wide"
}

output "check_spread_scheduling_command" {
  description = "验证 spread-workload 的 Pod 是否被分散到了不同节点"
  value       = "kubectl get pods -n ${var.namespace_name} -l app=spread-workload -o wide"
}
