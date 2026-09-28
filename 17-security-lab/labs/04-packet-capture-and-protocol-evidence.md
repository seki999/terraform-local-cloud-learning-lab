# Lab 04 - 抓包与协议证据

## 目标

把“攻击”和“访问”从抽象概念变成真实数据包。

你将观察：

- DNS 解析
- TCP 三次握手
- HTTP 请求
- HTTP 响应
- TCP 连接关闭
- 明文 HTTP 的可见性

## 1. 抓包准备

进入 attacker：

```powershell
docker compose exec attacker sh
```

查看接口：

```bash
ip link
```

开始抓包：

```bash
tcpdump -i any -nn
```

另一个终端：

```powershell
docker compose exec attacker curl http://target/admin.txt
```

## 2. 限定目标

为了减少噪声：

```bash
tcpdump -i any -nn host target
```

如果名称过滤不方便，可先：

```bash
getent hosts target
```

拿到 IP 后：

```bash
tcpdump -i any -nn host <LAB_TARGET_IP>
```

这里只允许使用实验容器的 IP。

## 3. 观察 TCP

典型流程：

```text
SYN
SYN, ACK
ACK
PSH, ACK   HTTP request
PSH, ACK   HTTP response
FIN/ACK
```

把它和 15-protocol-stack 的 TCP 章节对应起来。

## 4. 查看 HTTP 明文

```bash
tcpdump -i any -nn -A host target and tcp port 80
```

然后：

```bash
curl http://target/admin.txt
```

你可能直接看到：

```text
GET /admin.txt HTTP/1.1
Host: target
...
LOCAL-LAB-SECRET
```

这就是 HTTP 明文通信的核心问题：网络路径上的观察者可能看到内容。

## 5. 为什么 HTTPS 重要

HTTPS 并不会隐藏：

- 两端 IP
- 大致流量大小
- 连接时间

但会保护：

- HTTP path（在现代 HTTPS 中加密）
- headers
- body
- cookies
- application payload

后面的 TLS Lab 会继续验证。

## 6. 抓包和日志的差异

| 证据 | 优点 | 局限 |
|---|---|---|
| tcpdump | 网络层真实证据 | 加密后看不到应用内容 |
| nginx log | 应用知道请求语义 | 依赖日志配置 |
| curl -v | 客户端视角清楚 | 只看到自己的请求 |
| docker logs | 易收集 | 只覆盖容器输出 |

成熟排障通常要交叉验证。

## 7. 保存 pcap

在 attacker 内：

```bash
tcpdump -i any -nn -w /tmp/lab04.pcap host target
```

产生几次请求后 Ctrl+C。

查看：

```bash
tcpdump -nn -r /tmp/lab04.pcap
```

不要提交包含敏感真实流量的 pcap 到 Git。

## 8. HTTP 过滤

```bash
tcpdump -i any -nn -A 'tcp port 80'
```

练习识别：

- method
- path
- host
- response status

## 9. 从时间角度分析

```bash
tcpdump -tttt -i any -nn host target
```

观察从 SYN 到响应大约经过多久。

这帮助区分：

- 网络建立慢
- 服务处理慢
- 客户端读取慢

## 10. 练习

1. 请求首页和 admin.txt，对比 payload。
2. 加固成 403 后再次抓包。
3. 比较 200 和 403 的响应内容。
4. 记录一次完整 TCP lifecycle。
5. 思考 TLS 后哪些字段还可见、哪些不可见。

## 11. 完成标准

你应该能从抓包证据说明：

> 一次 HTTP 请求到底经过了哪些 TCP 数据包，以及为什么明文 HTTP 不适合承载敏感信息。
