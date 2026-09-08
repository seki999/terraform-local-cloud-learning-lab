<#
  start-minikube.ps1
  ------------------------------------------------------------
  这个脚本只负责"把 Minikube 集群本身启动好"，不涉及任何
  Terraform 管理的应用资源——刻意把这两件事分开：
    - Minikube 集群的生命周期（本脚本，一次性的基础设施准备工作）
    - 集群里的应用资源（main.tf，反复 apply/destroy 的学习对象）
  这样你可以放心地对 main.tf 做 destroy/apply 实验，
  而不用担心把整个 Minikube 集群也搞没了。
#>

Write-Host "==> 检查 Minikube 状态..." -ForegroundColor Cyan
$status = minikube status --format '{{.Host}}' 2>$null

if ($status -ne "Running") {
    Write-Host "==> 启动 Minikube 集群..." -ForegroundColor Cyan
    minikube start
} else {
    Write-Host "==> Minikube 已经在运行。" -ForegroundColor Green
}

Write-Host "==> 启用 ingress addon（Ingress 资源需要它才能生效）..." -ForegroundColor Cyan
minikube addons enable ingress

Write-Host "==> 修正 kubectl context（避免 kubeconfig 端口信息过期）..." -ForegroundColor Cyan
minikube update-context

Write-Host "==> 当前节点状态：" -ForegroundColor Cyan
kubectl get nodes

Write-Host "`n准备就绪，可以进入本章目录执行 terraform init / plan / apply 了。" -ForegroundColor Green
