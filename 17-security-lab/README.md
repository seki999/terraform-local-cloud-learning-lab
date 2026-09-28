# 17 - Local Security Lab：本地网络安全攻防课程

> 前置章节：[10-networking](../10-networking/README.md) → [15-protocol-stack](../15-protocol-stack/README.md) → [16-network-commands](../16-network-commands/README.md)

这一部分已经从原来的“单个入门实验”扩展成一个独立的本地网络安全课程模块。目标不是学习针对互联网目标的攻击，而是在**自己创建、隔离、可销毁的实验环境**里，把网络、协议、Linux、Docker、Kubernetes、Terraform 和安全思维串起来。

核心循环：

```text
Discover
 -> Enumerate
 -> Understand
 -> Prove
 -> Detect
 -> Harden
 -> Re-test
 -> Automate
 -> Document
```

---

## 1. 学习目标

完成本模块后，你应该能够：

- 解释资产、攻击面、信任边界、威胁和安全控制之间的关系；
- 用 `ip`、`route`、`getent`、`nmap`、`nc`、`curl` 做本地资产和服务枚举；
- 区分“主机可达”“端口开放”“应用可用”“资源存在”“权限允许”；
- 通过一个受控的信息暴露实验理解未授权访问；
- 用 Nginx access log 观察请求证据；
- 用 `tcpdump` 观察 TCP 与 HTTP；
- 理解 HTTP 明文和 HTTPS/TLS 的差异；
- 理解 firewall、network segmentation 和 default deny；
- 区分 Authentication 与 Authorization；
- 理解容器 root、capabilities、read-only filesystem、volume 和 secret 风险；
- 设计 Kubernetes NetworkPolicy；
- 设计 Kubernetes ServiceAccount / Role / RoleBinding；
- 使用 `kubectl auth can-i` 验证 allow/deny；
- 把安全要求写成 Terraform validation / check / test；
- 建立基本 Incident Response 时间线；
- 完成一次 Purple Team 风格的 Attack → Detect → Fix → Re-test 综合实验。

---

## 2. 安全边界

本模块所有主动验证仅针对本仓库自己创建的资源：

```text
local-security-attacker
local-security-target
本地 Minikube / Kind
本地 Terraform test resource
```

实验网络：

```yaml
internal: true
```

Host 暴露：

```text
127.0.0.1:18080
```

不要把教程中的：

```text
target
127.0.0.1
Docker internal IP
本地 Kubernetes Service
```

替换为公司、学校、他人主机、公共网站、云服务器或任何没有明确授权的系统。

---

## 3. 课程结构

本课程分成 14 个 Lab。

| Lab | 主题 | 核心问题 |
|---|---|---|
| 01 | Threat Model | 我在保护什么？ |
| 02 | Recon / Enumeration | 攻击面从哪里被看见？ |
| 03 | HTTP Exposure | 为什么资源会被未授权读取？ |
| 04 | Packet Capture | 网络上实际发生了什么？ |
| 05 | Logging / Detection | 防守方如何看到证据？ |
| 06 | Firewall / Segmentation | 谁应该能够连到谁？ |
| 07 | Authentication / Authorization | 你是谁？你能做什么？ |
| 08 | TLS / HTTPS | 传输过程如何保护？ |
| 09 | Container Hardening | 容器应该拥有什么权限？ |
| 10 | Kubernetes NetworkPolicy | Pod 之间如何最小连通？ |
| 11 | Kubernetes RBAC / Secret | Workload 身份如何最小授权？ |
| 12 | Terraform / IaC Security | 如何在部署前阻止错误配置？ |
| 13 | Incident Response | 出现异常后如何处理？ |
| 14 | Purple Team Capstone | 如何把前面全部串起来？ |

---

## 4. 推荐学习顺序

```text
01 Threat Model
        |
02 Recon / Enumeration
        |
03 HTTP Exposure
        |
04 Packet Capture
        |
05 Logging / Detection
        |
06 Firewall / Segmentation
        |
07 AuthN / AuthZ
        |
08 TLS
        |
09 Container Hardening
        |
10 Kubernetes NetworkPolicy
        |
11 Kubernetes RBAC / Secret
        |
12 Terraform / IaC Security
        |
13 Incident Response
        |
14 Purple Team Capstone
```

前 8 个偏网络与应用安全基础。

9～12 开始进入：

```text
Container Security
Kubernetes Security
Infrastructure as Code Security
```

13～14 则把这些能力整合成工程化流程。

---

## 5. 目录

```text
17-security-lab/
├── README.md
├── SECURITY-CHECKLIST.md
├── docker-compose.yml
├── target/
│   ├── Dockerfile
│   ├── vulnerable.conf
│   ├── hardened.conf
│   └── html/
│       ├── index.html
│       └── admin.txt
├── labs/
│   ├── 01-threat-model-and-lab-boundary.md
│   ├── 02-recon-and-service-enumeration.md
│   ├── 03-http-exposure-and-access-control.md
│   ├── 04-packet-capture-and-protocol-evidence.md
│   ├── 05-logging-detection-and-baseline.md
│   ├── 06-firewall-and-network-segmentation.md
│   ├── 07-authentication-and-authorization.md
│   ├── 08-tls-and-transport-security.md
│   ├── 09-container-hardening.md
│   ├── 10-kubernetes-networkpolicy.md
│   ├── 11-kubernetes-rbac-and-secrets.md
│   ├── 12-terraform-and-iac-security.md
│   ├── 13-incident-response.md
│   └── 14-capstone-purple-team.md
├── examples/
│   ├── docker-compose.hardened.yml
│   ├── kubernetes-networkpolicy.yaml
│   ├── kubernetes-rbac.yaml
│   └── terraform-security-example.tf
├── scripts/
│   └── verify-lab.ps1
└── docs/
    ├── security-glossary.md
    └── security-report-template.md
```

---

## 6. Lab 导航

### [Lab 01 - Threat Model 与实验边界](labs/01-threat-model-and-lab-boundary.md)

先不运行任何扫描工具。

学习：

- Asset
- Trust Boundary
- Threat
- Evidence
- Control
- Residual Risk
- 简化 STRIDE

这一步的目标是建立安全思维，而不是工具思维。

---

### [Lab 02 - Recon 与 Service Enumeration](labs/02-recon-and-service-enumeration.md)

使用：

```text
ip
ip route
getent
nmap
nc
curl
```

回答：

```text
目标在哪？
哪些端口开放？
是什么服务？
应用是否真的响应？
```

---

### [Lab 03 - HTTP 暴露与访问控制](labs/03-http-exposure-and-access-control.md)

从：

```text
GET /admin.txt -> 200
```

修复到：

```text
GET /admin.txt -> 403
```

同时保证：

```text
GET / -> 200
```

重点是：

```text
security negative test
+
business positive test
```

---

### [Lab 04 - 抓包与协议证据](labs/04-packet-capture-and-protocol-evidence.md)

使用：

```text
tcpdump
```

观察：

```text
DNS
TCP SYN
SYN/ACK
ACK
HTTP request
HTTP response
FIN
```

并理解 HTTP 明文内容为什么能够被观察。

---

### [Lab 05 - Logging / Detection / Baseline](labs/05-logging-detection-and-baseline.md)

从防守方回答：

```text
Who?
When?
From where?
Requested what?
Result?
How often?
```

并开始区分：

```text
Normal
Suspicious
Confirmed finding
False positive
```

---

### [Lab 06 - Firewall 与 Network Segmentation](labs/06-firewall-and-network-segmentation.md)

核心思想：

```text
deny by default
allow required flows
```

并建立 Source → Destination → Port → Expected 的访问矩阵。

---

### [Lab 07 - Authentication 与 Authorization](labs/07-authentication-and-authorization.md)

明确区分：

```text
Authentication = 你是谁？
Authorization  = 你能做什么？
```

设计：

```text
anonymous
normal user
admin
```

三类身份的访问矩阵。

---

### [Lab 08 - TLS / HTTPS](labs/08-tls-and-transport-security.md)

理解：

- HTTP 明文
- TLS handshake
- certificate
- hostname validation
- trust chain
- HTTPS 抓包可见/不可见信息

---

### [Lab 09 - Container Hardening](labs/09-container-hardening.md)

检查：

```text
root
capabilities
read-only filesystem
volume
Docker socket
image version
secret
resource limits
```

并参考：

[examples/docker-compose.hardened.yml](examples/docker-compose.hardened.yml)

---

### [Lab 10 - Kubernetes NetworkPolicy](labs/10-kubernetes-networkpolicy.md)

设计：

```text
frontend -> api      allow
api -> db            allow
frontend -> db       deny
debug -> api         deny
```

示例：

[examples/kubernetes-networkpolicy.yaml](examples/kubernetes-networkpolicy.yaml)

---

### [Lab 11 - Kubernetes RBAC / ServiceAccount / Secret](labs/11-kubernetes-rbac-and-secrets.md)

核心链路：

```text
Pod
 -> ServiceAccount
 -> RBAC
 -> API resource
```

通过：

```bash
kubectl auth can-i
```

同时验证 allow 和 deny。

示例：

[examples/kubernetes-rbac.yaml](examples/kubernetes-rbac.yaml)

---

### [Lab 12 - Terraform / IaC Security](labs/12-terraform-and-iac-security.md)

把安全要求编码：

```text
safe default
validation
precondition
postcondition
check
terraform test
CI policy
```

示例：

[examples/terraform-security-example.tf](examples/terraform-security-example.tf)

---

### [Lab 13 - Incident Response](labs/13-incident-response.md)

完整流程：

```text
Prepare
 -> Detect
 -> Triage
 -> Contain
 -> Eradicate
 -> Recover
 -> Lessons Learned
```

并学习如何把：

```text
Evidence
```

和：

```text
Hypothesis
```

分开记录。

---

### [Lab 14 - Purple Team 综合毕业实验](labs/14-capstone-purple-team.md)

最终任务：

```text
Asset Inventory
 -> Threat Model
 -> Recon
 -> Exposure Validation
 -> Packet Evidence
 -> Detection
 -> Hardening
 -> Regression Test
 -> Kubernetes Mapping
 -> IaC Mapping
 -> Incident Response
 -> Final Report
```

---

## 7. 第一次启动

```powershell
cd 17-security-lab
docker compose up -d --build
docker compose ps
```

预期：

```text
local-security-target
local-security-attacker
```

从 Host：

```powershell
curl.exe http://127.0.0.1:18080/
```

进入 attacker：

```powershell
docker compose exec attacker sh
```

查看：

```bash
ip addr
ip route
getent hosts target
```

---

## 8. 最小攻击验证

只针对本地 target：

```bash
nmap -sT -Pn target
nmap -sV -p 80 target
curl -i http://target/admin.txt
```

脆弱状态预期：

```text
80/tcp open
HTTP/1.1 200 OK
LOCAL-LAB-SECRET
```

这不是现实机密，只是用于证明：

> 一个本来应该受保护的资源正在被匿名读取。

---

## 9. 防守方证据

另一个 PowerShell：

```powershell
docker compose logs -f target
```

再请求：

```powershell
docker compose exec attacker curl http://target/admin.txt
```

你应该在日志看到：

- source IP
- method
- URI
- status
- timestamp
- user-agent

---

## 10. 抓包

attacker：

```bash
tcpdump -i any -nn -A 'tcp port 80'
```

然后执行：

```bash
curl http://target/admin.txt
```

在 HTTP 明文状态下，可以把：

```text
GET /admin.txt
LOCAL-LAB-SECRET
```

和 TCP packet 对应起来。

---

## 11. 加固与复测

从项目目录：

```powershell
docker cp .\target\hardened.conf local-security-target:/etc/nginx/conf.d/default.conf
docker exec local-security-target nginx -t
docker exec local-security-target nginx -s reload
```

正常页面：

```powershell
curl.exe -i http://127.0.0.1:18080/
```

应继续：

```text
200
```

敏感路径：

```powershell
docker compose exec attacker curl -i http://target/admin.txt
```

应变成：

```text
403
```

这就是最基础的：

```text
Attack
 -> Evidence
 -> Fix
 -> Positive Test
 -> Negative Re-test
```

---

## 12. 自动验证脚本

启动实验以后：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-lab.ps1
```

脚本检查：

1. Docker 是否可用；
2. Compose 容器状态；
3. 首页状态码；
4. admin.txt 状态码；
5. target 80/TCP；
6. 最近 Nginx 日志。

脆弱状态：

```text
/          -> 200
/admin.txt -> 200
```

加固状态：

```text
/          -> 200
/admin.txt -> 403
```

---

## 13. 安全层次模型

这一模块故意让你反复区分以下层次：

```text
Layer 1  Link
Layer 2  Ethernet / neighbor
Layer 3  IP / route
Layer 4  TCP / UDP / port
Layer 5+ TLS / HTTP
Identity Authentication
Policy   Authorization
Runtime  Container privilege
Platform Kubernetes policy
IaC      Terraform guardrail
Ops      Logging / Incident Response
```

一个请求失败时，不要只说：

> 网络不通。

而应该回答：

```text
DNS 是否成功？
IP 是否可达？
TCP 是否建立？
TLS 是否成功？
HTTP 是否响应？
认证是否成功？
授权是否允许？
```

---

## 14. Red Team / Blue Team / Purple Team

### Red Team 思维

```text
What can I reach?
What can I learn?
What is unnecessarily exposed?
```

### Blue Team 思维

```text
What should be reachable?
What evidence do I collect?
How do I reduce exposure?
```

### Purple Team 思维

```text
Use controlled attack validation
to improve defensive controls.
```

本课程主要采用 Purple Team 方法。

---

## 15. 常见误区

### 误区 1：端口开放 = 被攻破

错误。

```text
open port
```

只说明有服务监听。

---

### 误区 2：内网 = 安全

错误。

内网一样需要：

- identity
- segmentation
- least privilege
- logging

---

### 误区 3：用了 HTTPS 就安全

错误。

TLS 只解决一部分传输安全问题。

---

### 误区 4：Kubernetes Secret 是加密保险箱

错误。

Secret 默认编码方式不等于完整的 secret management。

---

### 误区 5：容器就是强隔离 VM

错误。

容器共享 Host kernel。

---

### 误区 6：扫描工具就是黑客能力

不完整。

真正工程能力是：

```text
hypothesis
 -> evidence
 -> root cause
 -> remediation
 -> re-test
```

---

## 16. 建议实验笔记格式

每个实验都记录：

```text
Date:
Lab:
Target:
Question:
Expected:
Command:
Observed:
Evidence:
Root Cause:
Fix:
Positive Test:
Negative Test:
Residual Risk:
```

完整报告模板：

[docs/security-report-template.md](docs/security-report-template.md)

---

## 17. Security Checklist

完成一个实验后，使用：

[SECURITY-CHECKLIST.md](SECURITY-CHECKLIST.md)

检查：

- Scope
- Network
- HTTP/Application
- TLS
- Container
- Kubernetes
- Terraform/IaC
- Logging
- Incident Response

---

## 18. Glossary

常用安全词汇：

[docs/security-glossary.md](docs/security-glossary.md)

建议不要只背英文，而是把词汇映射到真实操作：

```text
Exposure
 -> curl /admin.txt returns 200

Evidence
 -> nginx access log

Hardening
 -> 403

Re-test
 -> same curl now returns 403
```

---

## 19. 与整个仓库的关系

这个模块不是独立存在。

### 10-networking

告诉你：

```text
网络怎么搭
route/firewall/NAT 怎么工作
```

### 15-protocol-stack

告诉你：

```text
packet / TCP / HTTP / TLS 是什么
```

### 16-network-commands

告诉你：

```text
用什么命令观察
```

### 17-security-lab

把它们组合：

```text
网络知识
+
协议知识
+
命令
+
攻击面思维
+
防御验证
```

---

## 20. 建议学习节奏

如果每天学习约 30～60 分钟：

```text
Day 1  Lab 01
Day 2  Lab 02
Day 3  Lab 03
Day 4  Lab 04
Day 5  Lab 05
Day 6  Lab 06
Day 7  Review

Day 8  Lab 07
Day 9  Lab 08
Day 10 Lab 09
Day 11 Lab 10
Day 12 Lab 11
Day 13 Lab 12
Day 14 Review

Day 15 Lab 13
Day 16-18 Lab 14 Capstone
```

不要追求一次全部跑完。

安全学习更适合：

```text
少量命令
 -> 看清现象
 -> 写解释
 -> 做修复
 -> 再验证
```

---

## 21. 毕业标准

完成后，你应该能独立完成：

```text
1. 建立本地实验环境
2. 识别网络范围
3. 发现开放服务
4. 验证错误暴露
5. 保存客户端证据
6. 保存服务端日志证据
7. 用抓包解释协议行为
8. 设计网络限制
9. 设计身份与权限
10. 进行容器最小权限检查
11. 编写 Kubernetes NetworkPolicy
12. 编写 Kubernetes RBAC
13. 把安全要求转成 Terraform guardrail
14. 写事件时间线
15. 修复并复测
16. 输出安全实验报告
```

最终目标不是成为“会运行攻击工具的人”，而是成为能够解释：

> **为什么系统会暴露、攻击路径经过哪里、防守方怎样看到证据、怎样减少权限和攻击面、怎样证明修复真正生效**

的基础设施/云/平台安全工程师。

---

## 22. 清理环境

```powershell
docker compose down --remove-orphans
```

查看是否仍有残留：

```powershell
docker ps -a
docker network ls
```

实验结束后保持环境可清理、可重建，也是本课程的重要原则。
