# ============================================================
# main.tf —— 本地 Vault（Docker）+ Vault 配置（Terraform Vault Provider）
# ============================================================

resource "docker_image" "vault" {
  name         = "hashicorp/vault:1.18"
  keep_locally = true
}

# --------------------------------------------------------------
# Vault 的"开发模式"（Dev Mode）：单节点、内存存储、自动解封
# （Unseal，真实生产环境的 Vault 启动后默认是"封存"状态，
# 必须用密钥分片"解封"才能使用——这是 Vault 保护根密钥的机制，
# Dev 模式为了学习方便自动跳过了这一步）、固定 root token。
# **仅适合本地学习，绝不能在生产环境使用 Dev 模式**
# ——容器一旦重启，里面所有数据全部丢失，且没有任何访问控制的
# 缓冲地带（root token 直接暴露）。
# --------------------------------------------------------------
resource "docker_container" "vault" {
  name  = "vault-learning-lab"
  image = docker_image.vault.image_id

  ports {
    internal = 8200
    external = 8200
  }

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=${var.vault_root_token}",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200",
  ]

  capabilities {
    # 注意必须写 "CAP_IPC_LOCK"（带 CAP_ 前缀），而不是 "IPC_LOCK"。
    # 这是本项目实测踩过的一个坑：如果写不带前缀的 "IPC_LOCK"，
    # `apply` 当时能成功，但 Docker Engine 内部会把它规范化存成
    # "CAP_IPC_LOCK"；下一次 `terraform plan` 读取真实状态时，
    # 会发现"配置里是 IPC_LOCK，真实状态是 CAP_IPC_LOCK"，两者
    # 永远对不上，导致每一次 plan 都显示要销毁重建这个容器
    # （一种"永久性 drift"）。带上 CAP_ 前缀就能和 Docker 返回的
    # 真实值完全一致，避免这个问题。
    add = ["CAP_IPC_LOCK"]
    # IPC_LOCK：允许 Vault 把内存页锁定，防止被交换到磁盘——
    # 这是 Vault 保护内存中明文密钥/Secret 不被换出到磁盘的安全措施，
    # 官方镜像文档建议始终加上这个 capability。
  }

  restart = "unless-stopped"
}

resource "time_sleep" "wait_for_vault_container" {
  depends_on      = [docker_container.vault]
  create_duration = "3s"
}

resource "null_resource" "wait_for_vault" {
  depends_on = [time_sleep.wait_for_vault_container]

  # triggers：让这个 null_resource（以及所有依赖它的资源，
  # 比如下面的 vault_mount/vault_policy）在 docker_container.vault
  # 被替换时也跟着重新创建。
  #
  # 这是本项目实测踩过的一个真实的坑：Vault Dev 模式的数据完全存在
  # 内存里，一旦容器被替换（比如镜像更新导致 image_id 变化），
  # 里面所有的 mount/secret 都会清空——但 null_resource 本身默认
  # "创建过一次就不会再变"，不会因为它依赖的上游资源被替换而自动
  # 重新执行。如果不加 triggers，会出现"Terraform State 认为
  # mount/secret 都还在，但实际 Vault 容器是全新的、内部什么都没有"
  # 这种状态与现实不一致的情况——表现为后续操作报
  # "no handler for route" 这类"看起来资源存在、实际访问不到"的诡异错误。
  triggers = {
    vault_container_id = docker_container.vault.id
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = "SilentlyContinue"
      for ($i = 0; $i -lt 15; $i++) {
        try {
          $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8200/v1/sys/health" -UseBasicParsing -TimeoutSec 3
          if ($resp.StatusCode -eq 200) { Write-Host "Vault is ready."; exit 0 }
        } catch {}
        Start-Sleep -Seconds 2
      }
      Write-Error "Vault did not become ready in time."
      exit 1
    EOT
  }
}

# --------------------------------------------------------------
# vault_mount：把 KV 版本 2 的 Secret Engine 挂载到 "learning-secret/" 路径。
# v2 相比 v1 的关键区别是支持"版本历史"——每次覆盖写入同一个 key，
# 旧版本不会立刻丢失，可以像 Git 一样查看/回滚到历史版本。
#
# 注意：路径特意没有用看起来更"顺手"的 "secret"——Vault 的开发模式
# （Dev Mode）启动时会自动预先挂载一个名叫 "secret/" 的 kv-v2 引擎，
# 如果这里也用 "secret" 作为路径，会和这个自动挂载冲突，报
# "path is already in use at secret/"（这是本项目实测踩到的坑）。
# 用一个不同的路径名，既避免冲突，也更明确地表达"这是我们自己
# 声明式创建的挂载，不是依赖 Dev Mode 隐式提供的那一个"。
# --------------------------------------------------------------
resource "vault_mount" "kv" {
  path        = "learning-secret"
  type        = "kv-v2"
  description = "Terraform Learning Lab 的演示用 KV Secret Engine"

  depends_on = [null_resource.wait_for_vault]
}

# --------------------------------------------------------------
# vault_policy：定义"只能读 secret/data/app/* 路径下内容"的策略。
# 策略本身用 Vault 自己的 HCL 方言书写（和 Terraform HCL 语法类似，
# 但含义完全不同——这里的 "path" block 描述的是 Vault 内部的
# 访问控制规则，不是 Terraform 资源）。
# --------------------------------------------------------------
resource "vault_policy" "app_read_only" {
  name = "app-read-only"

  policy = <<-EOT
    path "learning-secret/data/app/*" {
      capabilities = ["read"]
    }
  EOT

  # 和 vault_mount.kv 一样，这个资源和 Vault 容器之间也没有任何
  # 参数引用，Terraform 无法自动推断"必须等 Vault 就绪"这层依赖，
  # 必须显式声明——本项目实测：漏掉这一行会导致 Terraform 尝试
  # 和其他资源并发创建它，在容器还没就绪时抢先发起请求而失败。
  depends_on = [null_resource.wait_for_vault]
}

# --------------------------------------------------------------
# 重要陷阱：这里把一个"真实密码"写进了 vault_kv_secret_v2 资源，
# 这意味着它会被 Terraform 完整记录进 terraform.tfstate——
# 也就是说，**即使我们的目的是"用 Vault 集中管理密码，
# 不要让密码散落在别处"，一旦通过 Terraform 资源写入这个密码，
# 它依然会出现在 Terraform State 里**，这和 09-vault-basics.md
# 里强调的"sensitive 不能保护 State"是同一个问题的另一种表现形式。
#
# 真实项目里更推荐的做法：Terraform 只负责创建 Secret Engine 和
# Policy 这些"结构"，真正的密码值由人工、CI/CD 密钥管理、
# 或应用自己的初始化逻辑写入 Vault（不经过 Terraform apply），
# 这样 Terraform State 里就不会出现任何真实密码。
# 本章为了演示完整对比，特意保留这个"反面教材"写法，
# 并在 README 的验证环节让你亲手确认这一点。
# --------------------------------------------------------------
resource "vault_kv_secret_v2" "db_credentials" {
  mount = vault_mount.kv.path
  name  = "app/database"

  data_json = jsonencode({
    username = "app_user"
    password = var.db_password
  })
}

# --------------------------------------------------------------
# vault_token：签发一个只绑定 app_read_only 策略的短期 Token，
# 模拟"应用程序拿到的凭证"——它只能读 secret/data/app/* 路径，
# 读不了任何其他内容，即使它知道 Vault 地址也无法访问超出授权范围的数据。
# --------------------------------------------------------------
resource "vault_token" "app_token" {
  policies  = [vault_policy.app_read_only.name]
  ttl       = "1h"
  renewable = true

  metadata = {
    purpose = "terraform-learning-lab-demo-app"
  }
}
