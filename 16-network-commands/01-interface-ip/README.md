# 01 - Interface / IP Commands

## Linux / WSL2

```bash
ip link
ip -br link
ip addr
ip -br addr
ip link show eth0
```

常看：

- interface 是否 UP
- MAC address
- IPv4/IPv6
- prefix length
- MTU

设置临时地址：

```bash
sudo ip addr add 10.10.10.10/24 dev eth0
```

启停接口：

```bash
sudo ip link set eth0 down
sudo ip link set eth0 up
```

## Windows

```powershell
ipconfig /all
Get-NetAdapter
Get-NetIPConfiguration
Get-NetIPAddress
```

## 典型问题

如果网络完全不通，第一步先确认：

```text
接口存在吗？
接口 Up 吗？
IP 正确吗？
CIDR/prefix 正确吗？
Gateway/DNS 从 DHCP 获取了吗？
```
