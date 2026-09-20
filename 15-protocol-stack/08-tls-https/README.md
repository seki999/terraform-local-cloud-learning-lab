# 08 - TLS / HTTPS

HTTPS 可以粗略理解为：

```text
HTTP
 ↓
TLS
 ↓
TCP
 ↓
IP
```

## TLS handshake 中应认识

- ClientHello
- ServerHello
- Cipher Suite
- Certificate
- SNI
- Key agreement
- Finished

现代 TLS 细节比这个更复杂，但排障先掌握这些足够。

## 查看证书

```bash
openssl s_client -connect example.com:443 -servername example.com
```

查看证书：

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

## curl

```bash
curl -v https://example.com
```

观察：

1. DNS
2. TCP connection
3. TLS negotiation
4. certificate validation
5. HTTP request

## SNI

一台服务器可以承载很多 HTTPS 域名。ClientHello 中的 SNI 告诉服务器客户端要访问哪个 hostname。

因此：

```text
IP 可达
TCP 443 可达
```

仍然不代表 TLS 一定成功。

## 常见 TLS 故障

- certificate expired
- hostname mismatch
- unknown CA
- protocol/cipher mismatch
- SNI 配置错误
