# Lab 14 - 综合毕业实验：Purple Team 本地攻防闭环

## 目标

把前 13 个实验串成一个完整工程任务。

Purple Team 的核心不是“红队赢还是蓝队赢”，而是让攻击验证帮助防御变得可测量。

## 场景

你接手一个本地服务：

```text
Host
 -> Docker
 -> Web target
```

已知：

- Web 服务能访问
- 有一个敏感资源
- 尚未完成安全基线
- 需要建立证据、修复和复测

## Phase 1 - Asset Inventory

记录：

```text
service:
container:
network:
published port:
application endpoints:
sensitive assets:
logs:
```

输出一份资产表。

## Phase 2 - Threat Model

至少识别：

- information disclosure
- unauthorized access
- excessive exposure
- missing encryption
- excessive container privilege
- missing monitoring

对每项写：

```text
Threat
Evidence needed
Preventive control
Detective control
Recovery
```

## Phase 3 - Recon Baseline

只对实验 target：

```bash
ip addr
ip route
getent hosts target
nmap -sT -Pn target
nmap -sV -p 80 target
curl -I http://target/
```

记录 baseline。

## Phase 4 - Controlled Exposure Validation

```bash
curl -i http://target/admin.txt
```

保存：

- client output
- status
- server log

证明问题存在。

## Phase 5 - Packet Evidence

```bash
tcpdump -i any -nn -A 'tcp port 80'
```

再次产生请求。

写出你看到的：

```text
TCP handshake
HTTP request
HTTP response
payload visibility
```

## Phase 6 - Detection

定义一条简单规则：

```text
Sensitive path access
or
repeated denied/not-found paths
```

解释：

- true positive
- false positive
- threshold

## Phase 7 - Hardening

至少完成三项：

1. Sensitive path access control
2. Minimal host binding
3. Container privilege review

如果继续扩展，则增加：

4. TLS
5. authentication
6. network segmentation
7. logging policy

## Phase 8 - Regression Tests

构建表：

| Test | Before | Expected After | Actual |
|---|---|---|---|
| GET / | 200 | 200 | |
| GET /admin.txt | 200 | 403 | |
| TCP/80 | open | open | |
| host bind | loopback | loopback | |

安全修复必须同时证明：

```text
bad behavior blocked
good behavior preserved
```

## Phase 9 - Kubernetes Mapping

把 Docker 控制映射到 Kubernetes：

| Docker Lab | Kubernetes |
|---|---|
| internal network | NetworkPolicy |
| container identity | ServiceAccount |
| access control | RBAC / app auth |
| runtime hardening | securityContext |
| config | ConfigMap |
| sensitive config | Secret |

## Phase 10 - IaC Mapping

把人工规则转成自动化检查：

- safe default
- validation
- terraform test
- policy scanner
- CI gate

目标：

> 下次错误配置最好根本无法合并。

## Phase 11 - Incident Response Drill

假设日志已经出现一次 200 admin access。

写：

- detection time
- scope
- containment
- evidence
- root cause
- remediation
- recovery
- follow-up

## Phase 12 - Final Report

报告建议：

```markdown
# Security Lab Report

## Scope
## Architecture
## Asset Inventory
## Threat Model
## Baseline
## Findings
## Evidence
## Remediation
## Re-test
## Residual Risk
## Follow-up
```

## 评分标准

### 1. 网络理解

你能否解释：

- IP
- route
- port
- DNS
- container network

### 2. 应用理解

你能否解释：

- HTTP status
- exposed resource
- authentication
- authorization

### 3. 证据能力

你能否提供：

- curl evidence
- nmap evidence
- log evidence
- packet evidence

### 4. 修复能力

你能否：

- 修复问题
- 不破坏首页
- 重新验证

### 5. 自动化思维

你能否把安全要求转换成：

- Terraform validation
- test
- policy
- CI

## 毕业标准

如果你能独立完成以下闭环，就完成本模块：

```text
Discover
 -> Understand
 -> Prove
 -> Detect
 -> Fix
 -> Re-test
 -> Automate
 -> Document
```

真正目标是建立可迁移能力。

以后无论环境是：

- AWS
- OCI
- Kubernetes
- Docker
- Linux VM
- 企业内部网络

你都可以用相同方法思考：

```text
What is exposed?
Who can reach it?
Who can authenticate?
What are they authorized to do?
What evidence exists?
How do we reduce privilege?
How do we prove the fix?
```
