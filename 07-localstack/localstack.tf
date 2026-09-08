# ============================================================
# localstack.tf —— 用 Terraform Docker Provider 启动 LocalStack 本身
# ------------------------------------------------------------
# 这里刻意复用第 2 章学过的 Docker Provider——LocalStack 说到底
# "只是"一个 Docker 容器，用同一套工具管理它，呼应本项目
# "Terraform 统一编排一切本地组件"的核心理念。
# ============================================================

resource "docker_image" "localstack" {
  name         = "localstack/localstack:3.8"
  keep_locally = true
}

resource "docker_container" "localstack" {
  name  = "localstack-learning-lab"
  image = docker_image.localstack.image_id

  ports {
    internal = 4566
    external = 4566
    # 4566 是 LocalStack 的"统一网关端口"——所有服务（S3/DynamoDB/
    # SQS/...）共用这一个端口，LocalStack 内部根据请求的路径/
    # 签名信息路由到对应的模拟实现，这也是为什么 versions.tf 里
    # 每个 endpoint 都写的是同一个地址。
  }

  env = [
    "SERVICES=${var.localstack_services}",
    "DEBUG=0",
    "PERSISTENCE=0",
    # PERSISTENCE=0：容器销毁后数据不保留（教学环境不需要持久化，
    # 每次都是全新状态，方便反复 destroy/apply 实验）。
    "LAMBDA_EXECUTOR=docker",
    # LAMBDA_EXECUTOR=docker：Lambda 函数在独立的 Docker 容器里执行
    # （而不是在 LocalStack 主进程里直接跑一段代码），这更接近真实
    # AWS Lambda"每次调用都是隔离沙箱"的执行模型，但也意味着
    # LocalStack 需要能够启动新的 Docker 容器——这就是下面为什么
    # 要把宿主机的 Docker socket 挂载进 LocalStack 容器内部
    # （"Docker outside of Docker"模式）。
  ]

  volumes {
    host_path      = "//var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    # 注意路径写成 "//var/run/docker.sock"（双斜杠开头）——
    # 这是 Windows 上 Docker Desktop 的一个已知怪癖：Docker Desktop
    # 在 Windows 上会把单斜杠开头的绝对路径误认为需要做盘符转换，
    # 双斜杠可以绕开这个转换逻辑，正确挂载到 Docker Desktop 后端
    # （WSL2 Linux VM）里真实的 docker.sock。
    # 详见 docs/05-debugging-guide.md 第 11 条"Windows 路径问题"。
  }

  restart = "unless-stopped"
}

# --------------------------------------------------------------
# LocalStack 容器启动后，内部服务需要几秒钟完成初始化，
# 直接创建 AWS 资源可能会遇到连接被拒绝。用 null_resource +
# local-exec 轮询健康检查端点，等 LocalStack 真正就绪后，
# 再让后面所有 aws_* 资源通过 depends_on 排在它后面创建。
#
# 这是一个很常见的真实工程模式：Terraform 本身没有"等待某个
# 外部服务变健康"的原生机制，遇到这种"基础设施需要额外启动时间"
# 的场景，null_resource + 轮询脚本是最直接的应对办法。
# --------------------------------------------------------------
resource "time_sleep" "wait_for_container_start" {
  depends_on      = [docker_container.localstack]
  create_duration = "5s"
}

resource "null_resource" "wait_for_localstack" {
  depends_on = [time_sleep.wait_for_container_start]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = "SilentlyContinue"
      $maxAttempts = 24
      for ($i = 0; $i -lt $maxAttempts; $i++) {
        try {
          $resp = Invoke-WebRequest -Uri "http://127.0.0.1:4566/_localstack/health" -UseBasicParsing -TimeoutSec 3
          if ($resp.StatusCode -eq 200) {
            Write-Host "LocalStack is ready."
            exit 0
          }
        } catch {}
        Start-Sleep -Seconds 5
      }
      Write-Error "LocalStack did not become ready in time."
      exit 1
    EOT
  }
}
