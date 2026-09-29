# Lab 27 - Secure SDLC 与安全代码审查

## 目标

把安全从“部署后检查”前移到开发流程。

Secure SDLC 不是新增一个最终审批步骤，而是让安全进入：

```text
requirements
 -> design
 -> coding
 -> review
 -> build
 -> test
 -> deploy
 -> operate
```

## 1. Requirements

需求阶段就明确：

- 哪些数据敏感
- 谁能访问
- 是否需要 TLS
- 日志保留多久
- 是否允许公网访问
- RPO/RTO

如果需求没有这些约束，后面很容易出现默认不安全设计。

## 2. Design Review

设计评审应问：

```text
assets?
trust boundaries?
identities?
data flow?
public endpoints?
admin endpoints?
secrets?
failure modes?
```

这和 Lab 01 Threat Model 直接连接。

## 3. Code Review

安全代码审查重点：

- 输入验证
- 权限检查
- secret
- dangerous defaults
- error handling
- logging
- file access
- network calls

## 4. Review Checklist

Pull Request 可加入：

```text
[ ] 新增 endpoint 是否有 auth
[ ] 是否新增公网暴露
[ ] 是否新增 secret
[ ] 是否修改权限
[ ] 是否记录敏感信息
[ ] 是否有 negative test
```

## 5. Static Analysis

SAST 用于分析 source/code pattern。

它适合发现：

- dangerous API
- insecure pattern
- missing validation pattern

但会有 false positive。

## 6. Dependency Analysis

SCA 用于检查第三方依赖：

- known vulnerability
- version
- license

SAST 与 SCA 关注点不同。

## 7. Security Unit Test

例：

```text
anonymous admin request -> denied
normal user admin request -> denied
admin request -> allowed
```

安全行为应该像业务逻辑一样可测试。

## 8. Integration Test

网络安全测试也可进入 CI：

```text
deploy ephemeral environment
 -> test expected open ports
 -> test sensitive endpoint denied
 -> destroy
```

## 9. Threat Model 更新

架构变化后 Threat Model 也要更新。

例如新增：

```text
third-party API
```

意味着新的：

- trust boundary
- credential
- egress
- failure mode

## 10. Security Debt

有时安全问题不能马上解决。

应像技术债一样记录：

- owner
- risk
- mitigation
- due date
- review date

## 11. Definition of Done

一个安全敏感功能的 DoD 可以包含：

- auth implemented
- authorization tested
- logs added
- no secrets committed
- IaC validation updated
- rollback documented

## 12. 练习

1. 给一个新 API 写 Security Requirements。
2. 写一份 PR Security Checklist。
3. 设计 3 个 negative tests。
4. 区分 SAST 与 SCA。
5. 把 Threat Model 加进设计评审模板。

## 13. 完成标准

你应该能把安全从“上线后扫描”前移到整个软件生命周期。
