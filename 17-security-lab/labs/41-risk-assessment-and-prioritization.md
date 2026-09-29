# Lab 41 - 风险评估与优先级

## 目标

安全工作永远有更多问题 than time。

需要学会排序。

## 1. Risk

简化：

```text
Risk = likelihood x impact
```

不是精确物理公式，而是讨论工具。

## 2. Impact

考虑：

- confidentiality
- integrity
- availability
- financial
- legal
- operational

## 3. Likelihood

考虑：

- exposure
- attacker prerequisite
- exploit maturity
- control strength
- frequency

## 4. Asset Criticality

同一个漏洞：

```text
test container
production payment DB
```

风险完全不同。

## 5. Exposure

公网、内网、localhost 的暴露面不同。

所以 Lab 中：

```text
127.0.0.1
```

就是重要风险降低因素。

## 6. Compensating Control

无法立即修复时：

- firewall
- access restriction
- monitoring
- feature disable

可降低风险。

## 7. Risk Register

字段：

```text
ID
Asset
Finding
Likelihood
Impact
Owner
Mitigation
Due Date
Status
Residual Risk
```

## 8. Prioritize

不要只按 CVSS。

综合：

```text
severity
exposure
business criticality
exploitability
existing controls
```

## 9. Residual Risk

修复后仍可能有风险。

例如：

```text
admin endpoint protected by auth
but still internet-reachable
```

剩余风险仍需记录。

## 10. Risk Acceptance

接受风险应该：

- 有明确 owner
- 有理由
- 有有效期
- 可重新评审

## 11. 练习

为本课程找 5 个 finding，做 3x3 风险矩阵，并说明排序理由。

## 12. 完成标准

你应该能解释为什么“技术上严重”与“业务上优先”并不总是相同。
