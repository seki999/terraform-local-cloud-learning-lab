<#
  create-manual-container.ps1
  ------------------------------------------------------------
  模拟"这个容器是有人在 Terraform 之外手工创建的"这一真实场景
  ——比如一个同事很久以前手工跑了一个容器，现在团队想把它
  纳入 Terraform 管理，但不希望销毁重建（可能它还在提供服务）。
#>

docker run -d --name manually-created-nginx -p 8099:80 nginx:1.27-alpine

Write-Host "`n手工容器已创建。现在进入 12-state-management/01-import 目录，" -ForegroundColor Green
Write-Host "按照 README 的步骤，把它 import 进 Terraform State。" -ForegroundColor Green
