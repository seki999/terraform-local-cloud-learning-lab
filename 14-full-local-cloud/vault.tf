# ============================================================
# vault.tf —— 本地 Vault：集中管理 db_password
# ------------------------------------------------------------
# 沿用 09-vault 章节验证过的写法（端口改为 8201，避免和
# 09-vault 章节残留的容器冲突）。
# ============================================================

resource "docker_image" "vault" {
  name         = "hashicorp/vault:1.18"
  keep_locally = true
}

resource "docker_container" "vault" {
  name  = "vault-graduation"
  image = docker_image.vault.image_id

  ports {
    internal = 8200
    external = 8201
  }

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=${var.vault_root_token}",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200",
  ]

  capabilities {
    add = ["CAP_IPC_LOCK"]
  }

  restart = "unless-stopped"
}

resource "time_sleep" "wait_for_vault_container" {
  depends_on      = [docker_container.vault]
  create_duration = "3s"
}

resource "null_resource" "wait_for_vault" {
  depends_on = [time_sleep.wait_for_vault_container]

  triggers = {
    vault_container_id = docker_container.vault.id
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = "SilentlyContinue"
      for ($i = 0; $i -lt 15; $i++) {
        try {
          $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8201/v1/sys/health" -UseBasicParsing -TimeoutSec 3
          if ($resp.StatusCode -eq 200) { Write-Host "Vault is ready."; exit 0 }
        } catch {}
        Start-Sleep -Seconds 2
      }
      Write-Error "Vault did not become ready in time."
      exit 1
    EOT
  }
}

resource "vault_mount" "kv" {
  path = "graduation-secret"
  type = "kv-v2"

  depends_on = [null_resource.wait_for_vault]
}

resource "vault_kv_secret_v2" "db_credentials" {
  mount = vault_mount.kv.path
  name  = "app/database"

  data_json = jsonencode({
    username = "app_user"
    password = var.db_password
  })
}

# --------------------------------------------------------------
# 关键的"跨领域桥接"：用 data source 把刚刚写进 Vault 的密码读出来
# （模拟真实项目里"Terraform 从 Vault 读取运维已经配置好的 Secret"
# 这一常见集成模式），再用它去创建下面 k8s-app.tf 里的
# kubernetes_secret——这就是本章"统一编排"思想的核心体现：
# Vault 管理 Secret 的事实来源（source of truth），
# Kubernetes 只是这个 Secret 的一个具体消费方。
# --------------------------------------------------------------
data "vault_kv_secret_v2" "db_credentials" {
  mount = vault_mount.kv.path
  name  = vault_kv_secret_v2.db_credentials.name
}
