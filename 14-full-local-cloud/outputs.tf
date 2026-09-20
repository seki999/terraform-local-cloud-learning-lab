# ============================================================
# outputs.tf
# ============================================================

output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}

output "frontend_port_forward_command" {
  value = "kubectl port-forward -n ${var.namespace_name} svc/frontend 8100:80"
}

output "vault_addr" {
  value = "http://127.0.0.1:8201"
}

output "vault_secret_path" {
  value = "graduation-secret/data/app/database"
}

output "network_verification_commands" {
  value = [
    "kubectl get pods,svc -n ${var.namespace_name}",
    "kubectl get endpoints -n ${var.namespace_name}",
    "kubectl exec -n ${var.namespace_name} deploy/frontend -- cat /etc/resolv.conf"
  ]
}
