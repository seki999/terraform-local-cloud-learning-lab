variable "replica_count" {
  type        = number
  description = "要创建的服务器身份数量"
  default     = 2

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 5
    error_message = "replica_count 必须在 1 到 5 之间。"
  }
}

variable "name_prefix" {
  type        = string
  description = "服务器名称前缀"
  default     = "srv"

  validation {
    condition     = length(var.name_prefix) > 0
    error_message = "name_prefix 不能是空字符串。"
  }
}
