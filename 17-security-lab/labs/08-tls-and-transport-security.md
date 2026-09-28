# Lab 08 - TLS、HTTPS 与传输安全

## 目标

理解为什么“服务能访问”不等于“通信安全”，并把前面抓到的明文 HTTP 和 TLS 加密通信进行对比。

你将学习：

- 明文 HTTP 的风险
- TLS 握手的基本结构
- 证书、主机名与信任链
- HTTPS 抓包后还能看到什么
- TLS 配置错误的常见类型
- 证书验证为什么不能随意跳过

## 1. 回顾明文 HTTP

在前面的抓包实验中：

```bash
tcpdump -i any -nn -A 'tcp port 80'
```

可以直接看到：

```text
GET /admin.txt HTTP/1.1
Host: target
...
LOCAL-LAB-SECRET
```

这说明网络路径上的观察者能够看到应用层内容。

## 2. TLS 解决什么

TLS 主要提供三类能力：

| 能力 | 说明 |
|---|---|
| Confidentiality | 防止第三方直接读取内容 |
| Integrity | 防止传输内容被无声篡改 |
| Authentication | 通过证书验证服务端身份 |

TLS 并不会自动解决：

- 应用本身的权限漏洞
- 弱口令
- 错误的 RBAC
- 数据库暴露
- 容器 root 权限

## 3. TLS 握手心智模型

简化流程：

```text
ClientHello
  -> ServerHello
  -> Certificate
  -> key agreement
  -> encrypted application traffic
```

你不需要一开始背完 TLS 所有字段，先理解：

> 客户端和服务端先协商加密参数，再进入受保护的 HTTP 通信。

## 4. openssl s_client

在有 HTTPS 服务时：

```bash
openssl s_client -connect target:443 -servername target
```

观察：

- certificate subject
- issuer
- validity
- negotiated protocol
- cipher
- verification result

## 5. 证书验证

真实系统中客户端需要确认：

1. 证书是否在有效期；
2. 主机名是否匹配；
3. 签发链是否可信；
4. 证书是否被撤销或替换。

测试环境自签名证书通常不会被系统 CA 默认信任。

## 6. 为什么 curl -k 只能用于受控调试

```bash
curl -k https://...
```

会跳过证书验证。

在实验中它可以帮助区分：

```text
TLS transport works
vs
certificate trust works
```

但真实客户端长期关闭校验会破坏 TLS 的身份认证价值。

## 7. HTTP 与 HTTPS 抓包对比

HTTP：

```text
TCP packet
  -> readable GET /path
  -> readable headers
  -> readable body
```

HTTPS：

```text
TCP packet
  -> TLS records
  -> encrypted application data
```

仍可能看到：

- IP
- port
- packet length
- timing
- connection count

## 8. TLS 版本

现代系统一般应该使用当前安全版本，如 TLS 1.2/1.3，并逐步淘汰历史协议。

验证服务支持：

```bash
openssl s_client -tls1_2 -connect HOST:PORT
```

或：

```bash
openssl s_client -tls1_3 -connect HOST:PORT
```

只对你自己的实验服务执行。

## 9. 安全头不是 TLS 的替代品

例如：

- HSTS
- CSP
- X-Content-Type-Options

它们属于 Web 安全控制，但不能替代传输加密。

同样 TLS 也不能替代：

- Authentication
- Authorization
- NetworkPolicy

## 10. TLS 终止点

常见架构：

```text
Client
 -> HTTPS
Reverse Proxy / Load Balancer
 -> HTTP or HTTPS
Backend
```

需要明确：

- TLS 在哪里终止？
- 终止之后的内部链路是否可信？
- 是否需要 end-to-end TLS？

## 11. 练习

1. 解释 HTTP 抓包为什么能看到 body。
2. 解释 HTTPS 后哪些字段仍可见。
3. 说明证书过期会产生什么问题。
4. 说明主机名不匹配为什么危险。
5. 解释为什么不应该在生产应用里永久关闭证书验证。

## 12. 完成标准

你应该能解释：

> TLS 保护的是传输过程，而不是自动修复应用权限、网络暴露或凭据管理问题。
