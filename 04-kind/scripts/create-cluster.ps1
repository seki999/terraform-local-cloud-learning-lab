<#
  create-cluster.ps1
  ------------------------------------------------------------
  和 03-minikube 的 start-minikube.ps1 一样，集群本身的创建/销毁
  独立于 Terraform 管理——Terraform 只负责集群"里面"的工作负载。

  集群名固定为 terraform-lab（对应 kubectl context "kind-terraform-lab"），
  刻意避免使用常见的默认名字，防止和你机器上可能已经存在的
  其他 Kind 集群（比如名叫 "k8s-learning" 的集群）冲突。
#>

$ClusterName = "terraform-lab"

$existing = kind get clusters 2>$null
if ($existing -contains $ClusterName) {
    Write-Host "==> 集群 '$ClusterName' 已存在，跳过创建。" -ForegroundColor Green
} else {
    Write-Host "==> 创建 1 control-plane + 2 worker 的 Kind 集群 '$ClusterName' ..." -ForegroundColor Cyan
    kind create cluster --name $ClusterName --config "$PSScriptRoot\..\kind-config.yaml"
}

Write-Host "==> 节点列表与标签：" -ForegroundColor Cyan
kubectl --context "kind-$ClusterName" get nodes --show-labels

Write-Host "`n准备就绪，可以进入本章目录执行 terraform init / plan / apply 了。" -ForegroundColor Green
