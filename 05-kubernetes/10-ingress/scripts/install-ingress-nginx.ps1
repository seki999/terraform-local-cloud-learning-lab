<#
  install-ingress-nginx.ps1
  ------------------------------------------------------------
  在 Kind 集群上安装 ingress-nginx Controller。
  这一步刻意用官方 kubectl 清单完成，而不是 Terraform——
  原因是 06-helm 章节会专门演示"用 Terraform Helm Provider
  安装 ingress-nginx"，这里先用最简单的方式让本实验独立可跑，
  避免 05 章节提前依赖还没学到的 Helm 概念。

  参考: https://kind.sigs.k8s.io/docs/user/ingress/
#>

kubectl --context kind-terraform-lab apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

Write-Host "==> 等待 ingress-nginx Controller 就绪（可能需要 1-2 分钟）..." -ForegroundColor Cyan
kubectl --context kind-terraform-lab wait --namespace ingress-nginx `
  --for=condition=ready pod `
  --selector=app.kubernetes.io/component=controller `
  --timeout=180s

Write-Host "ingress-nginx 就绪。" -ForegroundColor Green
