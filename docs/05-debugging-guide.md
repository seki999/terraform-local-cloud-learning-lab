# 05 - 常见问题排查手册（Debugging Guide）

统一格式：**现象 / 原因 / 检查命令 / 解决方法**。遇到问题先在这里搜索关键字。

---

## 1. Provider initialization failed（Provider 初始化失败）

**现象**：`terraform init` 报类似
`Failed to install provider` / `Error: Failed to query available provider packages`。

**原因**：网络无法访问 Terraform Registry（`registry.terraform.io`），
或者 `required_providers` 里的版本约束/来源写错了。

**检查命令**：
```powershell
terraform providers
Test-NetConnection registry.terraform.io -Port 443
```

**解决方法**：确认网络可以访问 HashiCorp Registry；检查
`versions.tf` 里 `source` 拼写是否正确（例如 Docker Provider 的正确来源是
`kreuzwerker/docker` 而不是 `hashicorp/docker`）；必要时删除 `.terraform/` 目录
和 `.terraform.lock.hcl` 后重新 `terraform init`。

---

## 2. Docker daemon unavailable（连接不上 Docker）

**现象**：`Error: Cannot connect to the Docker daemon`，或 Terraform apply 时
Docker Provider 报连接被拒绝。

**原因**：Docker Desktop 没有启动，或还在启动中。

**检查命令**：
```powershell
docker version
docker ps
```

**解决方法**：打开 Docker Desktop，等待左下角图标变绿（Running）后再重试。
如果长期无法启动，检查 WSL2 是否正常：`wsl --status`。

---

## 3. Minikube unavailable / 无法连接集群

**现象**：`kubectl get pods` 报 `The connection to the server ... was refused`。

**原因**：Minikube 集群没启动，或启动后又被 Docker Desktop 重启打断。

**检查命令**：
```powershell
minikube status
kubectl config current-context
```

**解决方法**：
```powershell
minikube start
```
如果反复失败，尝试 `minikube delete` 后重新 `minikube start`
（这会清空该集群的所有资源，注意先确认没有未保存的实验数据）。

---

## 4. kubectl context 不正确

**现象**：命令在 Minikube 集群上执行了，但你以为自己在 Kind 集群上（或反之）。

**原因**：`kubectl` 通过"当前 context"决定连哪个集群，多集群环境下很容易搞混。

**检查命令**：
```powershell
kubectl config get-contexts
kubectl config current-context
```

**解决方法**：
```powershell
kubectl config use-context <目标 context 名称>
```
建议在每章实验开始前，先跑一遍这条命令确认 context，避免在错误的集群上操作。

---

## 5. Kubernetes connection refused（Terraform Kubernetes Provider 连不上）

**现象**：`terraform apply` 时 Kubernetes Provider 报
`connection refused` 或 `unable to load kubeconfig`。

**原因**：Terraform 的 `provider "kubernetes"` block 里 `config_path` 没指对，
或者对应集群没启动。

**检查命令**：
```powershell
kubectl cluster-info
echo $env:KUBECONFIG
```

**解决方法**：确认 `provider "kubernetes" { config_path = "~/.kube/config" }`
指向的文件存在且集群可达；确认 `config_context` 参数（如果设置了）拼写正确。

---

## 6. 端口冲突（Port already in use / bind: address already in use）

**现象**：`docker_container` 或 `kubernetes_service` 创建失败，提示端口已被占用。

**原因**：本机另一个进程（甚至是上一次没有正确 destroy 的实验）占用了同一个端口。

**检查命令**：
```powershell
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
docker ps --filter "publish=8080"
```

**解决方法**：修改本章 `variables.tf` 里的端口变量，或
`docker stop <容器名>` / `terraform destroy` 清理占用端口的旧资源。

---

## 7. Terraform state locked（State 被锁）

**现象**：`Error acquiring the state lock`。

**原因**：上一次 `terraform apply/plan` 被强制中断（比如 Ctrl+C 后进程未完全退出），
锁没有被正常释放。本地 Backend 下这种情况较少见，但仍可能发生。

**检查命令**：
```powershell
Get-Process terraform -ErrorAction SilentlyContinue
```

**解决方法**：确认确实没有其他 Terraform 进程还在运行后，可以用
`terraform force-unlock <LOCK_ID>`（LOCK_ID 会显示在报错信息里）。
**谨慎使用**——如果真的有另一个进程在写 State，强制解锁可能导致 State 损坏。

---

## 8. Resource already exists（资源已存在）

**现象**：`apply` 报错说要创建的资源已经存在（例如同名 Docker 网络、
同名 Kubernetes Namespace）。

**原因**：这个资源是之前手工创建的，或者是被别的 Terraform 配置管理的，
不在当前的 State 里，Terraform 不知道它已经存在，于是尝试重新创建。

**检查命令**：
```bash
terraform state list
```

**解决方法**：如果这个资源确实应该由当前配置管理，使用
`terraform import`（见 [03-terraform-state.md](03-terraform-state.md)）把它
纳入 State，而不是手工删除后重建。

---

## 9. Provider version conflict（Provider 版本冲突）

**现象**：`Error: Failed to install provider — no available releases match the given constraints`。

**原因**：`versions.tf` 里的版本约束和已经写好的 `.terraform.lock.hcl` 不兼容，
或者本地缓存的 Provider 版本过旧。

**检查命令**：
```bash
terraform version
cat .terraform.lock.hcl
```

**解决方法**：调整 `required_providers` 里的版本约束范围，然后运行
`terraform init -upgrade` 重新解析并更新 lock 文件。

---

## 10. PowerShell 执行策略阻止脚本运行

**现象**：`无法加载文件 xxx.ps1，因为在此系统上禁止运行脚本`。

**原因**：Windows 默认执行策略限制未签名脚本运行。

**解决方法**：
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 11. Windows 路径问题

**现象**：涉及本地文件路径的资源（比如 `local_file`、挂载卷路径）在 Windows 上
报路径找不到，或者路径里的反斜杠 `\` 导致 HCL 字符串转义混乱。

**原因**：HCL 字符串里 `\` 是转义字符，Windows 路径的 `\` 会被误解析。

**解决方法**：Terraform 配置里的路径统一使用正斜杠 `/`
（例如 `C:/Users/xxx/data`），Terraform 在 Windows 上同样能正确识别正斜杠路径。
如果一定要用反斜杠，需要写成 `\\` 转义，或改用
[`path`](https://developer.hashicorp.com/terraform/language/expressions/references#filesystem-and-workspace-info)
系列内置变量拼接。

---

## 12. `localhost` 在某些 Provider 里连不上，但浏览器/curl 能打开（IPv4/IPv6 解析不一致）

**现象**：浏览器或 `curl http://localhost:PORT` 能正常访问某个本地容器
（比如 07-localstack、09-vault 章节的 LocalStack/Vault 容器），
但 Terraform 某个 Provider（本项目实测是 `hashicorp/vault`）报
`dial tcp [::1]:PORT: connectex: No connection could be made`。

**原因**：Windows 上 `localhost` 可能被解析成 IPv4 的 `127.0.0.1`
或 IPv6 的 `::1`，取决于具体发起连接的程序如何处理"Happy Eyeballs"
（同时尝试多个地址族并使用最先成功的）这套逻辑。有些用 Go 编写的
CLI/Provider 在特定版本/配置下会优先甚至只尝试 IPv6，而 Docker
Desktop 对"发布端口"的 IPv6 环回转发支持不如 IPv4 可靠——于是
IPv6 连接被拒绝，但同一台机器上用浏览器或 PowerShell 的
`Invoke-WebRequest`（更倾向优先 IPv4）访问同一个端口却完全正常，
造成"服务明明是好的，为什么 Terraform 连不上"的困惑。

**检查命令**：
```powershell
Test-NetConnection 127.0.0.1 -Port <端口>
Test-NetConnection ::1 -Port <端口>
```
如果第一条成功、第二条失败（或反过来），就确认了是地址族的问题。

**解决方法**：在所有 Terraform Provider 的连接地址里，统一显式使用
`127.0.0.1` 而不是 `localhost`，强制走 IPv4，避免这种不确定性
——本项目 07-localstack 和 09-vault 章节的 Provider 配置都采用了
这个写法，可以直接参考。

## 13. Kubernetes Pod 报 `executable file not found in $PATH`，CrashLoopBackOff

**现象**：`kubernetes_deployment`/`kubernetes_pod` 资源里给容器传了
启动参数（比如 `["-listen=:5678", "-text=hello"]`），Pod 一直
`CrashLoopBackOff`，`kubectl describe pod` 里能看到
`OCI runtime create failed: ... exec: "-listen=:5678": executable file not found in $PATH`。

**原因**：这是本项目实测踩过的坑——`command` 字段在
**Kubernetes** 和在 **Docker** 里的含义不一样：
- Kubernetes 的 `command` 会**覆盖镜像的 ENTRYPOINT**
  （相当于 `docker run --entrypoint`）；
- Kubernetes 的 `args` 才是**追加在 ENTRYPOINT 后面的参数**
  （相当于 Docker 的 CMD）。

如果镜像的 ENTRYPOINT 就是它自己的可执行文件（比如
`hashicorp/http-echo`），把启动参数写进 Kubernetes 的 `command`
字段，等于告诉容器"把这段参数字符串当成可执行文件来运行"，
自然会报"找不到这个可执行文件"。

**解决方法**：如果只是想传参数、不想替换掉 ENTRYPOINT，改用
`args` 字段。只有确实需要完全替换 ENTRYPOINT 时才用 `command`。

## 14. `terraform destroy` 报 `BucketNotEmpty`

**现象**：`aws_s3_bucket` 相关的 `destroy` 报
`api error BucketNotEmpty: The bucket you tried to delete is not empty`。

**原因**：S3（真实 AWS 和 LocalStack 行为一致）默认拒绝删除非空的桶，
这是防止误删数据的安全设计。如果这个桶在使用过程中被写入过对象
（比如 07-localstack 章节的 Lambda 会往桶里 `put_object`），
`destroy` 时 Terraform 请求删除桶本身，但桶里还有对象，请求被拒绝。

**解决方法**：给 `aws_s3_bucket` 资源加上 `force_destroy = true`，
让 Terraform 在删除 bucket 前自动先清空里面的所有对象。
**生产环境要谨慎使用**——这意味着"删除这个资源定义"就能连带清空
所有数据，对存有重要数据的桶，通常更希望保留"必须先手动清空"
这层保护，而不是设置 `force_destroy`。

## 15. WSL2 相关问题

**现象**：Docker Desktop 启动缓慢、容器网络异常、或者 Kind/Minikube 里
DNS 解析失败。

**检查命令**：
```powershell
wsl --status
wsl --list --verbose
wsl --update
```

**解决方法**：确保 WSL2（不是 WSL1）作为 Docker Desktop 的后端；
必要时执行 `wsl --shutdown` 完全重启 WSL2 子系统，再重新打开 Docker Desktop。
