# ============================================================
# outputs.tf
# ============================================================

output "namespace" {
  description = "本章使用的 Namespace"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "service_cluster_ip" {
  description = "Service 的集群内虚拟 IP（只能在集群内部访问，浏览器无法直接打开）"
  value       = kubernetes_service.web.spec[0].cluster_ip
}

output "ingress_host" {
  description = "Ingress 绑定的域名"
  value       = var.ingress_host
}

output "port_forward_command" {
  description = "最简单的验证方式：本地端口转发到 Service"
  value       = "kubectl port-forward -n ${var.namespace_name} svc/web 8080:80"
}

output "curl_via_ingress_command" {
  description = "通过 Ingress 验证访问的命令（无需修改系统 hosts 文件）"
  value       = "curl --resolve ${var.ingress_host}:80:$(minikube ip) http://${var.ingress_host}/"
}
