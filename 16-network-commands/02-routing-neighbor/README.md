# 02 - Routing / Neighbor Commands

## Linux Routing

```bash
ip route
ip route show
ip route get 8.8.8.8
```

`ip route get` 特别有价值，因为它直接告诉你系统准备：

- 从哪个 interface 发
- 使用哪个 source IP
- 经过哪个 gateway

例如：

```bash
ip route get 10.10.30.10
```

## Windows Routing

```powershell
route print
Get-NetRoute
Find-NetRoute -RemoteIPAddress 8.8.8.8
```

## Neighbor / ARP

Linux：

```bash
ip neigh
ip neigh show
```

Windows：

```powershell
arp -a
Get-NetNeighbor
```

## 关系

```text
Route Table
   ↓
决定下一跳 IP
   ↓
ARP/Neighbor
   ↓
把下一跳 IP 转成 MAC
```

所以：

> 路由正确，但 ARP/neighbor 失败，数据仍然发不出去。
