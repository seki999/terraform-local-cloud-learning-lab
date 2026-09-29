# Lab 35 - API Security：身份、对象与限流

## 目标

API 往往比网页 UI 更直接地暴露业务能力。本章从防御角度学习 API 安全设计，不针对真实服务进行利用。

## 1. API 的安全边界

每个 API 至少回答：

```text
Who calls?
How authenticated?
What object?
What action?
What scope?
What rate?
What evidence?
```

## 2. Authentication

API 常见身份机制：

- session cookie
- bearer token
- mTLS workload identity
- signed request
- short-lived cloud identity

重点不是 token 长什么样，而是：

- 谁签发
- scope 多大
- TTL 多久
- 如何 revoke

## 3. Object Authorization

即使用户已经登录，也必须检查：

> 当前用户是否允许访问这个具体对象？

例如：

```text
GET /orders/123
```

不能只检查“是否登录”，还要确认该用户是否拥有订单 123 的访问权。

## 4. Function Authorization

普通用户不应因为知道 URL 就能调用管理员功能。

服务端必须校验：

```text
identity
role
permission
action
```

## 5. Rate Limit

API 需要考虑：

- request rate
- burst
- expensive endpoint
- login endpoint
- per-user/per-IP/per-token limits

限流不仅用于安全，也用于保护系统稳定性。

## 6. Schema Validation

推荐：

```text
explicit JSON schema
known fields
known types
size limit
```

拒绝不符合协议的输入。

## 7. Pagination

无限制导出可能造成：

- 性能问题
- 数据暴露扩大

应有：

- page size
- maximum limit
- authorization

## 8. Sensitive Data

API 响应只返回客户端真正需要字段。

避免：

- internal ID
- debug info
- password hash
- secret
- admin-only metadata

## 9. Versioning

API version 退役需要计划。

旧版本如果长期保留，可能继续携带已修复的安全缺陷。

## 10. Logging

记录：

- caller identity
- endpoint
- result
- latency
- authorization decision

避免记录完整 secret/token。

## 11. Error Handling

API 错误应足够帮助客户端，但不要暴露：

- stack trace
- SQL
- filesystem path
- internal topology

## 12. 测试矩阵

| Identity | Action | Expected |
|---|---|---|
| anonymous | read public | allow |
| anonymous | read private | deny |
| user A | read A object | allow |
| user A | read B object | deny |
| normal user | admin action | deny |

## 13. 完成标准

你应该能把 API Security 拆成：身份、对象授权、功能授权、输入、速率、数据最小化和日志。
