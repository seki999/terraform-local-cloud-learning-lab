# 07 - Packet Capture Commands

## tcpdump

列接口：

```bash
tcpdump -D
```

抓指定接口：

```bash
sudo tcpdump -ni eth0
```

常用 Filter：

```bash
tcpdump -nn host 10.0.0.10
tcpdump -nn port 53
tcpdump -nn tcp port 443
tcpdump -nn udp port 162
tcpdump -nn icmp
tcpdump -A -nn port 514
```

保存：

```bash
tcpdump -i eth0 -w capture.pcap
```

读取：

```bash
tcpdump -nn -r capture.pcap
```

## tshark

```bash
tshark -i eth0
tshark -r capture.pcap
tshark -r capture.pcap -Y dns
```

## Windows pktmon

Windows 内置：

```powershell
pktmon start --etw -p 0
pktmon stop
```

复杂分析更推荐 Wireshark。

## 原则

抓包前先确定：

```text
哪个 interface？
哪个 IP？
哪个 port？
TCP 还是 UDP？
请求方向？
```

否则抓到的包太多。
