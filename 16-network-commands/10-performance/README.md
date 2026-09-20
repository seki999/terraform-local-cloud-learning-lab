# 10 - Performance / Throughput Commands

## iperf3

服务器：

```bash
iperf3 -s
```

客户端：

```bash
iperf3 -c <server-ip>
```

反向：

```bash
iperf3 -c <server-ip> -R
```

UDP：

```bash
iperf3 -c <server-ip> -u -b 100M
```

可观察：

- throughput
- retransmissions
- jitter
- packet loss

## 为什么不能只看 Speedtest

互联网 speed test 同时受到：

- ISP
- WAN
- remote server
- congestion
- routing

影响。

`iperf3` 更适合测试“局域网自身到底能跑多快”。

## Linux statistics

```bash
ip -s link
ss -s
```

这些可以看 RX/TX error/drop、socket summary。
