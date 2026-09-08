output "server_count" {
  value = length(random_pet.servers)
}

output "server_names" {
  value = [for p in random_pet.servers : p.id]
}

# check block：独立于任何具体资源的"持续性断言"，即使没有资源变化，
# 每次 plan/apply 都会重新求值——适合表达"整个配置层面的健康检查"，
# 而不是绑定在某一个资源的生命周期上。
check "at_least_one_server" {
  assert {
    condition     = length(random_pet.servers) >= 1
    error_message = "配置里至少应该有一台服务器。"
  }
}
