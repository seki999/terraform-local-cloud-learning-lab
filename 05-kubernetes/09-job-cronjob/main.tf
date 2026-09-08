# ============================================================
# main.tf —— Job（一次性任务）与 CronJob（定时任务）
# ============================================================

resource "kubernetes_namespace" "this" {
  metadata {
    name = "learning-05-job"
  }
}

# --------------------------------------------------------------
# Job：运行到"成功完成"为止的一次性任务，不是"一直运行的服务"。
# 这是 Job 和 Deployment 最本质的区别——Deployment 假设容器应该
# 永远运行（挂了就重启），Job 假设容器"跑完退出（exit 0）就算成功"。
# --------------------------------------------------------------
resource "kubernetes_job" "one_off" {
  metadata {
    name      = "one-off-task"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    completions = 1 # 需要成功完成的总次数
    parallelism = 1 # 同一时刻最多并发运行几个 Pod
    backoff_limit = 3
    # backoff_limit：任务失败后允许重试的次数上限，
    # 超过这个次数 Job 会被标记为失败，不再继续重试。

    template {
      metadata {
        labels = { app = "one-off-task" }
      }
      spec {
        # Job 的 Pod 必须显式设置 restart_policy 为 Never 或
        # OnFailure（不能是 Always，因为"一直重启的一次性任务"
        # 在逻辑上是矛盾的——Always 是 Deployment 用的默认值）。
        restart_policy = "Never"

        container {
          name    = "task"
          image   = "busybox:1.36"
          command = ["sh", "-c", "echo 'Doing some one-off work...'; sleep 3; echo 'Done.'"]
        }
      }
    }
  }

  wait_for_completion = true
}

# --------------------------------------------------------------
# CronJob：按 cron 表达式周期性地创建 Job。
# 这里设置成"每分钟运行一次"，方便你在几分钟内就能观察到多次执行历史，
# 真实场景里更常见的是"每天凌晨跑一次批处理""每小时同步一次数据"这类周期。
# --------------------------------------------------------------
resource "kubernetes_cron_job_v1" "periodic" {
  metadata {
    name      = "periodic-task"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    schedule = "*/1 * * * *" # 标准 5 段 cron 表达式：每分钟触发一次

    # 保留多少个历史 Job 记录，避免无限堆积
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 1

    job_template {
      metadata {}
      spec {
        template {
          metadata {
            labels = { app = "periodic-task" }
          }
          spec {
            restart_policy = "OnFailure"
            container {
              name    = "task"
              image   = "busybox:1.36"
              command = ["sh", "-c", "echo \"periodic run at $(date)\""]
            }
          }
        }
      }
    }
  }
}
