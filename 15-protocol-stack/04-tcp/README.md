# 04 - TCP 深入

TCP 是本专题最重要的一章之一。

## 三次握手

```text
Client                         Server

SYN seq=x        ------------>
                 <------------ SYN ACK seq=y ack=x+1
ACK ack=y+1      ------------>
```

## 为什么三次

双方都需要确认：

- 自己能发
- 自己能收
- 对方能发
- 对方能收
- 初始 sequence number 已同步

## TCP Header 重点

- Source Port
- Destination Port
- Sequence Number
- Acknowledgment Number
- Flags: SYN ACK FIN RST PSH
- Window Size

## 监听端口

Linux：

```bash
ss -lntp
```

Windows：

```powershell
Get-NetTCPConnection -State Listen
```

## 最简单实验

服务器：

```bash
python3 -m http.server 8080
```

客户端：

```bash
curl http://127.0.0.1:8080
```

抓包：

```bash
sudo tcpdump -nn -i any 'tcp port 8080'
```

观察 SYN / SYN-ACK / ACK。

## DROP 与 REJECT 的区别

Firewall DROP：

```text
client SYN ->
           ...
timeout
```

端口未监听时经常看到：

```text
client SYN ->
           <- RST
```

这两个现象是排障时非常重要的区别。

## 必练故障

1. server 未启动
2. port 写错
3. firewall DROP
4. 连接建立后 server 被 kill
5. 连续请求观察 TIME_WAIT
