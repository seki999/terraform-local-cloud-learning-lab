# Lab 42 - Tabletop Exercise：安全事件桌面演练

## 目标

不运行攻击工具，仅通过场景讨论练习跨团队事件响应。

## 场景

09:00 监控发现：

```text
/admin.txt 访问量异常增加
```

09:05 同时发现：

```text
target 出现新的 outbound connection
```

09:10 开发团队报告：

```text
昨天刚上线新版本
```

## Round 1 - Detect

回答：

- 谁先收到告警？
- 什么证据足够开始调查？
- 哪些日志最重要？
- 是否需要立即阻断？

## Round 2 - Scope

需要确认：

- affected service
- affected version
- affected data
- affected identity
- affected environment

## Round 3 - Contain

可能措施：

- deny sensitive endpoint
- isolate workload
- revoke credential
- rollback deployment

每个动作都要评估业务影响。

## Round 4 - Evidence

保留：

- logs
- deployment commit
- image digest
- config
- recent IAM change
- network evidence

## Round 5 - Root Cause

假设可能包括：

- configuration regression
- leaked credential
- application bug
- false positive

必须用证据逐个验证。

## Round 6 - Recovery

恢复前：

- fix deployed
- positive test
- negative test
- monitoring enabled
- credential rotated if needed

## Round 7 - Communication

不同对象需要不同信息：

- engineering
- management
- security
- customer/support

不要在证据不足时给出未经验证结论。

## Round 8 - Lessons Learned

输出：

- what worked
- what failed
- missing logs
- missing owner
- automation opportunity
- follow-up date

## 练习模板

每个参与者回答：

```text
My role:
My first action:
Evidence I need:
Decision I own:
Escalation condition:
```

## 完成标准

你应该能在没有任何“攻击操作”的情况下，完整演练 Detect → Respond → Recover。
