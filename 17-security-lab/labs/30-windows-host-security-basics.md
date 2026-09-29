# Lab 30 - Windows Host Security 基础

## 目标

仓库主要运行在 Windows 11 + WSL2 + Docker Desktop，因此 Windows Host 也是实验安全边界的一部分。

学习：

- Defender Firewall
- listening ports
- local users/groups
- process
- PowerShell logging
- BitLocker 概念
- update
- WSL/Docker boundary

## 1. 网络监听

PowerShell：

```powershell
Get-NetTCPConnection -State Listen
```

结合：

```powershell
Get-Process -Id <PID>
```

建立：

```text
Port -> Process -> Purpose
```

映射。

## 2. Windows Firewall

查看 profile：

```powershell
Get-NetFirewallProfile
```

查看规则：

```powershell
Get-NetFirewallRule | Select-Object -First 20
```

不要随意关闭整个防火墙来“解决问题”。

## 3. Network Profile

Windows 有：

- Domain
- Private
- Public

不同 profile 可以应用不同 firewall policy。

## 4. Local Users

```powershell
Get-LocalUser
Get-LocalGroup
```

重点检查：

- 不必要管理员
- 禁用账户
- 权限范围

## 5. Administrator

日常工作尽量使用普通用户，需要时提升权限。

原则：

```text
standard user by default
elevation only when required
```

## 6. Defender

Windows Security / Defender 提供：

- antivirus
- reputation
- firewall
- exploit protection

学习重点是理解状态和日志，而不是关闭保护。

## 7. PowerShell

PowerShell 是强大的管理工具，因此企业常关注：

- script block logging
- module logging
- transcription
- execution policy

Execution Policy 不是强安全边界。

## 8. BitLocker

磁盘加密保护：

```text
device lost/offline
 -> data at rest
```

但无法代替在线状态下的权限控制。

## 9. Windows Update

补丁状态也是安全基线。

要考虑：

- OS
- drivers
- browser
- Docker Desktop
- WSL kernel

## 10. WSL2

WSL2 有自己的 Linux 网络和进程环境。

需要理解：

```text
Windows Host
 <-> WSL VM
 <-> Docker Desktop
 <-> containers
```

边界。

## 11. Docker Desktop

安全关注：

- exposed ports
- file sharing
- mounted directories
- Docker context
- privileged containers

## 12. 练习

1. 列出监听端口并标记用途。
2. 查看 firewall profile。
3. 检查本地管理员组成员。
4. 画 Windows/WSL/Docker 信任边界。
5. 解释为什么 Execution Policy 不是完整安全控制。

## 13. 完成标准

你应该把 Windows Host 看成整个本地安全实验室的根安全边界之一。
