# 05 - Port / Socket Commands

## Linux ss

```bash
ss -lnt
ss -lntp
ss -lunp
ss -tan
ss -s
```

含义：

- `l` listening
- `n` 不解析名称
- `t` TCP
- `u` UDP
- `p` process
- `a` all

例如查 8080：

```bash
ss -lntp | grep 8080
```

## lsof

```bash
sudo lsof -i :8080
sudo lsof -iTCP -sTCP:LISTEN
```

## Windows

```powershell
Get-NetTCPConnection
Get-NetTCPConnection -State Listen
Get-NetTCPConnection -LocalPort 443
netstat -ano
```

结合 PID：

```powershell
Get-Process -Id <PID>
```

## nc / netcat

探测 TCP：

```bash
nc -vz server 443
```

监听：

```bash
nc -l 9999
```

UDP：

```bash
nc -u -l 9999
```

## 关键区别

```text
DNS success
   !=
TCP port reachable
   !=
Application healthy
```
