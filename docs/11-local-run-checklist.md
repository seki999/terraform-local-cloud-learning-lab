# Local Run Checklist — Windows 11 + WSL2 + Docker Desktop

本文档的目标是：**在开始课程前先发现环境问题，而不是学到一半才发现缺软件或端口冲突。**

## 1. 先运行一键检查

从仓库根目录打开 PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\preflight.ps1
```

脚本只读检查，不安装、不删除、不修改任何配置。

红色 `FAIL` 建议先全部修复。黄色 `WARN` 大多是某些高级章节才需要。

## 2. 主线最低环境

必须能正常执行：

```powershell
terraform version
docker version
docker info
git --version
kubectl version --client
minikube version
kind version
helm version
wsl --version
```

Docker 必须使用 Linux containers。

## 3. WSL2

查看：

```powershell
wsl -l -v
```

推荐：

```text
* Ubuntu    Running/Stopped    2
```

如果默认项不是正常 Ubuntu/Debian Linux，而是特殊发行版，请设置 Ubuntu 为默认：

```powershell
wsl --set-default Ubuntu
```

`10-networking/03-linux-routing` 会直接在默认 WSL 发行版里创建 Linux network namespaces。

## 4. WSL 网络工具

Ubuntu：

```bash
sudo apt update
sudo apt install -y \
  iproute2 iputils-ping dnsutils traceroute tcpdump \
  netcat-openbsd nftables iperf3 openssl curl python3
```

协议实验可追加：

```bash
sudo apt install -y snmp snmptrapd rsyslog wireguard-tools
```

Containerlab + FRRouting 是高级实验，先不安装也不影响主线前半部分。

## 5. 建议第一次按这个顺序运行

```text
01-terraform-basics
02-docker
03-minikube
04-kind
05-kubernetes
06-helm
10-networking
15-protocol-stack
16-network-commands
08-monitoring
09-vault
11-modules
12-state-management
13-testing
14-full-local-cloud
```

`07-localstack` 为可选章节。

## 6. 章节切换时最容易出现的问题

### Minikube 与 Kind context

确认当前 context：

```powershell
kubectl config current-context
kubectl config get-contexts
```

大多数 Kind 章节的 Terraform Provider明确使用：

```text
kind-terraform-lab
```

因此即使 kubectl 当前 context 不是 Kind，Terraform 仍会按 provider 配置访问指定 Kind context；但是你手工运行的 kubectl 命令可能会访问当前 context，所以排障时要特别注意。

### Ingress Controller 重复

`05-kubernetes/10-ingress` 可以手动安装 ingress-nginx，`06-helm` 默认也会安装 ingress-nginx。

不要同时保留两套。

如果 05 已安装，可以先卸载，或者运行 06 时设置：

```hcl
install_ingress_nginx = false
```

### Monitoring 需要 port-forward

运行 `08-monitoring` 前，在另一个 PowerShell 保持：

```powershell
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

关闭这个终端后，Terraform Grafana Provider 就无法访问 Grafana API。

### Vault 端口

`09-vault` 使用 8200。

`14-full-local-cloud` 使用 8201。

如果有残留容器：

```powershell
docker ps -a
```

先确认对应章节是否已经 `terraform destroy`。

## 7. NetworkPolicy 的已知限制

默认 Kind 使用 kindnet。课程中的 NetworkPolicy 对象可以创建，但默认环境不保证真正执行流量隔离。

因此：

- 学 API/对象结构：默认 Kind 可以。
- 真正验证 allow/deny：需要支持 NetworkPolicy 的 CNI，例如 Calico。

不要因为 blocked client 仍然可达就误以为 Terraform 配错。

## 8. 新增网络/协议章节的自动化程度

目前分三类：

### A. 可直接 Terraform 运行

例如：

```text
10-networking/03-linux-routing
```

Terraform 会调用 WSL2，在 Linux 内真实创建 namespace/veth/route。

### B. 已有运行环境，在里面执行命令

例如协议和命令章节：

```text
15-protocol-stack
16-network-commands
```

它们主要复用 WSL2、Docker、Kind 和 10-networking 创建的环境，通过 `ping`、`dig`、`curl`、`tcpdump` 等真实命令观察协议。

### C. 高级实验目前仍需手工准备

例如：

```text
WireGuard
Containerlab
FRRouting
部分 SNMP/Syslog receiver
```

这些章节目前是可执行教程，但还没有全部包装成“一次 terraform apply 自动搭完”。

## 9. 资源容量

Kind 的 1 control-plane + 2 workers、Prometheus/Grafana/Loki、Vault 与普通实验容器可以同时占用数 GB 内存。

如果运行 Monitoring 时出现 Pod Pending/OOM：

```powershell
kubectl get pods -A
kubectl describe pod <pod> -n <namespace>
docker stats
```

建议不要把所有章节的环境永久同时保留；完成一章后按 README 执行 `terraform destroy`。

## 10. Terraform lock file

如果某章最近修改过 Provider 列表，第一次运行：

```powershell
terraform init -upgrade
```

Terraform 会根据当前 `required_providers` 更新 `.terraform.lock.hcl`。之后日常运行再使用普通 `terraform init` 即可。

## 11. 开始之前的最终确认

下面全部 OK，就可以开始：

```text
[ ] preflight 没有 FAIL
[ ] Docker Desktop running
[ ] Docker Linux containers
[ ] WSL2 默认发行版是正常 Ubuntu/Debian Linux
[ ] terraform / kubectl / minikube / kind / helm 都能执行
[ ] WSL 中 ip / ping / curl / python3 / openssl 可执行
[ ] 需要抓包时已经安装 tcpdump
[ ] 需要 DNS 深入实验时已经安装 dig
[ ] 常用端口没有被旧实验占用
```
