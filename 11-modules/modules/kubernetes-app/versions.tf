# ============================================================
# modules/kubernetes-app/versions.tf
# ------------------------------------------------------------
# hashicorp/kubernetes 恰好在 Terraform 的默认命名空间
# （registry.terraform.io/hashicorp/*）下，即使完全不写这个文件，
# Terraform 也能猜对来源。这里依然显式声明，是为了让所有 module
# 遵循同一套"明确声明依赖，不依赖隐式默认值"的一致规范
# ——尤其是当你以后把这个 module 复制到别的项目里独立使用时，
# 显式声明能让它不必依赖"恰好蒙对默认值"这种运气。
# ============================================================

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
