# 04 - DNS Commands

## Linux

```bash
dig example.com
dig example.com A
dig example.com AAAA
dig +short example.com
dig +trace example.com
host example.com
nslookup example.com
```

## Windows

```powershell
Resolve-DnsName example.com
Resolve-DnsName example.com -Type A
Resolve-DnsName example.com -Type MX
nslookup example.com
```

查看当前 DNS：

```powershell
Get-DnsClientServerAddress
```

Linux：

```bash
cat /etc/resolv.conf
resolvectl status
```

## DNS 排障顺序

```text
1. DNS server 配置正确？
2. DNS server IP 能到？
3. Query 有 response？
4. response 是 NOERROR 还是 NXDOMAIN？
5. 返回 IP 正确？
6. DNS 正确后 TCP/HTTP 是否仍失败？
```
