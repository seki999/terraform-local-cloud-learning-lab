# 03 - Connectivity / Path Commands

## ping

```bash
ping 10.10.10.1
ping -c 4 8.8.8.8
```

Windows：

```powershell
ping 8.8.8.8
```

主要验证：

- IP 层是否可达
- RTT
- packet loss

但 ping 失败不代表 TCP/HTTP 一定失败，因为 ICMP 可能被过滤。

## traceroute / tracert

Linux：

```bash
traceroute 8.8.8.8
tracepath 8.8.8.8
```

Windows：

```powershell
tracert 8.8.8.8
```

观察每一跳。

## Test-NetConnection

Windows 非常实用：

```powershell
Test-NetConnection example.com
Test-NetConnection example.com -Port 443
Test-NetConnection 10.0.0.10 -Port 5432
```

它比单纯 ping 更适合检查具体 TCP 服务。

## pathping

Windows：

```powershell
pathping example.com
```

用于结合路径与丢包统计，但执行时间较长。
