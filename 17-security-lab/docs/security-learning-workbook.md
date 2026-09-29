# Security Learning Workbook

这份工作簿配合 42 个 Lab 使用。目的不是增加阅读量，而是逼自己把“看懂”变成“能解释、能验证、能设计”。

---

# Part A - 每个 Lab 的统一记录模板

## Lab 信息

```text
Date:
Lab:
Environment:
Target:
Scope:
Expected outcome:
```

## 1. 我想回答的问题

不要先写命令，先写问题。

例：

```text
目标服务开放了哪些端口？
敏感资源是否匿名可读？
NetworkPolicy 是否真的阻止 debug Pod？
```

## 2. 假设

```text
Hypothesis:
Because:
Evidence needed:
```

例：

```text
Hypothesis:
admin.txt is anonymously reachable.

Evidence needed:
HTTP status + response body + server access log.
```

## 3. 命令

只记录真正有用的命令。

```text
Command:
Purpose:
Expected:
Actual:
```

## 4. 证据

证据分类：

- Client Evidence
- Server Evidence
- Network Evidence
- Configuration Evidence
- Identity/Policy Evidence

## 5. 根因

避免：

```text
原因：被攻击。
```

更具体：

```text
原因：敏感文件位于 Web root，且 Nginx location 未限制匿名读取。
```

## 6. 修复

记录：

```text
Control:
Layer:
Why it helps:
Side effect:
```

Layer 可选：

- Network
- Transport
- TLS
- Application
- Identity
- Authorization
- Runtime
- Platform
- IaC
- Operations

## 7. Positive Test

证明正常功能没有坏。

例：

```text
GET / -> 200
```

## 8. Negative Test

证明原来的错误行为已被阻止。

例：

```text
GET /admin.txt -> 403
```

## 9. Residual Risk

修复后仍有什么风险？

例：

```text
HTTP endpoint still reachable on local network.
TLS not yet enabled.
Admin resource remains in web root.
```

---

# Part B - 网络安全工作表

## 1. Interface Inventory

| Host/Container | Interface | IP/CIDR | Purpose |
|---|---|---|---|
| | | | |

## 2. Route Inventory

| Source | Prefix | Next Hop | Interface | Expected |
|---|---|---|---|---|
| | | | | |

## 3. Port Inventory

| Host | Bind Address | Port | Process | Required? | Exposure |
|---|---|---:|---|---|---|
| | | | | | |

## 4. Connectivity Matrix

| Source | Destination | Protocol | Port | Expected | Actual |
|---|---|---|---:|---|---|
| frontend | api | TCP | 8080 | allow | |
| frontend | db | TCP | 5432 | deny | |
| api | db | TCP | 5432 | allow | |

## 5. Egress Matrix

| Workload | Destination | Port | Business Reason | Allow/Deny |
|---|---|---:|---|---|
| | | | | |

## 6. DNS Worksheet

```text
Name:
Resolver:
Expected IP:
Actual IP:
TTL:
TLS hostname:
Result:
```

## 7. Packet Evidence Worksheet

```text
Capture interface:
Filter:
Source:
Destination:
TCP handshake seen:
Application protocol:
Payload visible:
Encryption:
Conclusion:
```

---

# Part C - Identity 与 Authorization 工作表

## 1. Identity Inventory

| Identity | Type | Owner | Credential | TTL |
|---|---|---|---|---|
| user | human | | | |
| api | workload | | | |
| CI | machine | | | |

## 2. Permission Matrix

| Identity | Resource | Read | Write | Delete | Admin |
|---|---|---:|---:|---:|---:|
| | | | | | |

## 3. Authentication Questions

逐个系统回答：

1. 身份是谁？
2. 谁签发 credential？
3. credential 放在哪里？
4. TTL 多久？
5. 如何 rotate？
6. 如何 revoke？
7. 日志是否能追溯身份？
8. 是否支持 MFA 或 workload identity？

## 4. Authorization Questions

1. 权限是在前端还是服务端强制？
2. 是否检查对象 ownership？
3. 是否区分用户与管理员？
4. 是否存在 wildcard permission？
5. 默认新用户权限是什么？
6. 权限变更是否审计？

---

# Part D - Secret 工作表

| Secret | Owner | Scope | Storage | TTL | Rotation | Revoke |
|---|---|---|---|---|---|---|
| | | | | | | |

检查：

- [ ] 不在 Git
- [ ] 不在 Docker image
- [ ] 不在日志
- [ ] 不长期明文保存
- [ ] 有 owner
- [ ] 有 rotate 流程
- [ ] 有 revoke 流程
- [ ] 权限最小

---

# Part E - Container Security 工作表

## Container Inventory

| Container | Image | User | Capabilities | Writable Paths | Network |
|---|---|---|---|---|---|
| | | | | | |

逐项检查：

```text
Runs as root?
Needs root?
Privileged?
Docker socket mounted?
HostPath?
Read-only root FS?
Capabilities dropped?
Seccomp enabled?
Image pinned?
Healthcheck?
Resource limits?
Secret embedded?
```

结论格式：

```text
Finding:
Risk:
Recommended control:
Verification:
```

---

# Part F - Kubernetes 工作表

## 1. Workload Identity

| Namespace | Workload | ServiceAccount | Needs API? |
|---|---|---|---|
| | | | |

## 2. RBAC

| ServiceAccount | Resource | Verbs | Namespace | Why |
|---|---|---|---|---|
| | | | | |

测试：

```text
kubectl auth can-i ...
Expected allow:
Expected deny:
```

## 3. NetworkPolicy

列出所有必需连接。

```text
Source:
Destination:
Port:
Protocol:
Reason:
```

然后验证所有“不应该连接”的组合。

## 4. Pod Security

```text
runAsNonRoot:
allowPrivilegeEscalation:
readOnlyRootFilesystem:
capabilities:
seccomp:
hostNetwork:
hostPID:
hostPath:
```

---

# Part G - Terraform / IaC 工作表

## 1. 安全默认值

| Variable | Secure Default | Unsafe Example | Validation |
|---|---|---|---|
| | | | |

## 2. Plan Review

每次 plan 检查：

- [ ] 新增公网 IP？
- [ ] 新增 0.0.0.0/0？
- [ ] 新增管理端口？
- [ ] encryption 被关闭？
- [ ] logging 被关闭？
- [ ] IAM/RBAC 扩大？
- [ ] Secret 出现在 output？
- [ ] destructive change？

## 3. Terraform Test

至少有：

```text
secure input -> pass
unsafe input -> fail
expected deny -> pass
expected allow -> pass
```

---

# Part H - Logging 与 Detection 工作表

## Baseline

```text
Normal request rate:
Normal status distribution:
Normal destinations:
Normal login failures:
Normal pod restarts:
```

## Detection Rule

```text
Rule name:
Signal:
Condition:
Window:
Severity:
False positives:
Owner:
Runbook:
```

## Alert Triage

```text
Alert:
Time:
Affected asset:
Identity:
Source:
Evidence:
Known change?
Escalate?
Contain?
```

---

# Part I - Vulnerability Management 工作表

| Finding | Asset | Severity | Exposure | Business Impact | Owner | Due |
|---|---|---|---|---|---|---|
| | | | | | | |

逐项回答：

1. 版本真的受影响吗？
2. 功能是否启用？
3. 是否可达？
4. 是否已有 compensating control？
5. fixed version 是什么？
6. 升级影响是什么？
7. 修复后如何 re-test？

---

# Part J - Supply Chain 工作表

## Artifact Chain

```text
Source commit:
Build system:
Dependencies:
Base image:
SBOM:
Scan:
Signature:
Registry:
Deployment digest:
```

## 第三方依赖

| Dependency | Version | Source | Owner | Update Policy |
|---|---|---|---|---|
| | | | | |

---

# Part K - Incident Response 工作表

## Detect

```text
What happened?
When?
How detected?
Initial evidence?
```

## Triage

```text
Affected asset:
Affected identity:
Affected data:
Affected environment:
Current activity:
```

## Contain

```text
Action:
Reason:
Business impact:
Rollback:
```

## Eradicate

```text
Root cause:
Permanent fix:
Related systems checked:
```

## Recover

```text
Service restored:
Positive test:
Negative test:
Monitoring:
```

## Lessons Learned

```text
What worked:
What failed:
Missing telemetry:
Missing ownership:
Automation opportunity:
Due date:
```

---

# Part L - Risk Register

| ID | Asset | Finding | Likelihood | Impact | Control | Residual | Owner |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

推荐不要只填 High/Medium/Low，而是写一句原因。

例：

```text
Impact High:
credential grants deployment access to production.

Likelihood Medium:
credential is not internet-exposed but is stored long-term in CI.
```

---

# Part M - Security Architecture Review

## 1. Assets

列出所有：

- code
- data
- secret
- identity
- image
- log
- backup
- state

## 2. Entry Points

- public HTTP
- admin
- API
- CI
- webhook
- SSH/RDP
- monitoring
- Kubernetes API

## 3. Trust Boundaries

每条 boundary 写：

```text
From:
To:
Identity:
Encryption:
Authorization:
Logging:
```

## 4. Failure Modes

逐个问：

```text
If identity service fails?
If DNS fails?
If secret expires?
If DB unavailable?
If logging unavailable?
If backup fails?
```

---

# Part N - 30 天复习计划

## Week 1 - 网络与协议

Day 1:
- Lab 01
- 资产、边界、威胁

Day 2:
- Lab 02
- Recon / port / service

Day 3:
- Lab 03
- HTTP exposure

Day 4:
- Lab 04
- tcpdump

Day 5:
- Lab 16
- DNS

Day 6:
- Lab 17
- ARP / neighbor

Day 7:
- 总结一张 Network Security Map

## Week 2 - Identity 与 Platform

Day 8:
- Lab 07

Day 9:
- Lab 19

Day 10:
- Lab 09

Day 11:
- Lab 10

Day 12:
- Lab 11

Day 13:
- Lab 21

Day 14:
- 做 Kubernetes Security Matrix

## Week 3 - Secure Delivery

Day 15:
- Lab 12

Day 16:
- Lab 20

Day 17:
- Lab 24

Day 18:
- Lab 27

Day 19:
- Lab 28

Day 20:
- Lab 31

Day 21:
- 做 Supply Chain 图

## Week 4 - Operations

Day 22:
- Lab 05

Day 23:
- Lab 22

Day 24:
- Lab 38

Day 25:
- Lab 39

Day 26:
- Lab 13

Day 27:
- Lab 23

Day 28:
- Lab 41

Day 29:
- Lab 42

Day 30:
- Lab 34 Advanced Capstone

---

# Part O - 自测问题

完成课程后，不看文档回答：

1. TCP port open 能证明什么？不能证明什么？
2. 403 与 network deny 有什么区别？
3. TLS 保护什么？不保护什么？
4. Authentication 与 Authorization 的差异？
5. NetworkPolicy 与 RBAC 分别控制什么？
6. ServiceAccount 与 container UID 有什么区别？
7. Kubernetes Secret 为什么不等于保险箱？
8. 为什么 egress 也需要控制？
9. 为什么 CI/CD 是高价值资产？
10. 为什么镜像需要周期性重新扫描？
11. 什么是 SBOM？
12. 什么是 residual risk？
13. Backup 和 Restore 哪个更能证明恢复能力？
14. 为什么 Zero Trust 不是一个单独产品？
15. 为什么日志告警要有 baseline？
16. Terraform sensitive 为什么不能代替 state protection？
17. 为什么公网暴露会提高风险？
18. 为什么 0.0.0.0 和 127.0.0.1 风险不同？
19. 为什么安全测试既要 positive test 又要 negative test？
20. 为什么 Evidence 和 Hypothesis 必须分开？
21. 为什么管理员 credential 应该短期化？
22. 为什么 DB 不应使用应用 superuser？
23. 为什么容器不等于 VM？
24. 为什么 privileged Pod 风险高？
25. 为什么 CORS 不等于认证？
26. 为什么 Base64 不等于加密？
27. 为什么漏洞评分不是唯一优先级依据？
28. 什么是 compensating control？
29. 什么是 RPO/RTO？
30. 如何证明一个安全修复真正有效？

如果 30 个问题中有 25 个能清楚回答，说明已经建立较完整的安全基础框架。
