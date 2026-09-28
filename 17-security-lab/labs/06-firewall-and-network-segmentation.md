# Lab 06 - 防火墙、网络分段与最小可达性

## 目标

把“能不能访问”从应用层下沉到网络层。

学习：

- 网络分段
- 默认拒绝
- allow list
- 管理面与业务面分离
- 为什么 NetworkPolicy / firewall 是纵深防御的一部分

## 1. 分层防御

即使 Nginx 已经返回 403，攻击者仍然可以到达 80/TCP。

更进一步的防御是：

```text
不需要访问的人
 -> 网络层就不让到达
```

## 2. 三种控制层次

```text
Host firewall
Docker network
Application ACL
```

它们解决不同问题。

## 3. Docker 内部网络

现有：

```yaml
networks:
  security_lab:
    driver: bridge
    internal: true
```

查看：

```powershell
docker network inspect 17-security-lab_security_lab
```

`internal: true` 主要限制容器通过该网络访问外部，不等于完整企业防火墙。

## 4. 网络分段思想

真实系统可分：

```text
public subnet
  reverse proxy

application subnet
  API

data subnet
  DB
```

原则：

```text
Internet -> proxy
proxy -> API
API -> DB
Internet -X-> DB
```

## 5. 为什么默认拒绝更安全

两种模型：

```text
allow all, deny exceptions
deny all, allow required
```

后者更符合 least privilege。

## 6. Linux nftables 思维实验

在 Linux/WSL 网络实验中，规则逻辑可以是：

```text
default drop
allow established
allow loopback
allow required source -> required destination:port
drop everything else
```

具体命令建议结合 10-networking 的 nftables lab 执行。

## 7. 验证矩阵

安全规则不要只测“一条能不能通”，要做矩阵：

| Source | Destination | Port | Expected |
|---|---|---:|---|
| attacker | web | 80 | allow |
| attacker | internal admin | 8080 | deny |
| app | db | 5432 | allow |
| attacker | db | 5432 | deny |

## 8. 失败模式

配置 firewall 时常见事故：

- 把自己管理连接也封掉
- 忘记 established/related
- 规则顺序错误
- 只考虑 ingress 不考虑 egress
- IPv4 做了限制但 IPv6 没做
- 容器和 host firewall 行为理解错误

所以必须先在本地实验。

## 9. Docker 端口发布

比较：

```yaml
ports:
  - "127.0.0.1:18080:80"
```

和：

```yaml
ports:
  - "18080:80"
```

后者通常等价于绑定所有接口，攻击面更大。

## 10. 验证 Host 监听

Windows：

```powershell
Get-NetTCPConnection -LocalPort 18080
```

或：

```powershell
netstat -ano | findstr 18080
```

理解 LocalAddress 的含义。

## 11. 纵深防御

理想状态：

```text
Network segmentation
+ firewall
+ authentication
+ authorization
+ TLS
+ logging
+ least privilege
```

任何一层失效时，其他层仍提供保护。

## 12. 练习

1. 画一个 public/app/data 三段网络。
2. 写出 6 条访问矩阵。
3. 标记哪条必须 allow，哪条必须 deny。
4. 解释为什么 DB 不应直接发布到 host。
5. 说明 loopback binding 能减少什么攻击面。

## 13. 完成标准

你应该能解释：

> 应用返回 403 是应用层拒绝，而网络分段的目标是让不该访问的主体连 TCP 都建立不了。
