# 11 - WebSocket / HTTP2 / gRPC / QUIC / HTTP3

这章不要求一次全部掌握，重点是建立现代协议的关系图。

## HTTP/2

特点包括：

- binary framing
- multiplexing
- header compression
- 一个 TCP connection 上并发多个 stream

查看：

```bash
curl -I --http2 https://example.com
```

## gRPC

典型组合：

```text
gRPC
 ↓
HTTP/2
 ↓
TLS
 ↓
TCP
```

并常使用 Protocol Buffers 描述接口和消息。

## WebSocket

先通过 HTTP Upgrade 建立，然后形成长连接双向通信。

适合：

- chat
- realtime update
- dashboard push

## QUIC / HTTP/3

典型关系：

```text
HTTP/3
 ↓
QUIC
 ↓
UDP
 ↓
IP
```

QUIC 把很多原来由 TCP + TLS 分担的机制整合到用户态协议中。

## 排障提醒

看到 UDP 443 不要立即判断异常；现代 HTTP/3 正常就可能使用 UDP/443。
