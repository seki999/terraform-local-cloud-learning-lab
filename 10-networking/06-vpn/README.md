# 06 - VPN / Tunnel

VPN 的核心是：在原有网络之上创建一条逻辑隧道，让两个原本不可直接路由的地址空间可以安全通信。

本章建议使用 WireGuard（免费开源）理解：

- tunnel interface
- peer
- public/private key
- AllowedIPs
- route injection
- site-to-site VPN

## 学习顺序

先用两个 Linux namespace 建立普通路由，再加入 WireGuard 接口，把业务流量改走隧道。验证时同时使用：

```bash
ip addr
ip route
wg show
ping
tcpdump
```

## 云上对应

本地 WireGuard 并不等同某个具体云 VPN 产品，但“两个 CIDR 之间通过 tunnel + routes 建立连接”的心智模型可以迁移到 Site-to-Site VPN、Transit Gateway VPN 等场景。
