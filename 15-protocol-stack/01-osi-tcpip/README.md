# 01 - OSI 七层与 TCP/IP

## OSI 七层

| Layer | 名称 | 常见内容 |
|---|---|---|
| 7 | Application | HTTP、DNS、SSH、SNMP、Syslog |
| 6 | Presentation | TLS、编码、压缩、序列化 |
| 5 | Session | 会话状态、RPC/session 概念 |
| 4 | Transport | TCP、UDP |
| 3 | Network | IPv4/IPv6、ICMP、routing |
| 2 | Data Link | Ethernet、ARP、VLAN |
| 1 | Physical | Wi-Fi、铜线、光纤、radio |

## 一个 HTTP 请求如何封装

```text
GET / HTTP/1.1
Host: example.com
        ↓
TCP src=53000 dst=80
        ↓
IP src=192.168.1.10 dst=93.184.x.x
        ↓
Ethernet src=PC-MAC dst=Gateway-MAC
```

注意最后一行：访问互联网时 Ethernet 的目标 MAC 通常不是远端服务器 MAC，而是**下一跳网关**。

## 思考题

- DNS 查询通常为什么先看到 UDP？
- HTTPS 为什么同时涉及 TCP、TLS、HTTP？
- Router 看 IP 还是 HTTP Path？
- L7 Load Balancer 为什么可以根据 URL 转发，而普通 Router 不行？
