# Lab 15 - Web Security 基础：输入、会话与安全响应

## 目标

这一章不做真实站点利用，而是在本地教学应用的语境里理解 Web 安全最常见的失误：

- 输入验证缺失
- 输出编码缺失
- 认证与会话管理不当
- 错误信息泄露
- 不安全的默认配置
- 缺少安全响应头

核心思想：

```text
untrusted input
 -> validation
 -> business logic
 -> storage
 -> output encoding
 -> response
```

任何来自浏览器、API、Header、Cookie、Query String 的数据，都应该默认视为不可信。

## 1. 输入验证

输入验证回答：

> 这个值是否符合系统预期？

例如用户名：

```text
长度
字符集合
是否允许为空
是否允许控制字符
```

不要把“前端验证”当作安全边界，因为客户端可以被绕过。

服务端必须再次验证。

## 2. Allow List 优先

两种思路：

```text
block known bad
allow known good
```

对结构清晰的字段，allow list 通常更稳定。

例：

```text
environment = dev | test | prod
```

而不是接受任意字符串后再尝试过滤危险内容。

## 3. 输出编码

如果用户内容要进入 HTML、JavaScript、URL、SQL、Shell，不同上下文需要不同的处理方式。

重要原则：

> 不要用一个“万能 escape”解决所有上下文。

Web 页面输出时，应由框架提供的安全模板机制完成 HTML encoding。

## 4. 参数化查询

数据库访问应优先使用参数化查询，而不是字符串拼接。

概念：

```text
SQL template
+
parameter binding
```

而不是：

```text
"SELECT ... " + user_input
```

本课程强调修复模式，而不提供针对真实数据库的利用步骤。

## 5. 会话安全

Session / Cookie 要关注：

- Secure
- HttpOnly
- SameSite
- 过期时间
- 登出失效
- Rotation
- 不在 URL 中携带敏感 token

## 6. 错误信息

开发环境可能输出：

- stack trace
- file path
- SQL error
- library version
- internal hostname

生产环境应避免把内部细节直接返回给客户端。

## 7. 安全响应头

常见头：

```text
Content-Security-Policy
X-Content-Type-Options
Referrer-Policy
Strict-Transport-Security
```

这些头不是“万能防护”，但可以降低特定风险。

## 8. Same-Origin 与 CORS

CORS 是浏览器安全模型的一部分，不是服务端认证机制。

错误理解：

> 只要 CORS 不允许，API 就安全。

实际上非浏览器客户端仍可发送请求。

所以仍需要：

- authentication
- authorization
- network control

## 9. CSRF 思维模型

如果浏览器会自动携带 credential，就要考虑跨站请求风险。

缓解措施包括：

- SameSite cookie
- anti-CSRF token
- re-authentication for sensitive actions
- origin checks

## 10. 安全测试矩阵

| Case | Expected |
|---|---|
| 正常输入 | accepted |
| 空值 | rejected or handled |
| 超长值 | rejected |
| 未认证敏感请求 | 401/403 |
| 普通用户访问 admin | denied |
| 异常格式 | 400 |

## 11. 练习

1. 给一个注册表单设计服务端验证规则。
2. 列出哪些字段适合 allow list。
3. 解释为什么 CORS 不是认证。
4. 为登录 Cookie 设计安全属性。
5. 设计一个“正常请求 + 非法格式 + 未授权请求”的回归测试表。

## 12. 完成标准

你应该能说明：

> Web 安全的第一步不是寻找复杂漏洞，而是确保输入、身份、权限、输出和错误处理都有明确边界。
