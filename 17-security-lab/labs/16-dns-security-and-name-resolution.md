# Lab 16 - DNS 安全与名称解析

## 目标

理解 DNS 不只是“把名字变成 IP”，它也是基础设施安全的重要组成部分。

学习：

- resolver
- authoritative server
- cache
- hosts file
- split DNS
- DNS logging
- DNS failure vs application failure
- DNS 信任边界

## 1. 本地观察

在 attacker 容器：

```bash
cat /etc/resolv.conf
getent hosts target
nslookup target 2>/dev/null || true
```

Docker 内部 DNS 会把 service name 解析到容器 IP。

## 2. DNS 与安全

如果名称解析被错误配置或被篡改：

```text
client asks for service-a
 -> receives wrong IP
 -> connects to unintended destination
```

这可能破坏：

- confidentiality
- integrity
- availability

## 3. hosts file 优先级

Linux 名称解析可能经过：

```text
/etc/hosts
DNS
mDNS
other NSS sources
```

查看：

```bash
cat /etc/nsswitch.conf
```

理解：

> DNS 不是唯一名称来源。

## 4. 缓存

DNS cache 可以提升性能，但也意味着：

- 变更不会立即生效
- 故障可能持续到 TTL 结束
- 排障时要考虑缓存

## 5. Split DNS

企业常见：

```text
same hostname
internal resolver -> private address
external resolver -> public address
```

设计不当会导致：

- 内外地址混淆
- 测试结果不同
- 误暴露内部名称

## 6. DNS 日志

防守方可以关注：

- unusual domain volume
- repeated NXDOMAIN
- unexpected resolver
- sudden hostname changes

不要把任何单一 DNS 异常直接认定为恶意行为。

## 7. DNS 与 TLS

即使 DNS 返回错误 IP，TLS hostname verification 仍可能阻止错误服务冒充目标。

因此：

```text
DNS integrity
+
TLS identity verification
```

是不同层面的保护。

## 8. 排障链

```text
name entered
 -> resolver selected
 -> answer returned
 -> IP reachable
 -> TCP established
 -> TLS verified
 -> HTTP responds
```

不要把“curl 失败”直接归因于 DNS。

## 9. 本地验证

```bash
getent hosts target
ping -c 1 target
nc -vz target 80
curl -I http://target/
```

按层观察。

## 10. 防御原则

- 使用可信 resolver
- 记录关键 DNS 变更
- 重要内部域名有明确 ownership
- 避免把内部命名暴露到不必要范围
- TLS 不关闭 hostname verification
- 关键基础设施修改走变更流程

## 11. 练习

1. 画出 client → resolver → service 的路径。
2. 解释 DNS 成功但 TCP 失败的场景。
3. 解释 TCP 成功但 TLS hostname 失败的场景。
4. 设计 DNS 故障排查顺序。
5. 解释为什么 DNS 安全不能代替 TLS。

## 12. 完成标准

你应该能把“名称解析问题”和“网络连接问题”分开，并理解 DNS 在身份与路由决策中的位置。
