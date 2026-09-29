# Lab 28 - CI/CD Pipeline Security

## 目标

理解 CI/CD 自己也是高价值系统。

Pipeline 往往能够：

- 读源码
- 读 secret
- 构建 artifact
- 推送 image
- 部署生产

所以 Pipeline 权限非常敏感。

## 1. Pipeline Threat Model

资产：

- source
- signing key
- registry credential
- cloud credential
- deployment token

入口：

- Pull Request
- dependency
- CI action/plugin
- build script

## 2. 最小权限

CI token 只给实际需要权限。

例如 build job 不应该默认拥有 production deploy 权限。

## 3. PR 与 Secret

来自不可信 fork/PR 的代码，不应该轻易获得 production secret。

否则攻击代码可能读取环境变量并外传。

## 4. Environment Separation

```text
build credential
test credential
staging credential
production credential
```

应该分离。

## 5. Protected Environment

生产 deploy 可以要求：

- approved branch
- reviewer
- manual approval
- protected environment

## 6. Artifact Promotion

推荐：

```text
build once
 -> test same artifact
 -> scan
 -> sign
 -> promote
```

不要 staging 与 prod 各自重新构建不同 artifact。

## 7. Pin Dependencies

第三方 CI action / plugin 应尽量固定明确版本。

避免：

```text
latest
main
master
```

成为不可预期变更来源。

## 8. Secret Masking

日志 masking 有用，但不是完整保护。

如果代码主动编码、拆分或写文件，masking 可能无法阻止泄露。

根本控制仍是：

> 不让不可信代码拿到 secret。

## 9. Deployment Identity

更现代的 CI 可以通过 federation/OIDC 获取短期云凭据，而不是存长期 access key。

核心价值：

- short TTL
- traceable identity
- easier revoke

## 10. CI Security Gates

可以加入：

```text
terraform fmt
terraform validate
terraform test
SAST
SCA
image scan
IaC scan
unit tests
policy checks
```

## 11. Break Glass

紧急部署路径也要：

- 记录
- 最小权限
- 审批
- 事后审查

## 12. 练习

1. 画出 CI/CD trust boundary。
2. 列出 5 个 Pipeline secret。
3. 设计 build/deploy 权限分离。
4. 解释 OIDC 短期凭据优势。
5. 设计一个安全 Gate 顺序。

## 13. 完成标准

你应该理解：

> CI/CD 是生产权限的自动化入口，因此它本身必须作为高价值资产保护。
