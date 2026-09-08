# ============================================================
# outputs.tf
# ============================================================

output "grafana_dashboard_url" {
  value = "${var.grafana_url}/d/${grafana_dashboard.cluster_overview.uid}"
}

output "loki_push_example" {
  description = "从集群内部向 Loki 推送一条测试日志的示例命令（模拟应用日志上报）"
  value       = "kubectl run -it --rm loki-push-test --image=curlimages/curl:8.10.1 --restart=Never -n monitoring -- curl -s -XPOST http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push -H 'Content-Type: application/json' -d '{\"streams\":[{\"stream\":{\"job\":\"manual-test\"},\"values\":[[\"'$(date +%s%N)'\",\"hello from terraform-local-cloud-learning-lab\"]]}]}'"
}

output "loki_datasource_uid" {
  value = grafana_data_source.loki.uid
}

output "prometheus_datasource_uid" {
  value = data.grafana_data_source.prometheus.uid
}
