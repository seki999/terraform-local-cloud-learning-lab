# ============================================================
# outputs.tf
# ============================================================

output "ingress_nginx_status" {
  description = "ingress-nginx Release 状态"
  value       = var.install_ingress_nginx ? helm_release.ingress_nginx[0].status : "未安装（install_ingress_nginx = false）"
}

output "kube_prometheus_stack_status" {
  description = "kube-prometheus-stack Release 状态"
  value       = helm_release.kube_prometheus_stack.status
}

output "grafana_port_forward_command" {
  description = "访问 Grafana 的端口转发命令"
  value       = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
}

output "prometheus_port_forward_command" {
  description = "访问 Prometheus UI 的端口转发命令"
  value       = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
}

output "grafana_admin_username" {
  value = "admin"
}
