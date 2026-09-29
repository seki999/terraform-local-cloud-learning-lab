# Security Command & Troubleshooting Reference

> 所有命令只用于你自己的本地实验资源。本文重点是“命令回答什么问题”，而不是堆砌命令。

# 1. Windows Host

## Interface

```powershell
Get-NetAdapter
Get-NetIPConfiguration
ipconfig /all
```

回答：

- 有哪些网卡？
- IP 是什么？
- Gateway/DNS 是什么？

## Route

```powershell
Get-NetRoute
route print
```

回答：

- 去目标网络走哪条路？
- 默认路由是什么？

## Neighbor

```powershell
Get-NetNeighbor
arp -a
```

回答：

- IP 对应哪个 MAC？
- Neighbor 状态如何？

## Listening Port

```powershell
Get-NetTCPConnection -State Listen
netstat -ano
```

回答：

- 哪些 TCP port 正在监听？
- 绑定 127.0.0.1 还是 0.0.0.0？

## Process

```powershell
Get-Process
Get-Process -Id <PID>
```

把端口映射到进程。

## Firewall

```powershell
Get-NetFirewallProfile
Get-NetFirewallRule
```

查看策略，不要为了排障直接关闭整个防火墙。

---

# 2. Linux / WSL

## Interface

```bash
ip addr
ip link
```

## Route

```bash
ip route
```

## Neighbor

```bash
ip neigh
```

## Socket

```bash
ss -lntup
```

## Process

```bash
ps aux
pstree
```

## DNS

```bash
cat /etc/resolv.conf
getent hosts target
dig name
nslookup name
```

## Connectivity

```bash
ping target
traceroute target
nc -vz target 80
```

## HTTP

```bash
curl -I http://target/
curl -v http://target/
```

## TLS

```bash
openssl s_client -connect HOST:443 -servername HOST
```

---

# 3. Docker

## Status

```powershell
docker ps
docker compose ps
```

## Logs

```powershell
docker compose logs target
docker compose logs -f target
```

## Network

```powershell
docker network ls
docker network inspect 17-security-lab_security_lab
```

## Container Detail

```powershell
docker inspect local-security-target
```

## Process

```powershell
docker top local-security-target
```

## Resource

```powershell
docker stats
```

## Identity

```powershell
docker compose exec target id
```

---

# 4. Local Recon

仅针对课程 target：

```bash
nmap -sT -Pn target
nmap -sV -p 80 target
nc -vz target 80
```

分别回答：

```text
port open?
service?
TCP connection?
```

不要把 target 替换成未授权的外部主机。

---

# 5. Packet Capture

## Basic

```bash
tcpdump -i any -nn
```

## Filter Target

```bash
tcpdump -i any -nn host <LAB_TARGET_IP>
```

## HTTP Text

```bash
tcpdump -i any -nn -A 'tcp port 80'
```

## Save

```bash
tcpdump -i any -nn -w /tmp/lab.pcap
```

## Read

```bash
tcpdump -nn -r /tmp/lab.pcap
```

---

# 6. Kubernetes

## Resource

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get networkpolicy -A
kubectl get serviceaccount -A
kubectl get role,rolebinding -A
```

## Describe

```bash
kubectl describe pod POD -n NS
kubectl describe networkpolicy NAME -n NS
```

## Logs

```bash
kubectl logs POD -n NS
```

## RBAC Check

```bash
kubectl auth can-i get pods
kubectl auth can-i delete pods
```

模拟本地 ServiceAccount：

```bash
kubectl auth can-i get configmaps   --as=system:serviceaccount:security-lab:config-reader   -n security-lab
```

## YAML

```bash
kubectl get pod POD -n NS -o yaml
```

确认 securityContext、ServiceAccount 等最终配置。

---

# 7. Terraform

## Static

```bash
terraform fmt
terraform validate
terraform plan
```

## Test

```bash
terraform test
```

## State

```bash
terraform state list
terraform show
```

注意：输出可能含敏感配置，不要把真实结果随意公开。

---

# 8. Security Troubleshooting Ladder

遇到“访问失败”：

```text
1 Link
2 IP
3 Route
4 Neighbor
5 Firewall
6 DNS
7 TCP
8 TLS
9 HTTP
10 Authentication
11 Authorization
12 Application
```

每一层只回答一个问题。

---

# 9. Example：curl 失败

## Step 1 DNS

```bash
getent hosts target
```

失败：

```text
DNS/service name issue
```

成功继续。

## Step 2 TCP

```bash
nc -vz target 80
```

失败：

- service down
- wrong port
- network policy
- firewall

## Step 3 HTTP

```bash
curl -v http://target/
```

判断：

- TCP connect
- request sent
- status

## Step 4 Authorization

```text
401?
403?
```

这已经不是纯网络问题。

---

# 10. Example：Kubernetes Service 访问失败

顺序：

```text
Pod Ready?
Service exists?
Endpoints exist?
DNS resolves?
NetworkPolicy?
Port correct?
App listening?
```

命令：

```bash
kubectl get pod -n NS
kubectl get svc -n NS
kubectl get endpoints -n NS
kubectl get networkpolicy -n NS
kubectl logs POD -n NS
```

---

# 11. Example：403 增加

不要马上认定攻击。

检查：

1. 最近部署？
2. Auth policy change？
3. 用户行为变化？
4. 同一 source？
5. 同一路径？
6. 时间分布？
7. 是否健康检查？

再决定是否安全事件。

---

# 12. Example：Unexpected Egress

先确认：

```text
process/workload
destination
DNS name
port
business dependency
recent deploy
```

再决定：

- legitimate
- misconfiguration
- suspicious

---

# 13. Evidence Collection Rules

建议保留：

```text
timestamp
command
target
output
configuration version
commit
logs
```

不要收集不必要的真实敏感数据。

---

# 14. Positive / Negative Testing

每个安全控制同时验证：

```text
Allowed path still works.
Denied path is denied.
```

例如：

```text
GET /          -> 200
GET /admin.txt -> 403
```

---

# 15. 常用“问题 -> 命令”映射

| 问题 | 命令 |
|---|---|
| 本机 IP？ | ip addr / Get-NetIPConfiguration |
| 路由？ | ip route / Get-NetRoute |
| DNS？ | getent / dig / Resolve-DnsName |
| Port？ | ss / Get-NetTCPConnection |
| TCP 可达？ | nc / Test-NetConnection |
| HTTP？ | curl -v |
| TLS？ | openssl s_client |
| Packet？ | tcpdump |
| Docker network？ | docker network inspect |
| Container identity？ | docker exec id |
| K8s policy？ | kubectl get networkpolicy |
| RBAC？ | kubectl auth can-i |
| Terraform safety？ | validate / plan / test |

---

# 16. 最重要的习惯

不要：

```text
看到失败
 -> 随机改配置
```

而是：

```text
Question
 -> Observation
 -> Hypothesis
 -> Small test
 -> Evidence
 -> Fix
 -> Re-test
```

这套方法既适用于网络排障，也适用于安全分析。
