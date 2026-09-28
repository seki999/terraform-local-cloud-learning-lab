# Lab 12 - Terraform / IaC 安全

## 目标

把安全控制提前到“部署之前”。

学习：

- IaC misconfiguration
- 安全默认值
- variable validation
- precondition / postcondition
- terraform test
- 静态扫描思想
- plan review
- state 敏感数据

## 1. 为什么 IaC 安全很重要

如果错误配置已经写进 Terraform：

```text
one bad config
 -> repeated deployment
 -> many environments
```

所以 IaC 同时是风险放大器，也是安全自动化入口。

## 2. 安全默认值

变量应该尽量默认安全。

例如：

```text
public_access = false
admin_port_exposed = false
allow_from = loopback/internal only
```

而不是默认全开放。

## 3. validation

示意：

```hcl
variable "listen_address" {
  type    = string
  default = "127.0.0.1"

  validation {
    condition     = var.listen_address != "0.0.0.0"
    error_message = "Security lab service must not bind to all interfaces."
  }
}
```

这里不是说 0.0.0.0 永远错误，而是把本实验安全边界编码进规则。

## 4. precondition

资源创建前检查：

```text
is this configuration acceptable?
```

适合约束：

- 必须启用 encryption
- 不允许 public access
- required tags
- allowed CIDR

## 5. postcondition

资源创建后验证 provider 返回结果。

例如：

```text
resource actually has expected secure setting
```

## 6. terraform test

安全测试也应自动化。

思路：

```text
secure input -> plan succeeds
unsafe input -> plan rejected
apply -> output matches secure expectation
```

把它和 13-testing 章节结合。

## 7. Plan 是安全审查点

```terraform
terraform plan
```

不要只看：

```text
+ create
~ update
- destroy
```

还要看：

- 是否新增公网入口
- 是否新增宽 CIDR
- 是否删除 encryption
- 是否输出 secret
- 是否扩大 IAM/RBAC

## 8. State 安全

Terraform state 可能包含：

- resource IDs
- addresses
- configuration
- sometimes sensitive values

因此 state 不应随意提交 Git。

需要：

- access control
- encryption
- backup
- locking
- secret hygiene

## 9. sensitive = true 的局限

Terraform 的 sensitive 标记主要控制 CLI/UI 展示。

它不意味着：

> secret 不会存在 state。

必须理解这个区别。

## 10. 静态扫描

IaC scanner 的价值是：

```text
code
 -> known policy checks
 -> findings
 -> fix before deploy
```

可以研究：

- Checkov
- tfsec / Trivy config
- Terrascan

工具不是最终裁判，规则必须结合环境。

## 11. Policy as Code

更成熟的组织会把策略写成自动规则：

```text
No public DB
Encryption required
No wildcard admin privilege
Required logging
```

CI 中自动执行。

## 12. 安全测试案例

设计：

```text
Case 1: loopback bind -> pass
Case 2: all-interface bind -> fail
Case 3: admin endpoint public -> fail
Case 4: logging disabled -> warning/fail
```

## 13. 练习

1. 给实验变量增加 validation。
2. 写一个 unsafe case。
3. 用 terraform test 验证它被拒绝。
4. 检查 state 是否包含你不希望存储的信息。
5. 写 5 条自己的 IaC security policy。

## 14. 完成标准

你应该能说明：

> 最有效的安全修复之一，是让错误配置在 plan/CI 阶段就无法进入部署。
