# Lab 33 - Security Architecture Review

## 目标

学习在系统上线前做一次结构化安全架构审查。

场景：

```text
Browser
 -> Load Balancer
 -> Web
 -> API
 -> DB

API
 -> external SaaS

All components
 -> logging
```

## 1. Data Flow Diagram

先画数据流，而不是直接看产品名。

标记：

- process
- data store
- external entity
- trust boundary

## 2. Entry Points

列出所有入口：

- web
- API
- admin
- SSH/RDP
- CI/CD
- webhook
- monitoring endpoint

## 3. Identity

每条数据流问：

```text
Who is caller?
How authenticated?
What credential?
What authorization?
```

## 4. Data Classification

数据分：

- public
- internal
- confidential
- secret

不同等级需要不同：

- encryption
- retention
- access
- logging

## 5. Network Path

每条连接：

```text
source
destination
protocol
port
encryption
policy
```

## 6. Admin Plane

管理面应单独审查：

- who
- from where
- MFA
- audit
- break glass

不要把 admin endpoint 和 public API 视为同样风险。

## 7. Dependency

第三方依赖要问：

- credential scope
- egress
- timeout
- fallback
- data sent
- vendor outage

## 8. Failure Mode

安全设计也要考虑失败：

```text
auth service down
 -> fail open or fail closed?
```

不同业务可能有不同选择。

## 9. Logging

需要明确：

- security event
- owner
- retention
- alert
- privacy

## 10. Recovery

问：

- backup
- restore
- RTO
- RPO
- key recovery

## 11. Review Output

输出应该是：

```text
finding
risk
evidence
recommendation
owner
due date
```

而不是模糊说“系统不安全”。

## 12. 练习

1. 画三层应用 DFD。
2. 标 4 个 trust boundary。
3. 找 8 个 entry point。
4. 为每条流标 TLS/AuthZ。
5. 输出 5 条 architecture findings。

## 13. 完成标准

你应该能在不运行攻击工具的情况下，仅通过架构分析发现大量潜在安全问题。
