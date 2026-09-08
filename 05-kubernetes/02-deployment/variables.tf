variable "nginx_version" {
  type        = string
  description = "nginx 镜像 tag。改变这个值并重新 apply，用来触发一次滚动升级。"
  default     = "1.27-alpine"
}
