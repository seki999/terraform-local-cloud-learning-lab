# Terraform Local Cloud Learning Lab

> 一个完全在本地运行、尽量不依赖真实收费云的 **Terraform + Kubernetes + Docker + Linux Networking + DevOps 中文实践课程**。

## 项目定位

这个仓库的核心不再是“模拟 AWS”，而是学习真正可以迁移到云环境的基础设施能力：

- Terraform / IaC
- Docker 网络与容器
- Minikube / Kind / Kubernetes
- Helm
- Linux Routing / Firewall / NAT / DNS
- Load Balancer / VPN
- Containerlab / FRRouting
- Prometheus / Grafana / Loki
- Vault
- Terraform Module / State / Testing

`07-localstack/` 仍然保留，但现在是**可选的 AWS API 模拟专题**。即使不安装或不购买 LocalStack 的商业功能，主线课程和毕业实验仍然可以完成。

## 核心原则

| 原则 | 说明 |
|---|---|
| 本地优先 | Windows 11 + WSL2 + Docker Desktop 为主要环境 |
| 零云账单主线 | 主线不要求 AWS/Azure/GCP/OCI 账号 |
| 真实数据面 | 网络章节优先使用 Linux namespace、veth、route、nftables、tcpdump |
| 可重复 | Terraform 管理的实验应能 apply / verify / destroy |
| 云概念映射 | 每个本地组件都解释它与 VPC/Subnet/Route/NAT/LB/VPN 等概念的关系 |
| 排障优先 | 不只学习“怎么配”，还要学习“坏了怎么查” |

## 学习路线

```text
Stage 1   Terraform Fundamentals        01-terraform-basics/
Stage 2   Terraform + Docker            02-docker/
Stage 3   Terraform + Minikube          03-minikube/
Stage 4   Terraform + Kind              04-kind/
Stage 5   Kubernetes                    05-kubernetes/
Stage 6   Helm                          06-helm/

Core      Linux / Cloud Networking      10-networking/

Stage 8   Monitoring                    08-monitoring/
Stage 9   Vault                         09-vault/
Stage 10  Terraform Modules             11-modules/
Stage 11  State Management              12-state-management/
Stage 12  Full Local Cloud              14-full-local-cloud/

Optional  LocalStack AWS API Lab        07-localstack/
Optional  Proxmox / libvirt             optional/
```

详细顺序见 [docs/00-learning-roadmap.md](docs/00-learning-roadmap.md)。

## 网络专题

`10-networking/` 已扩展为真正的 Local Network Engineering Lab：

```text
01-docker-network-isolation
02-coredns
03-linux-routing
04-firewall-nat
05-load-balancer
06-vpn
07-containerlab-frr
08-network-troubleshooting
```

其中 `03-linux-routing` 会在 WSL2 Linux 内真正创建：

```text
web 10.10.10.10/24
        |
     10.10.10.1
       router
  10.10.20.1   10.10.30.1
       |             |
app 10.10.20.10   db 10.10.30.10
```

使用的是 Linux network namespace + veth + route + ip_forward，而不是云 API 模拟。

你可以直接观察：

```bash
ip addr
ip route
ip neigh
ping
traceroute
ss
dig
tcpdump
nft
```

## 本地概念与云概念

| 本地技术 | 云端心智模型 |
|---|---|
| Linux namespace / Docker network | VPC/VNet 隔离 |
| CIDR | VPC/Subnet CIDR |
| veth / NIC | ENI / NIC |
| `ip route` | Route Table |
| Linux router | VPC Router / Transit routing |
| nftables | Security Group / NACL 的底层类比 |
| SNAT / masquerade | NAT Gateway |
| CoreDNS | Private DNS / Service Discovery |
| HAProxy / nginx | ALB / NLB |
| WireGuard | Site-to-Site VPN |
| FRRouting | OSPF/BGP/动态路由 |
| Kind | 本地 Kubernetes / EKS 类比 |
| Vault | Secret Manager 类能力 |
| Prometheus/Grafana | Cloud monitoring 类能力 |

这里强调的是概念与数据流映射，不代表具体云产品与本地工具 1:1 等价。

## 环境

主要工具：

- Terraform
- Docker Desktop
- WSL2
- Git
- kubectl
- Minikube / Kind
- Helm

网络高级实验还会用到：

- iproute2
- nftables
- tcpdump
- WireGuard
- Containerlab
- FRRouting

## 常用 Terraform 命令

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
terraform output
terraform destroy
```

## 毕业实验

`14-full-local-cloud/` 已经取消对 LocalStack 的依赖。

现在毕业实验主要验证：

```text
Terraform
   |
   +-- Docker -> Vault
   |
   +-- Kubernetes
          |
          +-- frontend
          +-- backend
          +-- redis
          +-- postgres
          +-- Service / DNS
          +-- Secret <- Vault
```

这样 LocalStack 免费层或商业功能变化不会再阻塞整个课程。

## LocalStack 的角色

`07-localstack/` 没有删除。

它仍然适合单独学习：

- AWS Provider endpoint 重定向
- S3
- DynamoDB
- SQS
- Lambda
- API Gateway
- AWS 风格 API 与 Terraform 的交互

但是它不再是主线，也不再是毕业实验依赖。

## 推荐的网络排障顺序

遇到“网络不通”，统一按下面顺序：

```text
Link
 -> IP/CIDR
 -> Route/Gateway
 -> ARP/Neighbor
 -> Firewall/NAT
 -> DNS
 -> TCP/UDP Port
 -> TLS/HTTP
 -> Application
```

目标是形成工程化排障习惯，而不是随机修改配置。

## 安全说明

仓库里的 Token、密码、API Key 均为本地教学占位值，不应在生产环境复用。`*.tfstate`、真实凭据与个人配置不应提交到 Git。

## 项目方向

这个项目现在更接近一个：

> **Terraform + Kubernetes + Linux Networking + Local Cloud Engineering Lab**

而不是依赖某一个云模拟器的教程。主线知识可以继续迁移到 AWS、Azure、GCP、OCI、Kubernetes 和私有云环境。
