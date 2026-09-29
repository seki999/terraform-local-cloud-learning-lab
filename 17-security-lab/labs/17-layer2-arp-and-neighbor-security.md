# Lab 17 - 二层网络、ARP 与 Neighbor 安全

## 目标

把 10-networking 与 15-protocol-stack 中的 ARP/Neighbor 知识映射到安全问题。

本章主要做观察和防御分析，不做对其他设备的欺骗攻击。

## 1. 查看 Neighbor

Linux：

```bash
ip neigh
```

Windows：

```powershell
arp -a
Get-NetNeighbor
```

这些表记录：

```text
IP <-> MAC
```

的邻居关系。

## 2. 为什么二层信任重要

同一二层网络中的设备需要知道下一跳 MAC。

如果邻居映射错误，可能造成：

- 流量送错目的地
- 通信失败
- 中间路径发生变化

## 3. ARP 没有强身份认证

传统 ARP 的设计目标是局域网地址解析，不是强安全认证。

所以企业网络通常还会依赖：

- switch isolation
- VLAN
- DHCP snooping
- Dynamic ARP Inspection
- port security
- endpoint security

## 4. 本地只观察

在 Docker bridge 或 Linux namespace 实验里：

```bash
ip neigh
ping -c 1 target
ip neigh
```

比较 ping 前后 neighbor cache。

## 5. Neighbor 状态

常见：

```text
REACHABLE
STALE
DELAY
PROBE
FAILED
```

这些状态有助于排障，但不是攻击证据本身。

## 6. VLAN 不是完整安全边界

VLAN 可以做逻辑分段，但安全仍需要：

- ACL
- firewall
- authentication
- monitoring

不要把“不同 VLAN”理解成“绝对安全”。

## 7. 二层异常检测思路

可关注：

- gateway MAC 突然变化
- 同一 IP 频繁映射多个 MAC
- 大量 ARP 请求
- 不符合资产清单的设备

但也要考虑正常网络变化。

## 8. 静态 ARP 的局限

静态绑定可以解决少量固定场景，但维护成本高，不适合大规模动态网络。

## 9. 云环境映射

公有云通常屏蔽大量传统二层行为。

你在 AWS/OCI 中更常操作：

- route table
- security group
- subnet
- virtual NIC

但理解 ARP 仍有助于掌握网络底层原理。

## 10. 练习

1. 观察本地 neighbor table。
2. ping 目标后再次观察。
3. 解释 IP 与 MAC 的职责差异。
4. 解释为什么 VLAN 不是最终安全边界。
5. 写出网关 MAC 异常变化的排查步骤。

## 11. 完成标准

你应该能理解：

> 安全不仅发生在 HTTP 和 Kubernetes；二层地址解析同样是网络信任链的一部分。
