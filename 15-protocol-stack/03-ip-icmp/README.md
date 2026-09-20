# 03 - IPv4 / Routing / ICMP

## IPv4 Header 要关注什么

- Source IP
- Destination IP
- TTL
- Protocol
- Fragmentation fields

Router 主要根据 **Destination IP + Route Table** 决定下一跳。

## TTL

每经过一个三层 Router，TTL 减 1。

TTL 变成 0 时 Router 丢弃数据包，并通常返回 ICMP Time Exceeded。

这就是 traceroute 能工作的基础之一。

## 命令

```bash
ip addr
ip route
ping
traceroute
```

Windows：

```powershell
ipconfig
route print
ping
tracert
```

## ICMP 不只有 ping

常见 ICMP：

- Echo Request
- Echo Reply
- Destination Unreachable
- Time Exceeded

因此“禁止所有 ICMP”会损失不少诊断能力。

## 实验

用 10-networking/03-linux-routing：

```bash
ip netns exec web ping -c 2 10.10.30.10
ip netns exec web ip route
ip netns exec router ip route
```

然后删除 web 的 default route：

```bash
ip -n web route del default
```

再次 ping，比较错误。
