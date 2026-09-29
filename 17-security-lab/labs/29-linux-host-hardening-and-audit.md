# Lab 29 - Linux Host Hardening 与审计

## 目标

把安全视角从容器扩展到宿主 Linux。

学习：

- account
- sudo
- SSH
- service
- filesystem permission
- package update
- audit/log
- listening ports

## 1. 用户与权限

检查：

```bash
id
getent passwd
groups
```

重点不是收集别人系统信息，而是在自己的 WSL/VM 理解账户结构。

## 2. sudo

最小权限原则：

```text
specific command
instead of
full root shell
```

sudo 配置修改必须谨慎，避免锁死管理员访问。

## 3. SSH

本地 VM 学习时关注：

- 禁止 root 直接远程登录
- key authentication
- password policy
- known_hosts
- authorized_keys
- logging

不要把实验 SSH 暴露到公网。

## 4. Listening Ports

```bash
ss -lntup
```

建立 baseline：

- 哪些服务监听
- 哪个进程
- 哪个地址
- 是否必要

## 5. Service Management

systemd：

```bash
systemctl --type=service --state=running
```

不需要的 daemon 不应默认运行。

## 6. File Permission

检查：

```bash
ls -l
stat FILE
```

理解：

```text
owner
group
other
rwx
```

## 7. Sensitive File

例如：

- private key
- config credential
- SSH authorized_keys

需要严格权限。

## 8. Updates

安全更新流程需要：

```text
inventory
 -> update
 -> reboot if required
 -> verify
```

生产环境还需变更窗口。

## 9. Logs

Linux 常见：

- journalctl
- auth logs
- kernel logs
- service logs

例如本地：

```bash
journalctl -n 50
```

WSL 环境行为可能不同。

## 10. Audit

需要回答：

```text
who changed what
when
from where
result
```

高安全环境可进一步研究 auditd。

## 11. Kernel / Sysctl

网络安全参数可能涉及：

```text
IP forwarding
redirect
source routing
```

修改前必须理解影响，最好在 disposable VM/namespace 中实验。

## 12. 练习

1. 用 ss 建立本机监听基线。
2. 找出每个监听端口对应服务。
3. 检查一个 private file 权限。
4. 写 Host Hardening Checklist。
5. 解释容器安全为什么不能替代 Host 安全。

## 13. 完成标准

你应该能从网络、账户、服务、文件和日志五个维度检查 Linux Host。
