# 03 - Linux Network Namespace：真正的三层路由实验

> 目标：不用 LocalStack、不连接真实云，在 WSL2 Linux 内核里创建真实网卡、IP、路由和转发路径。

## 架构

```text
web 10.10.10.10/24
        |
     10.10.10.1
       router
  10.10.20.1   10.10.30.1
       |             |
app 10.10.20.10   db 10.10.30.10
```

这里不是“模拟 AWS API”。`ping`、`ip route`、`tcpdump` 看到的都是真实 Linux 数据包。

## 前置条件

Windows 11 + WSL2。WSL 发行版内需要 `iproute2`：

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping
```

## 创建实验

在 PowerShell：

```powershell
wsl -u root -- bash ./scripts/setup.sh
```

也可以让 Terraform 调用同一个脚本：

```powershell
terraform init
terraform apply
```

## 验证

```powershell
wsl -u root -- ip netns list
wsl -u root -- ip netns exec web ip addr
wsl -u root -- ip netns exec web ip route
wsl -u root -- ip netns exec web ping -c 2 10.10.20.10
wsl -u root -- ip netns exec web ping -c 2 10.10.30.10
```

重点观察：三个业务 namespace 之间没有直接网卡连接，跨子网通信必须经过 `router` namespace。

## 抓包

开两个终端：

```powershell
wsl -u root -- ip netns exec router tcpdump -ni r-web icmp
```

```powershell
wsl -u root -- ip netns exec web ping 10.10.20.10
```

如果没有 tcpdump：

```bash
sudo apt install -y tcpdump
```

## 对应云概念

| 本实验 | 云环境 |
|---|---|
| network namespace | VM/容器网络隔离边界 |
| veth pair | 虚拟网卡/ENI 的底层类比 |
| 10.10.x.0/24 | Subnet CIDR |
| router namespace | VPC Router / 虚拟路由器 |
| ip route | Route Table |
| ip_forward | 三层转发 |

## 销毁

```powershell
terraform destroy
```

或：

```powershell
wsl -u root -- bash ./scripts/destroy.sh
```
