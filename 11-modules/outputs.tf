# ============================================================
# outputs.tf —— root module
# ============================================================

output "network_name" {
  value = module.network.network_name
}

output "web_container_name" {
  value = module.web.container_name
}

output "api_container_name" {
  value = module.api.container_name
}

output "k8s_frontend_service" {
  value = module.k8s_frontend.service_name
}

output "web_url" {
  value = "http://localhost:8090"
}
