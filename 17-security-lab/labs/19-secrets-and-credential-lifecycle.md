# Lab 19 - Secret 与 Credential 生命周期

## 目标

把 Secret 从“一个字符串”提升成完整生命周期管理问题。

学习：

```text
create
 -> distribute
 -> store
 -> use
 -> rotate
 -> revoke
 -> audit
 -> destroy
```

## 1. 什么属于 Secret

常见：

- password
- API key
- access token
- private key
- database credential
- webhook secret
- signing key

## 2. 不要放进 Git

错误：

```text
config.prod.json
password=...
```

即使之后删除，Git history 也可能保留。

## 3. 环境变量

环境变量方便，但也要注意：

- debug dump
- process inspection
- crash report
- child process inheritance

所以“环境变量”不等于“安全 secret store”。

## 4. 文件挂载

可把 secret 以只读文件挂载到容器。

优势：

- 可限制文件权限
- 不必进入镜像层

仍需考虑：

- host file ownership
- backup
- rotation

## 5. Kubernetes Secret

Kubernetes Secret 应配合：

- RBAC
- encryption at rest
- dedicated ServiceAccount
- minimal mount scope

不要认为 base64 自动提供加密。

## 6. Vault / External Secret Manager

集中 secret manager 可以提供：

- dynamic credential
- TTL
- audit
- rotation
- revocation

这正好和仓库中的 09-vault 对接。

## 7. Short-lived Credential

短时凭据比长期静态 key 更容易控制风险。

概念：

```text
identity proves itself
 -> gets temporary credential
 -> credential expires
```

## 8. Rotation

好的轮换方案应该避免“大爆炸式停机”。

通常：

```text
create new
 -> deploy consumers
 -> verify
 -> revoke old
```

## 9. 泄露响应

发现 credential 泄露：

1. 评估作用域；
2. 立即 revoke/rotate；
3. 查日志；
4. 清理仓库与缓存；
5. 检查是否被使用；
6. 修复根因；
7. 添加自动扫描。

## 10. Secret Scanner

CI 可检测疑似：

- private key
- cloud access key
- token pattern

但 scanner 可能：

- false positive
- false negative

不能代替流程。

## 11. 权限最小化

如果 token 只需要 read：

```text
read only
```

不要给：

```text
admin
```

即使泄露，blast radius 也更小。

## 12. 练习

1. 列出你项目里的 secret 类型。
2. 为每种写 owner、TTL、rotation。
3. 设计泄露响应流程。
4. 解释为什么“删除 Git 文件”不够。
5. 把 09-vault 和本章连接起来，设计动态 credential 思路。

## 13. 完成标准

你应该能说明：

> Secret 安全的核心不是“藏在哪里”，而是整个生命周期都可控制、可轮换、可撤销、可审计。
