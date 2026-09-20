# 16 - Network Command Toolbox

本专题不是按协议分类，而是按“你现在想检查什么”分类网络命令。

## 最重要的结论

网络命令 **不全是协议命令**。

有些命令直接查看协议行为，例如：

- `ping` -> ICMP
- `dig` / `nslookup` -> DNS
- `curl` -> HTTP/HTTPS
- `openssl s_client` -> TLS
- `snmpwalk` -> SNMP

但还有大量命令查看的是操作系统网络状态：

- `ip addr` -> 网卡/IP 配置
- `ip route` -> 路由表
- `ss` -> socket 状态
- `ip neigh` -> neighbor/ARP cache
- `nft` -> firewall/NAT 规则

所以更准确的理解是：

> 网络命令 = 协议观察工具 + 操作系统网络状态工具 + 故障诊断工具 + 配置工具。

## 分类地图

| 类别 | 目标 | Linux/WSL2 | Windows |
|---|---|---|---|
| 接口/IP | 看网卡、IP、MTU | `ip addr`, `ip link` | `ipconfig`, `Get-NetIPConfiguration` |
| 路由 | 看下一跳、默认网关 | `ip route` | `route print`, `Get-NetRoute` |
| 二层邻居 | 看 ARP/neighbor | `ip neigh` | `arp -a`, `Get-NetNeighbor` |
| 连通性 | 看能否到达 | `ping`, `traceroute` | `ping`, `tracert`, `Test-NetConnection` |
| DNS | 看名字解析 | `dig`, `host`, `nslookup` | `Resolve-DnsName`, `nslookup` |
| Socket/端口 | 看监听与连接 | `ss`, `lsof -i` | `Get-NetTCPConnection`, `netstat` |
| HTTP | 看应用层请求 | `curl` | `curl.exe`, `Invoke-WebRequest` |
| TLS | 看证书/握手 | `openssl s_client` | WSL/OpenSSL |
| 抓包 | 看真实数据包 | `tcpdump`, `tshark` | Wireshark, pktmon |
| Firewall/NAT | 看过滤/转换 | `nft`, `iptables` | Windows Defender Firewall cmdlets |
| Wi-Fi | 看无线链路 | `iw` | `netsh wlan` |
| 流量/带宽 | 看吞吐 | `iperf3` | `iperf3.exe` |
| 服务探测 | 检查端口 | `nc`, `nmap` | `Test-NetConnection`, `nmap` |

## 推荐排障顺序

不要一次运行所有命令。按层次：

```text
1. ip link / ipconfig
2. ip addr
3. ip route
4. ip neigh / arp
5. ping
6. traceroute / tracert
7. dig / Resolve-DnsName
8. ss / Get-NetTCPConnection
9. nc / Test-NetConnection
10. curl
11. openssl s_client
12. tcpdump / Wireshark
13. nft / firewall
```

这套顺序对应：

```text
Link
 -> IP
 -> Route
 -> Neighbor
 -> ICMP
 -> Path
 -> DNS
 -> TCP/UDP socket
 -> Application
 -> TLS
 -> Packet evidence
 -> Policy
```

## 子章节

- [01-interface-ip](01-interface-ip/README.md)
- [02-routing-neighbor](02-routing-neighbor/README.md)
- [03-connectivity-path](03-connectivity-path/README.md)
- [04-dns-commands](04-dns-commands/README.md)
- [05-port-socket](05-port-socket/README.md)
- [06-http-tls](06-http-tls/README.md)
- [07-packet-capture](07-packet-capture/README.md)
- [08-firewall-nat](08-firewall-nat/README.md)
- [09-wifi](09-wifi/README.md)
- [10-performance](10-performance/README.md)
- [11-command-cheatsheet](11-command-cheatsheet/README.md)

## 和协议栈的关系

`15-protocol-stack/` 回答“协议怎么工作”。

`16-network-commands/` 回答：

> 我怎样在操作系统里观察它、验证它、排查它？

两章应该配合学习。
