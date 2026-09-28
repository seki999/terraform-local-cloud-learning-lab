# Lab 13 - 安全事件响应与取证基础

## 目标

学习当“异常已经发生”时如何处理。

本章不做真实攻击溯源，而是在本地实验里建立 Incident Response 基本流程：

```text
Prepare
 -> Detect
 -> Triage
 -> Contain
 -> Eradicate
 -> Recover
 -> Lessons Learned
```

## 1. 场景

假设你发现日志中出现：

```text
GET /admin.txt 200
```

但正常用户不应该访问该路径。

问题不是马上“谁是黑客”，而是先回答：

- 发生了什么？
- 影响什么资产？
- 是否仍在继续？
- 能否快速降低风险？
- 有什么证据？

## 2. Prepare

事前准备包括：

- 日志
- 时间同步
- 资产清单
- 联系路径
- 恢复步骤
- 备份
- runbook

没有准备时，事件发生后会非常混乱。

## 3. Detect

本地：

```powershell
docker compose logs --tail 100 target
```

关注：

- unusual path
- status
- source
- frequency
- timestamp

## 4. Triage

给事件定范围。

例：

```text
Affected service: local-security-target
Affected resource: /admin.txt
Observed result: HTTP 200
Persistence: none
External exposure: loopback only
Severity in lab: controlled
```

## 5. Contain

Containment 目标是先减少继续影响。

本实验可以：

- 临时 403
- 停止 target
- 取消 host port publishing
- 隔离 network

生产环境 containment 必须兼顾业务影响。

## 6. Preserve Evidence

不要先清空日志再排查。

建议保留：

- relevant logs
- timestamps
- configuration before change
- configuration after change
- request evidence
- packet capture if available

## 7. Eradicate

找根因。

这里根因不是“有人请求了路径”，而是：

> 敏感资源被错误地放在可公开读取的位置。

真正修复可能包括：

- remove file from web root
- authentication
- authorization
- network restriction

## 8. Recover

修复后恢复服务：

```text
syntax test
 -> reload
 -> health test
 -> negative security test
 -> monitor
```

## 9. Lessons Learned

事件后要问：

- 为什么最初配置允许它？
- 为什么测试没发现？
- 是否需要自动化检测？
- 是否需要 IaC validation？
- 其他环境是否有同类问题？

## 10. 时间线模板

```text
T0  deployment
T1  unexpected access
T2  alert/observation
T3  containment
T4  root cause identified
T5  fix deployed
T6  re-test passed
T7  follow-up action
```

## 11. 证据与假设分开

写：

```text
Evidence: GET /admin.txt returned 200 at 10:03.
Hypothesis: client was enumerating sensitive paths.
```

不要把 hypothesis 写成已经证实的事实。

## 12. 练习

1. 制造一次本地 admin.txt 200。
2. 保存相关日志。
3. 写出 6 行时间线。
4. 应用 hardened.conf。
5. 复测 403。
6. 写一个 5 条 action items 的 postmortem。

## 13. 完成标准

你应该能说明：

> 事件响应的目标不是马上归咎某个人，而是快速控制影响、保存证据、找根因、恢复服务并避免再次发生。
