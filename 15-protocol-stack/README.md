# 15 - Protocol Stack Learning Lab

本专题回答一个核心问题：

> 一条请求从应用发出后，到底经过哪些协议层、哪些 Header、哪些端口、哪些网络设备，最后为什么能够到达服务器？

本章同时使用 **OSI 七层模型** 和工程上更常用的 **TCP/IP 模型**。

## 学习地图

| Lab | 主题 | 核心内容 |
|---|---|---|
| 01 | OSI vs TCP/IP | 七层模型、四层模型、封装/解封装 |
| 02 | Ethernet + ARP | MAC、Frame、ARP、同网段通信 |
| 03 | IP + ICMP | IPv4、TTL、Router、ping、traceroute |
| 04 | TCP | 三次握手、四次挥手、SEQ/ACK、RST、重传 |
| 05 | UDP | 无连接传输、DNS/SNMP/Syslog 常见用途 |
| 06 | DNS | A/AAAA/CNAME/MX/TXT/NS/PTR、递归解析 |
| 07 | HTTP | Method、Status、Header、Keep-Alive、Proxy |
| 08 | TLS / HTTPS | Certificate、ClientHello、SNI、TLS handshake |
| 09 | SNMP | Manager/Agent、OID/MIB、GET/TRAP、161/162 |
| 10 | Syslog | Facility、Severity、RFC 3164/5424、514 |
| 11 | Modern Protocols | HTTP/2、gRPC、QUIC、HTTP/3、WebSocket |
| 12 | Packet Analysis | tcpdump/Wireshark/tshark 全链路抓包 |
| 13 | Protocol Troubleshooting | 分层制造故障并定位 |

## OSI 与 TCP/IP

```text
OSI                         TCP/IP

7 Application   ┐
6 Presentation  ├──────>    Application
5 Session       ┘

4 Transport     ───────>    Transport

3 Network       ───────>    Internet

2 Data Link     ┐
1 Physical      ┘──────>    Link
```

现实排障时通常不会纠结“某功能严格属于第 5 层还是第 6 层”，而是更关注：

```text
Application
   ↓
TCP/UDP
   ↓
IP
   ↓
Ethernet/Wi-Fi
```

## 封装

应用发送 HTTP 请求时：

```text
HTTP data
   ↓
TCP segment
   ↓
IP packet
   ↓
Ethernet frame
   ↓
bits
```

接收方则反向解封装。

## 推荐学习顺序

```text
01 OSI/TCP-IP
 -> 02 Ethernet/ARP
 -> 03 IP/ICMP
 -> 04 TCP
 -> 05 UDP
 -> 06 DNS
 -> 07 HTTP
 -> 08 TLS
 -> 09 SNMP
 -> 10 Syslog
 -> 11 Modern Protocols
 -> 12 Packet Analysis
 -> 13 Troubleshooting
```

## 推荐工具

Windows / WSL2：

```text
ping
tracert / traceroute
arp / ip neigh
nslookup / dig
curl
Test-NetConnection
ss
tcpdump
tshark
Wireshark
openssl
nc / ncat
```

本专题目标不是背协议，而是能够回答：

1. 数据现在在哪一层？
2. 哪个 Header 决定了下一步？
3. 哪个端口在监听？
4. 哪个设备负责路由？
5. 包有没有出去？
6. 包有没有回来？
7. 是 DNS、TCP、TLS 还是应用层出了问题？
