# 08 - Firewall / NAT Commands

## nftables

查看：

```bash
sudo nft list ruleset
```

实时 trace：

```bash
sudo nft monitor trace
```

查看 table：

```bash
sudo nft list tables
sudo nft list table inet filter
```

## iptables

旧系统和很多容器环境仍常见：

```bash
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
```

现代发行版常建议直接理解 nftables，但排障时仍需要能读 iptables 输出。

## Windows Firewall

```powershell
Get-NetFirewallProfile
Get-NetFirewallRule
Get-NetFirewallPortFilter
```

## NAT 排障

重点检查：

- forward 是否开启
- FORWARD chain 是否允许
- SNAT/MASQUERADE 是否存在
- return route 是否存在

Linux：

```bash
sysctl net.ipv4.ip_forward
ip route
nft list ruleset
```
