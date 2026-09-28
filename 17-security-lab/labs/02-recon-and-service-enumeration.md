# Lab 02 - 本地侦察、端口与服务枚举

## 目标

学习攻击链最前面的 Recon / Enumeration，但只在本地隔离网络里执行。

你将练习：

- 查看本机接口与路由
- 识别实验网段
- 使用 DNS 名称解析 target
- 使用 nmap 识别开放端口
- 比较端口扫描、版本识别和应用层请求之间的差异
- 从防御角度理解“攻击面”

## 1. 启动实验

```powershell
cd 17-security-lab
docker compose up -d --build
docker compose ps
```

进入 attacker：

```powershell
docker compose exec attacker sh
```

## 2. 先观察，不扫描

```bash
hostname
ip addr
ip route
cat /etc/resolv.conf
getent hosts target
```

问题：

- attacker 有几个接口？
- 默认路由是什么？
- target 被解析成哪个 IP？
- Docker DNS 在哪里发挥作用？

## 3. 单目标端口枚举

```bash
nmap -sT -Pn target
```

参数含义：

- `-sT`：TCP connect scan
- `-Pn`：不依赖 ICMP host discovery
- `target`：Docker 内部 DNS 名称

不要把 target 换成外部网站。

## 4. 指定端口

```bash
nmap -sT -Pn -p 80 target
```

对比：

```bash
nc -vz target 80
curl -I http://target/
```

三者分别回答不同问题：

| 工具 | 回答 |
|---|---|
| nc | TCP 是否能建立连接 |
| nmap | 哪些端口开放、可能是什么服务 |
| curl | HTTP 应用层是否工作 |

## 5. 服务版本识别

```bash
nmap -sV -p 80 target
```

然后：

```bash
curl -v http://target/
```

观察 Server header、HTTP version、status code。

## 6. 从防御视角理解攻击面

攻击面可以简单理解成：

```text
reachable interfaces
+ open ports
+ exposed protocols
+ exposed endpoints
+ identities/credentials
+ privileged functions
```

所以安全加固不应该只考虑“有没有 CVE”，还要考虑：

- 这个端口有必要开吗？
- 这个端口应该对谁开放？
- 服务是否泄露过多版本信息？
- 管理接口是否和公共接口混在一起？

## 7. 建立基线

记录当前 baseline：

```text
target:
  tcp/80: open
  protocol: HTTP
  expected paths:
    /
    /admin.txt
```

以后每次加固后重复相同检查。

## 8. 观察 Docker 网络

退出 attacker 后：

```powershell
docker network ls
docker network inspect 17-security-lab_security_lab
```

重点看：

- Subnet
- Gateway
- Containers
- Internal=true

## 9. 练习：最小暴露

当前 host mapping：

```yaml
127.0.0.1:18080:80
```

解释以下两个配置差异：

```yaml
127.0.0.1:18080:80
0.0.0.0:18080:80
```

前者只绑定 loopback；后者可能在主机其他接口上监听。

## 10. 排障题

如果 nmap 显示 80 closed，而 curl 失败：

1. `docker compose ps`
2. `docker compose logs target`
3. `docker inspect local-security-target`
4. `getent hosts target`
5. `nc -vz target 80`

不要随机修改配置，按层验证。

## 11. 完成标准

你应该能区分：

```text
Host reachable
Port open
Service identified
Application responding
Resource authorized
```

这五件事不是一回事。
