# ============================================================
# modules/docker-service/variables.tf
# ============================================================

variable "service_name" {
  type        = string
  description = "服务名称，会用作容器名"
}

variable "image" {
  type        = string
  description = "容器镜像（含 tag）"
}

variable "network_name" {
  type        = string
  description = "要加入的 Docker 网络名称（通常来自 docker-network module 的 output）"
}

variable "command" {
  type        = list(string)
  description = "覆盖容器默认启动命令，留空则使用镜像自带的默认命令"
  default     = null
  nullable    = true
}

variable "env" {
  type        = list(string)
  description = "环境变量列表，格式 KEY=VALUE"
  default     = []
}

variable "port_mappings" {
  description = "端口映射列表，留空表示不对外发布端口（仅集群/网络内部可见）"
  type = list(object({
    internal = number
    external = number
  }))
  default = []
}

variable "keep_image_locally" {
  type    = bool
  default = true
}
