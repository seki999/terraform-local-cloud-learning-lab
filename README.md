# Terraform Local Cloud Learning Lab

> 一个完全在本地运行、尽量不依赖真实收费云的 **Terraform + Kubernetes + Docker + Linux Networking + Protocol Stack + Network Commands + DevOps 中文实践课程**。

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
- 网络命令：ip / route / ping / traceroute / dig / ss / curl / openssl / tcpdump / nft / netsh
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
| 命令可操作 | 每个网络概念都尽量配套 Windows/Linux 命令进行验证 |
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
Core C    Network Command Toolbox       16-network-commands/

Stage 8   Monitoring                    08-monitoring/
Stage 9   Vault                         09-vault/
Stage 10  Terraform Modules             11-modules/
Stage 11  State Management              12-state-management/
Stage 12  Full Local Cloud              14-full-local-cloud/

Optional  LocalStack AWS API Lab        07-localstack/
Optional  Proxmox / libvirt             optional/
```

详细顺序见 [docs/00-learning-roadmap.md](docs/00-learning-roadmap.md)。

## 网络学习分成三条互补主线

### 10-networking

回答：

> 网络拓扑怎么搭？路由、防火墙、NAT、LB、VPN 怎么工作？

### 15-protocol-stack

回答：

> ARP/IP/TCP/TLS/HTTP/SNMP/Syslog 到底怎么通信？

### 16-network-commands

回答：

> 我怎样在 Windows/Linux 里观察、验证、配置和排查这些网络现象？

这三部分应配合学习。

## Network Command Toolbox

`16-network-commands/` 按“你想检查什么”分类命令：

```text
01 interface / IP
02 routing / neighbor
03 connectivity / path
04 DNS
05 port / socket
06 HTTP / TLS
07 packet capture
08 firewall / NAT
09 Wi-Fi
10 performance
11 cheatsheet
```

特别强调：

> 网络命令并不都等于“协议命令”。

例如：

```text
ping              -> 直接使用 ICMP
dig               -> 直接查询 DNS
curl              -> HTTP/HTTPS 客户端
openssl s_client  -> TLS 诊断
snmpwalk          -> SNMP
```

而：

```text
ip addr     -> 操作系统接口/IP 状态
ip route    -> 内核路由表
ss          -> socket 状态
ip neigh    -> neighbor cache
nft         -> firewall/NAT policy
netsh wlan  -> Windows Wi-Fi 状态
```

它们主要是在查看或配置操作系统的网络栈。

## 推荐的排障顺序

```text
Link
 -> IP/CIDR
 -> Route/Gateway
 -> ARP/Neighbor
 -> ICMP / Path
 -> Firewall/NAT
 -> DNS
 -> TCP/UDP socket
 -> TLS
 -> HTTP/Application
 -> Packet Capture
```

对应命令大致是：

```text
ip link / Get-NetAdapter
ip addr / ipconfig
ip route / route print
ip neigh / arp -a
ping / traceroute / tracert
nft / Get-NetFirewallRule
dig / Resolve-DnsName
ss / Test-NetConnection
openssl s_client
curl -v
tcpdump / Wireshark
```

目标是形成工程化排障习惯，而不是随机修改配置。

## LocalStack 的角色

`07-localstack/` 没有删除。它仍适合单独学习 AWS Provider、S3、DynamoDB、SQS、Lambda、API Gateway 等 API 交互，但它不再是主线，也不再是毕业实验依赖。

## 安全说明

仓库里的 Token、密码、API Key、SNMP community 等均为本地教学占位值，不应在生产环境复用。

## 项目方向

这个项目现在更接近一个：

> **Terraform + Kubernetes + Linux Networking + Protocol Engineering + Network Troubleshooting + Local Cloud Learning Lab**

目标不只是会部署资源，而是能够解释“一条请求从应用到网络再到后端究竟经过了什么”，并且知道应该用什么命令去证明自己的判断。
