output "service_name" {
  value = kubernetes_service.this.metadata[0].name
}

output "cluster_ip" {
  value = kubernetes_service.this.spec[0].cluster_ip
}
