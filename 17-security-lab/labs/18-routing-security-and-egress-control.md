# Lab 18 - 路由安全与 Egress Control

## 目标

学习一个常被忽略的问题：

> 服务不仅要控制“谁能进来”，也要控制“它能访问哪里”。

学习：

- routing
- default route
- egress
- allow list
- proxy
- NAT
- route verification

## 1. 查看路由

```bash
ip route
```

重点理解：

```text
default via ...
network/prefix via ...
local route
```

## 2. 为什么 Egress 很重要

很多安全设计只考虑 ingress：

```text
Internet -> application
```

但被入侵或错误配置的应用也可能主动连接外部。

所以还要设计：

```text
application -> allowed dependencies only
```

## 3. Internal Network

当前 Docker security_lab：

```yaml
internal: true
```

这是非常适合教学的 egress 限制。

它帮助说明：

> 一个容器是否有默认外部出口，是可以设计的。

## 4. 依赖清单

为每个服务写：

| Service | Destination | Port | Reason |
|---|---|---:|---|
| app | db | 5432 | data |
| app | DNS | 53 | resolution |
| app | package mirror | 443 | only if update job |
| db | internet | none | normally not needed |

## 5. 默认路由风险

如果所有 workload 默认都能访问互联网：

- 数据外传面更大
- 恶意依赖下载更容易
- 错误回调更难发现

所以高安全环境常做显式 egress policy。

## 6. Proxy

企业可能要求：

```text
workload
 -> approved proxy
 -> internet
```

好处：

- central logging
- filtering
- domain policy
- audit

## 7. DNS 与 Egress

如果只限制 IP，却允许任意 DNS 和动态地址，策略可能难维护。

需要明确：

- 域名依赖
- IP 变化
- CDN
- SaaS

## 8. Kubernetes

NetworkPolicy 可同时控制：

```text
Ingress
Egress
```

default deny 后，再允许：

- DNS
- required API
- required DB

## 9. 云映射

AWS/OCI 中常见：

- route table
- NAT Gateway
- Internet Gateway
- security list / security group
- firewall service

核心逻辑仍是：

```text
Where can this workload send packets?
```

## 10. 验证矩阵

| Source | Destination | Expected |
|---|---|---|
| app | db | allow |
| app | DNS | allow |
| app | arbitrary internet | deny |
| db | arbitrary internet | deny |

## 11. 练习

1. 为三层应用写 egress matrix。
2. 解释为什么 DB 通常不需要任意互联网访问。
3. 解释 NAT 为什么不是授权系统。
4. 设计 Kubernetes egress allow list。
5. 说明如何验证规则既阻断错误流量又保留必要依赖。

## 12. 完成标准

你应该能够把安全问题从“谁能访问我”扩展到“我能访问谁”。
