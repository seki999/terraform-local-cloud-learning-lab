# 06 - HTTP / TLS Commands

## curl

```bash
curl http://example.com
curl -v https://example.com
curl -I https://example.com
curl -L https://example.com
curl --connect-timeout 3 https://example.com
```

指定 Host：

```bash
curl -H 'Host: app.example.local' http://127.0.0.1
```

指定解析结果：

```bash
curl --resolve app.example.com:443:10.0.0.10 https://app.example.com
```

这个对区分 DNS 问题与 HTTP/TLS 问题非常有用。

## openssl

```bash
openssl s_client -connect example.com:443 -servername example.com
```

检查：

- TLS version
- cipher
- certificate chain
- issuer
- hostname/SNI 相关问题

证书摘要：

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

## Windows

```powershell
curl.exe -v https://example.com
Invoke-WebRequest https://example.com
```
