# 12 - Packet Analysis：tcpdump / Wireshark / tshark

这章的目标是把前面协议真正“看见”。

## tcpdump

DNS：

```bash
sudo tcpdump -nn -i any port 53
```

TCP 443：

```bash
sudo tcpdump -nn -i any tcp port 443
```

SNMP Trap：

```bash
sudo tcpdump -nn -i any udp port 162
```

Syslog：

```bash
sudo tcpdump -A -nn -i any port 514
```

保存：

```bash
sudo tcpdump -i any -w lab.pcap
```

## Wireshark Filter

```text
arp
icmp
dns
tcp
tcp.flags.syn == 1
tls
http
snmp
udp.port == 162
udp.port == 514
```

## 一个完整 HTTPS 请求应该怎么分析

```text
1. DNS query
2. DNS response
3. TCP SYN
4. TCP SYN/ACK
5. TCP ACK
6. TLS ClientHello
7. TLS ServerHello / certificate related messages
8. encrypted application data
```

如果使用 HTTP/3，路径会不同，因为它基于 QUIC/UDP。

## 最重要的方法

不要一上来就抓所有流量。

先缩小范围：

```text
host
port
protocol
interface
direction
```

否则很容易被大量背景流量淹没。
