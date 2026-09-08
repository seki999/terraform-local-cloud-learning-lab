output "workspace" {
  value = terraform.workspace
}

output "replica_count" {
  value = local.current_env.replica_count
}

output "log_level" {
  value = local.current_env.log_level
}
