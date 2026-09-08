# ============================================================
# outputs.tf
# ============================================================

output "vault_addr" {
  value = "http://127.0.0.1:8200"
}

output "vault_ui_url" {
  value = "http://127.0.0.1:8200/ui"
}

output "app_token" {
  description = "只拥有 app-read-only 策略的受限 Token"
  value       = vault_token.app_token.client_token
  sensitive   = true
}

output "secret_path" {
  value = "learning-secret/data/app/database"
}
