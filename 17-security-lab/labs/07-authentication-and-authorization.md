# Lab 07 - 身份认证、授权与最小权限

## 目标

理解两个经常混淆的概念：

```text
Authentication = 你是谁？
Authorization  = 你能做什么？
```

以及：

- 401 vs 403
- shared secret 的风险
- 管理接口保护
- 最小权限
- 权限验证矩阵

## 1. 认证和授权不是同一件事

例子：

```text
Alice successfully logs in
```

只说明 Authentication 成功。

如果 Alice 访问 admin-only 页面，还需要 Authorization 判断。

## 2. HTTP 状态码

通常：

- 401：未认证或认证失败
- 403：身份可能已知，但没有权限
- 200：允许

实际框架可能略有差异，但概念必须分开。

## 3. Basic Auth 适合什么

Basic Auth 可以作为本地教学工具，但生产环境必须配 TLS。

因为 Basic Auth 的 credential 只是编码，不是加密。

概念：

```text
Authorization: Basic <base64(user:password)>
```

不要把真实账号密码写进仓库。

## 4. 本地实验设计

推荐把资源分成：

```text
/public
/admin
```

规则：

| Identity | /public | /admin |
|---|---|---|
| anonymous | allow | deny |
| user | allow | deny |
| admin | allow | allow |

这是最小权限矩阵。

## 5. 角色与权限

RBAC 思路：

```text
User -> Role -> Permission
```

比直接：

```text
User -> many individual permissions
```

更容易维护。

## 6. 常见权限错误

- 默认给 admin
- 新增 API 忘记加授权
- 前端隐藏按钮但后端不校验
- 只检查“是否登录”，不检查“是否有权限”
- token 永不过期
- 多个服务共享同一高权限 credential

## 7. 测试矩阵

每个敏感接口至少测：

```text
anonymous -> denied
wrong identity -> denied
normal user -> denied
admin -> allowed
expired credential -> denied
```

## 8. 为什么不能只靠前端

前端按钮隐藏：

```text
UI says no
```

并不等于：

```text
API enforces no
```

真正授权必须在可信服务端执行。

## 9. Credential 生命周期

一个 credential 至少有：

```text
create
distribute
use
rotate
revoke
expire
audit
```

缺少 revoke/expire 会让泄露后的风险长期存在。

## 10. Service Account

在 Kubernetes 中，不应该让所有 Pod 都使用高权限 ServiceAccount。

后面的 RBAC Lab 会把这个原则落地：

```text
workload
 -> dedicated service account
 -> minimum Role
 -> RoleBinding
```

## 11. 练习

1. 为 public/user/admin 三类接口设计权限矩阵。
2. 写出匿名、普通用户、管理员的 expected status。
3. 解释 401 和 403 的区别。
4. 解释为什么 Base64 不是加密。
5. 解释为什么“登录成功”不代表“有管理员权限”。

## 12. 完成标准

你应该能清楚回答：

> 谁在访问？身份如何证明？这个身份应该有什么权限？系统在哪里强制执行？
