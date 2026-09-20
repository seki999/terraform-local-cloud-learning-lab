# 06 - DNS

DNS 是现代基础设施最重要的依赖之一。

## 常见记录

| Record | 作用 |
|---|---|
| A | name → IPv4 |
| AAAA | name → IPv6 |
| CNAME | alias → canonical name |
| MX | mail exchanger |
| TXT | 文本/验证信息 |
| NS | authoritative nameserver |
| PTR | reverse lookup |

## 查询

```bash
dig example.com
dig example.com A
dig example.com AAAA
dig +trace example.com
```

Windows：

```powershell
Resolve-DnsName example.com
nslookup example.com
```

## DNS 链路

```text
Application
   ↓
OS resolver
   ↓
recursive resolver
   ↓
root
   ↓
TLD
   ↓
authoritative server
```

## Kubernetes

```text
backend.default.svc.cluster.local
```

通常由 CoreDNS 解析为 Service 地址。

验证：

```bash
kubectl exec <pod> -- cat /etc/resolv.conf
kubectl exec <pod> -- nslookup kubernetes.default
```

## 必练故障

- nameserver 配错
- DNS server 不可达
- NXDOMAIN
- Service 名拼错
- DNS 正常但 TCP port 不通

最后一个非常重要：**“域名能解析”不等于“服务可访问”。**
