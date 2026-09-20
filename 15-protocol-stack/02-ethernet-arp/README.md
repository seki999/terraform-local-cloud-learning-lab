# 02 - Ethernet / MAC / ARP

## 核心问题

同一个子网里的两台机器已经知道对方 IP，为什么还不能直接发送 Ethernet Frame？

因为链路层需要目标 MAC。

ARP 解决：

```text
Who has 10.10.10.20?
Tell 10.10.10.10

10.10.10.20 is at aa:bb:cc:dd:ee:ff
```

## 查看 Neighbor Cache

Linux：

```bash
ip neigh
```

Windows：

```powershell
arp -a
```

## 实验

在 10-networking/03-linux-routing 创建网络后：

```bash
ip netns exec web ip neigh
ip netns exec web ping -c 1 10.10.10.1
ip netns exec web ip neigh
```

比较 ping 前后 neighbor table。

## 抓 ARP

```bash
ip netns exec web tcpdump -ni web0 arp
```

另一个终端：

```bash
ip netns exec web ping -c 1 10.10.10.1
```

## 非常重要

ARP 只解决**本地二层网络**的 IP → MAC。

当目标在其他子网：

```text
web -> router -> app
```

web 不会查询 app 的 MAC，而是查询自己的 default gateway MAC。
