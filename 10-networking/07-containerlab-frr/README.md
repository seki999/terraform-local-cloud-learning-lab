# 07 - Containerlab + FRRouting

这是网络专题的进阶部分，目标是从静态路由进入动态路由。

## 为什么加入这一章

LocalStack 擅长模拟一部分 AWS API，但它不是网络仿真器。Containerlab + FRRouting 可以让你真正运行路由协议并观察路由表变化。

建议在 WSL2 Linux 环境安装 Containerlab，并使用 FRRouting 容器完成：

1. 两台 router 的静态路由
2. 三台 router 的 OSPF 邻居建立
3. BGP peer
4. route advertisement / withdrawal
5. 链路断开后的收敛
6. `show ip route`、`show ip ospf neighbor`、`show bgp summary`

## 推荐拓扑

```text
LAN-A -- R1 ----- R2 -- LAN-B
          \     /
            R3
```

当 R1-R2 链路断开后，让流量通过 R3 绕行。这个实验会把“路由协议为什么存在”变得非常直观。

> Containerlab 在 WSL2 上可运行，但属于高级实验；如果宿主机内核/权限限制导致失败，不影响前面的主线学习。
