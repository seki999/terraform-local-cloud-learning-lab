<#
  delete-cluster.ps1
  ------------------------------------------------------------
  彻底删除本章使用的 Kind 集群。请先执行 `terraform destroy`
  清理集群内的工作负载，再运行这个脚本删除集群本身
  ——两者分开操作，避免"集群都没了，Terraform 却还以为
  资源存在"的 State 不一致情况（如果真的发生了，
  参考 12-state-management 里关于清理"孤儿 State"的做法）。
#>

$ClusterName = "terraform-lab"
kind delete cluster --name $ClusterName
