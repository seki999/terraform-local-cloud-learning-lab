# ============================================================
# variables.tf
# ============================================================

variable "environment" {
  type        = string
  description = "环境标识，会作为环境变量传给 Web App 容器，用于演示配置如何随环境变化"
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment 必须是 dev / test / prod 之一。"
  }
}

variable "postgres_db" {
  type        = string
  description = "PostgreSQL 初始数据库名"
  default     = "app_db"
}

variable "postgres_user" {
  type        = string
  description = "PostgreSQL 初始用户名"
  default     = "app_user"
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL 密码（教学占位符，仅用于本地容器，不是真实密码）"
  default     = "demo-password"
  sensitive   = true
}

variable "restart_policy" {
  type        = string
  description = "所有容器统一使用的重启策略，对应 docker run --restart 参数"
  default     = "unless-stopped"

  validation {
    condition     = contains(["no", "always", "on-failure", "unless-stopped"], var.restart_policy)
    error_message = "restart_policy 必须是 Docker 支持的取值之一：no / always / on-failure / unless-stopped。"
  }
}

variable "nginx_port_mappings" {
  description = <<-EOT
    nginx 容器的端口映射列表，用于演示 dynamic block。
    每一项包含 internal（容器内部监听端口）和 external（映射到 Windows 宿主机的端口）。
  EOT
  type = list(object({
    internal = number
    external = number
  }))
  default = [
    { internal = 80, external = 8080 }
  ]
}

variable "keep_images_locally" {
  type        = bool
  description = "destroy 时是否保留已拉取的镜像（避免下次 apply 重新下载）。演示 docker_image 的 keep_locally 参数。"
  default     = true
}
