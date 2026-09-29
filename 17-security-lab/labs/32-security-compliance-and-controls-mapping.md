# Lab 32 - 安全控制、合规与证据映射

## 目标

理解安全工程与合规之间的关系。

合规不是安全的全部，但它要求：

> 控制必须能够被证明存在并持续执行。

## 1. Policy / Standard / Procedure

```text
Policy    -> 我们要求什么
Standard  -> 必须达到什么标准
Procedure -> 实际怎么做
Evidence  -> 如何证明做了
```

## 2. Control

安全控制可以分：

- Preventive
- Detective
- Corrective

例：

```text
NetworkPolicy -> preventive
alert         -> detective
restore       -> corrective
```

## 3. Evidence

审计需要客观证据：

- configuration
- test result
- log
- ticket
- approval
- scan report

## 4. Control Mapping

本仓库中的实验可以映射：

| Control Area | Lab |
|---|---|
| Access Control | 07, 11 |
| Network Security | 06, 10, 18 |
| Encryption | 08, 31 |
| Logging | 05, 22 |
| Vulnerability Mgmt | 20, 24 |
| Backup | 23 |
| Incident Response | 13 |
| Secure SDLC | 27 |

## 5. CIS 思路

CIS Benchmarks 提供系统/平台配置基线。

学习方式：

```text
recommendation
 -> rationale
 -> check
 -> remediation
 -> impact
```

不要盲目套用生产配置到学习环境。

## 6. NIST CSF 思路

高层可理解为：

```text
Govern
Identify
Protect
Detect
Respond
Recover
```

这和本课程结构高度对应。

## 7. ISO 27001

ISO 更强调管理体系、风险管理和持续改进。

工程师需要知道技术控制如何形成审计证据。

## 8. Evidence Automation

IaC/CI 可以自动产生：

- terraform test result
- scan report
- policy check
- deployment record

比手工截图更可重复。

## 9. Exception Management

任何控制例外都应有：

- reason
- risk owner
- compensating control
- expiry
- approval

## 10. Continuous Compliance

不是一年检查一次，而是：

```text
code change
 -> automated policy
 -> evidence
 -> continuous visibility
```

## 11. 练习

1. 把 10 个 Lab 映射到 Prevent/Detect/Correct。
2. 为 NetworkPolicy 设计审计证据。
3. 为 RBAC 设计季度 review。
4. 写一份 exception 记录。
5. 用 NIST CSF 六个动词分类本课程。

## 12. 完成标准

你应该能把“我做了安全配置”转化成“我能持续证明这个控制存在、有效、有人负责”。
