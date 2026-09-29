# Lab 25 - Zero Trust 与身份中心安全

## 目标

理解 Zero Trust 的核心不是某个产品，而是一种设计原则：

> 不因为网络位置就自动信任。

## 1. 传统思维

旧模型常是：

```text
outside = untrusted
inside  = trusted
```

现代环境中：

- remote work
- cloud
- SaaS
- Kubernetes
- multiple accounts

让“内网可信”越来越不可靠。

## 2. Zero Trust 思路

更接近：

```text
verify identity
verify device/context
least privilege
explicit authorization
continuous observation
```

## 3. Identity First

访问决策不只看 IP。

还可能看：

- user identity
- workload identity
- device state
- service account
- token scope
- time/context

## 4. Workload Identity

Kubernetes：

```text
Pod -> ServiceAccount
```

Cloud：

```text
VM/Container -> Instance/Workload Role
```

尽量避免长期静态 key。

## 5. Microsegmentation

NetworkPolicy 是微分段的一种实现。

目标：

```text
frontend cannot talk to everything
api cannot talk to everything
db cannot talk to internet
```

## 6. Continuous Verification

不是登录一次后永久信任。

需要：

- short-lived token
- session expiry
- re-auth for sensitive actions
- telemetry

## 7. Least Privilege

Zero Trust 和最小权限紧密相关。

身份即使被盗：

```text
limited scope
limited TTL
limited network reach
```

可以降低 blast radius。

## 8. Device Trust

用户身份正确，也不代表设备一定安全。

企业环境可能额外检查：

- managed device
- patch status
- disk encryption
- endpoint protection

## 9. Service-to-Service

微服务之间也要考虑身份。

不应该：

```text
same cluster = trusted
```

而应该考虑：

- mTLS
- workload identity
- policy

## 10. Zero Trust 不是“零信任所有人”

它不是让系统不可用，而是：

> 每次访问都有明确的身份、策略和最小授权。

## 11. 练习

1. 把 frontend/api/db 转成身份关系图。
2. 为每条连接指定 identity。
3. 为 token 设计 scope 与 TTL。
4. 解释为什么 IP allowlist 不是完整身份控制。
5. 把 NetworkPolicy + RBAC + TLS 组合成 Zero Trust 风格架构。

## 12. 完成标准

你应该能从“网络在哪里”转向“谁在访问、为什么允许、权限多大、信任持续多久”。
