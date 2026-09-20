# 10 - Syslog

Syslog 是设备、操作系统和网络设备传输日志的经典协议体系。

## 常见端口

- UDP 514
- TCP 514
- TLS Syslog 常使用 TCP 6514

## Severity

```text
0 Emergency
1 Alert
2 Critical
3 Error
4 Warning
5 Notice
6 Informational
7 Debug
```

## Facility

Facility 用来区分日志来源类别，例如 kernel、mail、daemon、local0-local7。

## RFC

常见格式：

- RFC 3164
- RFC 5424

现代系统中实际行为还取决于 rsyslog/syslog-ng/设备厂商实现。

## 实验

监听：

```bash
nc -u -l 5514
```

发送：

```bash
echo '<14>Sep 20 12:00:00 lab app: hello syslog' | nc -u 127.0.0.1 5514
```

抓包：

```bash
tcpdump -A -nn -i any udp port 5514
```

## 排障

如果日志收不到：

1. sender 是否真的发出
2. UDP/TCP 是否选对
3. destination port
4. firewall
5. receiver 是否监听
6. parser 是否接受该格式
7. 时间戳/hostname/facility 是否符合预期
