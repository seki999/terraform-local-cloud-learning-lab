# 13 - Protocol Troubleshooting

本章把所有协议知识转化成排障方法。

## 一个“网页打不开”应该如何拆

```text
1. DNS 能不能解析？
2. IP 路由是否存在？
3. TCP 443 能不能建立？
4. TLS 是否成功？
5. HTTP 是否收到响应？
6. Proxy/LB backend 是否健康？
7. 应用是否正常？
```

Windows：

```powershell
Resolve-DnsName example.com
Test-NetConnection example.com -Port 443
curl.exe -v https://example.com
```

Linux：

```bash
dig example.com
ip route get <IP>
nc -vz <IP> 443
openssl s_client -connect example.com:443 -servername example.com
curl -v https://example.com
```

## 故障矩阵

| 现象 | 优先怀疑 |
|---|---|
| DNS NXDOMAIN | DNS/record/name |
| No route to host | Route/interface |
| SYN 一直无响应 | Firewall/drop/path |
| 立即 RST | Port 未监听/主动拒绝 |
| TLS hostname mismatch | Certificate/SNI |
| HTTP 404 | Application/path |
| HTTP 502 | Proxy/upstream |
| SNMP Trap 没收到 | UDP162/firewall/receiver |
| Syslog 没收到 | transport/port/parser |

## 毕业实验

选择一个请求：

```text
client -> DNS -> LB -> backend
```

人为制造五个不同层次故障，每次必须写：

- symptom
- hypothesis
- command
- packet evidence
- root cause
- fix

完成后才算真正学会协议栈排障。
