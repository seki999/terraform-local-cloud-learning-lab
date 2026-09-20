# 07 - HTTP

## Request

```http
GET /api/users HTTP/1.1
Host: app.example.local
Accept: application/json
```

## Response

```http
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: ...
```

## 必须掌握

Methods：

```text
GET POST PUT PATCH DELETE HEAD OPTIONS
```

常见 Status：

```text
200 201 204
301 302
400 401 403 404
429
500 502 503 504
```

## curl 是网络工程师也应该熟练使用的工具

```bash
curl -v http://example.com
curl -I http://example.com
curl -H 'Host: app.local' http://127.0.0.1
curl --connect-timeout 3 http://server:8080
```

## 502 / 503 / 504

看到这些状态码时，不应该只说“网络坏了”。

例如：

```text
Client -> Load Balancer -> Backend
```

- 502 常涉及 upstream 返回异常/连接失败
- 503 常涉及没有可用 backend / 服务不可用
- 504 常涉及 upstream timeout

具体含义仍取决于代理实现。

## 实验

用 nginx/HAProxy 做反向代理，再逐个停掉 backend，观察状态码和日志变化。
