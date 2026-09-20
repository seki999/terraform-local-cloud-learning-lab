# 11 - Network Command Cheatsheet

## 我是谁？

```text
Linux:   ip addr
Windows: ipconfig /all
```

## 默认网关在哪？

```text
Linux:   ip route
Windows: route print
```

## 到目标会走哪条路？

```text
Linux:   ip route get <IP>
Windows: Find-NetRoute -RemoteIPAddress <IP>
```

## ARP/Neighbor？

```text
Linux:   ip neigh
Windows: arp -a
```

## 能 ping 吗？

```text
ping <host>
```

## 路径经过哪里？

```text
Linux:   traceroute <host>
Windows: tracert <host>
```

## DNS？

```text
Linux:   dig <name>
Windows: Resolve-DnsName <name>
```

## TCP 端口能连吗？

```text
Linux:   nc -vz <host> <port>
Windows: Test-NetConnection <host> -Port <port>
```

## 本机监听什么？

```text
Linux:   ss -lntup
Windows: Get-NetTCPConnection -State Listen
```

## HTTP？

```text
curl -v <url>
```

## TLS？

```text
openssl s_client -connect host:443 -servername host
```

## 抓包？

```text
tcpdump -nn -i <iface> <filter>
Wireshark
```

## Firewall？

```text
Linux:   nft list ruleset
Windows: Get-NetFirewallRule
```

## Wi-Fi？

```text
Windows: netsh wlan show interfaces
```

## 性能？

```text
iperf3
```

## 一句话原则

> 先用状态命令缩小范围，再用协议命令验证，最后用抓包拿证据。
