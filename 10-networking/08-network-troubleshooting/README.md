# 08 - Network Troubleshooting：故障实验

网络知识真正形成能力的关键不是“正常时会配置”，而是“坏了之后知道从哪一层查”。

## 固定排障顺序

```text
1. Link/interface
2. IP/CIDR
3. Route/Gateway
4. ARP/Neighbor
5. Firewall/NAT
6. DNS
7. TCP/UDP port
8. TLS/HTTP/Application
```

## 必练故障

| 故障 | 首选检查 |
|---|---|
| 网卡 down | `ip link` |
| 地址配错 | `ip addr` |
| 默认路由丢失 | `ip route` |
| 下一跳不可达 | `ping`, `ip neigh` |
| Firewall DROP | `nft list ruleset`, `nft monitor trace` |
| DNS 错误 | `dig`, `cat /etc/resolv.conf` |
| 端口未监听 | `ss -lntup` |
| 路径异常 | `traceroute` |
| 包到了但应用没响应 | `tcpdump` + 应用日志 |

## 建议练法

每次只制造一个故障，并记录：

- 现象
- 假设
- 验证命令
- 根因
- 修复
- 如何防止再次发生

最终目标是看到“连接不上”时，不再随机改配置，而是按层定位。
