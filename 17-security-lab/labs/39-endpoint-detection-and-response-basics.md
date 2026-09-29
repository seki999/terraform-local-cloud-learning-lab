# Lab 39 - Endpoint Detection & Response 基础

## 目标

把安全观察从网络扩展到主机进程和行为。

EDR 思维关注：

- process
- parent/child
- file
- registry/config
- network
- user
- timeline

## 1. Process Tree

进程不是孤立事件。

关键问题：

```text
who started it?
what parent?
what command?
what user?
what network?
```

## 2. Windows

可观察：

```powershell
Get-Process
Get-CimInstance Win32_Process
```

本地学习时只检查自己的主机。

## 3. Linux

```bash
ps aux
pstree
```

关注服务父子关系。

## 4. File Change

重要配置文件变化可能是：

- legitimate deployment
- admin operation
- compromise

所以需要：

- owner
- change record
- timestamp

## 5. Persistence

企业 EDR 会关注各种持久化位置。

本课程不做持久化攻击，只学习防守方为什么要建立：

- startup inventory
- service inventory
- scheduled task inventory

## 6. Scheduled Task

Windows Task Scheduler / cron 都是正常管理机制，也应纳入资产和变更管理。

## 7. Network Correlation

如果某个异常进程同时建立异常网络连接：

```text
process evidence
+
network evidence
```

调查价值更高。

## 8. User Context

同一命令由：

- system
- admin
- normal user

执行，风险意义可能不同。

## 9. Detection Rule

概念规则：

```text
unexpected process
+
unexpected parent
+
unexpected outbound connection
```

比单一进程名更可靠。

## 10. False Positive

开发工具、安装程序、自动更新都可能产生“奇怪”行为。

必须结合环境。

## 11. Triage

调查顺序：

```text
process
 -> parent
 -> user
 -> binary path
 -> file hash/signature
 -> network
 -> timeline
```

## 12. 完成标准

你应该能把 endpoint evidence 和 network/application evidence 放进同一个事件时间线。
