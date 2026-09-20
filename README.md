# Terraform Local Cloud Learning Lab

> 一个完全在本地运行、尽量不依赖真实收费云的 **Terraform + Kubernetes + Docker + Linux Networking + Protocol Stack + DevOps 中文实践课程**。

## 项目定位

这个仓库的核心不再是“模拟 AWS”，而是学习真正可以迁移到云环境的基础设施能力：

- Terraform / IaC
- Docker 网络与容器
- Minikube / Kind / Kubernetes
- Helm
- Linux Routing / Firewall / NAT / DNS
- Load Balancer / VPN
- OSI / TCP-IP / Ethernet / ARP / IP / ICMP / TCP / UDP
- HTTP / TLS / DNS / SNMP / Syslog / HTTP2 / gRPC / QUIC
- tcpdump / Wireshark / tshark
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
| 协议可观察 | 不只记协议定义，要通过抓包看到 Header、握手、端口和失败现象 |
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

Core A    Linux / Cloud Networking      10-networking/
Core B    Protocol Stack                15-protocol-stack/

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

`10-networking/` 是 Local Network Engineering Lab：

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

其中 `03-linux-routing` 会在 WSL2 Linux 内真正创建多子网路由环境。

## 协议栈专题

`15-protocol-stack/` 把“网络能通”继续推进到“到底是什么协议在通信”：

```text
01-osi-tcpip
02-ethernet-arp
03-ip-icmp
04-tcp
05-udp
06-dns
07-http
08-tls-https
09-snmp
10-syslog
11-modern-protocols
12-packet-analysis
13-protocol-troubleshooting
```

这个专题不是背 OSI 七层，而是用：

```text
ARP -> IP -> ICMP -> TCP/UDP -> DNS -> TLS -> HTTP
```

这样的真实链路来学习。

同时覆盖监控系统常见的：

```text
SNMP GET / TRAP
Syslog
UDP 161 / 162 / 514
TCP/TLS Syslog
```

并用 tcpdump / Wireshark 验证。

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
| TCP/TLS/HTTP | LB、Ingress、API 通信的底层协议链 |
| SNMP/Syslog | 网络监控与日志采集 |
| Kind | 本地 Kubernetes / EKS 类比 |
| Vault | Secret Manager 类能力 |
| Prometheus/Grafana | Cloud monitoring 类能力 |

这里强调的是概念与数据流映射，不代表具体云产品与本地工具 1:1 等价。

## 推荐工具

主要工具：

- Terraform
- Docker Desktop
- WSL2
- Git
- kubectl
- Minikube / Kind
- Helm

网络/协议实验还会用到：

- iproute2
- nftables
- tcpdump
- Wireshark / tshark
- dig / nslookup
- curl
- openssl
- nc / ncat
- WireGuard
- Containerlab
- FRRouting

## 推荐的排障顺序

遇到“服务访问不了”，统一按下面顺序：

```text
Link
 -> IP/CIDR
 -> Route/Gateway
 -> ARP/Neighbor
 -> Firewall/NAT
 -> DNS
 -> TCP/UDP
 -> TLS
 -> HTTP/Application
```

如果是监控协议，再进一步检查：

```text
SNMP version/OID/community/user
Syslog transport/port/RFC format/parser
```

目标是形成工程化排障习惯，而不是随机修改配置。

## LocalStack 的角色

`07-localstack/` 没有删除。它仍适合单独学习 AWS Provider、S3、DynamoDB、SQS、Lambda、API Gateway 等 API 交互，但它不再是主线，也不再是毕业实验依赖。

## 安全说明

仓库里的 Token、密码、API Key、SNMP community 等均为本地教学占位值，不应在生产环境复用。生产环境应优先采用更安全的认证和加密方式，例如 SNMPv3、TLS 和受控 Secret 管理。

## 项目方向

这个项目现在更接近一个：

> **Terraform + Kubernetes + Linux Networking + Protocol Engineering + Local Cloud Learning Lab**

目标不只是会部署资源，而是能够解释“一条请求从应用到网络再到后端究竟经过了什么”，并在出问题时有系统地定位根因。
