# 05 - UDP

UDP 不建立类似 TCP 的连接状态。

## UDP Header 非常简单

- Source Port
- Destination Port
- Length
- Checksum

## 特点

- 无三次握手
- 无内建重传
- 无内建顺序保证
- 开销低
- 应用自己决定可靠性机制

常见使用：

- DNS
- SNMP
- Syslog
- NTP
- QUIC 的底层承载

## 实验

Receiver：

```bash
nc -u -l 9999
```

Sender：

```bash
echo hello | nc -u 127.0.0.1 9999
```

抓包：

```bash
sudo tcpdump -nn -i any 'udp port 9999'
```

## 排障重点

TCP 可以观察连接状态；UDP 没有这一层，所以更依赖：

- tcpdump
- 应用日志
- firewall counter
- 是否真的监听 UDP socket
