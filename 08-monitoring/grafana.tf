# ============================================================
# grafana.tf —— 用 Terraform Grafana Provider 以代码管理 Grafana
# ------------------------------------------------------------
# 这是本章真正的教学重点：Data Source / Folder / Dashboard /
# Alert Rule / Contact Point 全部由 Terraform 声明式创建，
# 而不是在 Grafana 网页 UI 里手工点击配置——这同样是 Infrastructure
# as Code，只不过管理的对象从"一台虚拟机"变成了"一个仪表盘定义"。
# 好处：可版本控制、可复现、销毁重建整个监控栈后一键恢复所有配置。
# ============================================================

# --------------------------------------------------------------
# data source（只读）：查询 kube-prometheus-stack 自动创建的
# Prometheus Data Source。它不是本章创建的，而是 06-helm 里
# helm_release.kube_prometheus_stack 的 Grafana 子 Chart 自动
# provision 出来的——这里只是"读取"它的 UID，供下面的 Dashboard/
# Alert 引用，不需要我们重新创建一个功能重复的 Data Source。
# --------------------------------------------------------------
data "grafana_data_source" "prometheus" {
  name = "Prometheus"
}

# --------------------------------------------------------------
# Loki 是本章新创建的，所以这里用 resource（而不是 data source）
# 显式声明它作为 Grafana 的 Data Source。
# --------------------------------------------------------------
resource "grafana_data_source" "loki" {
  type = "loki"
  name = "Loki"
  url  = "http://loki.monitoring.svc.cluster.local:3100"

  depends_on = [helm_release.loki]
}

resource "grafana_folder" "learning_lab" {
  title = "Terraform Learning Lab"
}

resource "grafana_dashboard" "cluster_overview" {
  folder = grafana_folder.learning_lab.uid

  config_json = templatefile("${path.module}/dashboards/cluster-overview.json.tftpl", {
    prometheus_uid = data.grafana_data_source.prometheus.uid
    loki_uid       = grafana_data_source.loki.uid
  })
  # templatefile 在这里的作用和 02-docker 章节渲染 nginx.conf 完全一样：
  # 把"这个 Data Source 的 UID 是多少"这种只有 apply 时才知道的值，
  # 注入进一份原本是纯静态 JSON 的 Dashboard 定义里。
}

# --------------------------------------------------------------
# Contact Point：告警最终通知给谁。教学环境不配置真实的
# 邮件服务器，只声明配置本身（Grafana 允许创建 Contact Point
# 而不要求邮件地址真实可达）。
# --------------------------------------------------------------
resource "grafana_contact_point" "demo_email" {
  name = "learning-lab-demo-contact"

  email {
    addresses = ["demo-alerts@example.com"]
    message   = "Terraform Learning Lab 告警通知（教学占位邮箱，非真实收件地址）"
  }
}

# --------------------------------------------------------------
# Alert Rule：基于 Prometheus 的 up 指标，检测"有目标被 Prometheus
# 判定为不可达（up == 0）"这一最基础、最常用的告警场景。
#
# Grafana 统一告警（Unified Alerting）的规则结构分两部分：
#   data 块 A —— 真正去 Prometheus 查询数据（up 指标）；
#   data 块 C —— 用 Grafana 内置的 "__expr__" 表达式引擎，
#                对 A 的查询结果做阈值判断，产出最终的告警条件；
#   condition = "C" 告诉 Grafana："以 C 这个数据块的结果作为
#                最终判断这条规则是否触发的依据"。
# 这种"查询"和"判断条件"分离的设计，让同一份查询结果可以喂给
# 多种不同的判断逻辑（阈值、变化率等），而不需要在查询语句本身
# 里塞进复杂的告警判断表达式。
# --------------------------------------------------------------
resource "grafana_rule_group" "basic_alerts" {
  name             = "learning-lab-basic-alerts"
  folder_uid       = grafana_folder.learning_lab.uid
  interval_seconds = 60

  rule {
    name           = "TargetDown"
    for            = "2m"
    condition      = "C"
    no_data_state  = "NoData"
    exec_err_state = "Error"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = data.grafana_data_source.prometheus.uid
      model = jsonencode({
        expr          = "up == 0"
        instant       = true
        intervalMs    = 1000
        maxDataPoints = 100
        refId         = "A"
      })
    }

    data {
      ref_id = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      datasource_uid = "__expr__"
      model = jsonencode({
        type       = "threshold"
        expression = "A"
        conditions = [
          {
            evaluator = {
              type   = "gt"
              params = [0]
            }
          }
        ]
        refId = "C"
      })
    }

    annotations = {
      summary = "存在被 Prometheus 判定为 down 的抓取目标"
    }
    labels = {
      severity = "warning"
    }
  }
}
