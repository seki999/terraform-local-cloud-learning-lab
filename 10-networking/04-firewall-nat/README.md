# 04 - Firewall / NAT

本实验基于上一节的 `router/web/app/db` namespaces，学习 Security Group、NACL、NAT Gateway 背后的 Linux 原理。

## Firewall：先建立“最小权限”思维

先安装 nftables：

```bash
sudo apt install -y nftables
```

进入路由 namespace 配置转发过滤：

```bash
sudo ip netns exec router nft -f - <<'EOF'
flush ruleset
table inet filter {
  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state established,related accept
    ip saddr 10.10.10.0/24 ip daddr 10.10.20.0/24 accept
    ip saddr 10.10.20.0/24 ip daddr 10.10.30.0/24 accept
  }
}
EOF
```

含义：

- web → app：允许
- app → db：允许
- web → db：默认拒绝
- 回包通过 `established,related` 放行

查看规则和计数器：

```bash
sudo ip netns exec router nft list ruleset
```

这对应云上的 Security Group / NACL 思维，但要注意：各云产品具体的 stateful/stateless 语义并不完全等同 nftables。

## NAT 原理

NAT 的核心不是“云服务”，而是改写数据包源/目标地址。Linux 常见形式：

```bash
nft add rule ip nat postrouting oifname "wan0" masquerade
```

本课程先理解规则，再在有 WAN veth 的进阶实验中加入真实 SNAT。

## 故障练习

1. 把 forward policy 改成 accept，观察隔离消失。
2. 删除 `ct state established,related accept`，观察回包问题。
3. 用 `nft monitor trace` 跟踪一条被拒绝的流量。
4. 用 `tcpdump` 同时看入口和出口网卡。
