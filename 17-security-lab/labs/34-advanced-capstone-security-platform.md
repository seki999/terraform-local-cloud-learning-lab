# Lab 34 - Advanced Capstone：本地安全平台综合设计

## 目标

这是第二阶段毕业实验。

你需要设计一个比 Lab 14 更完整的本地安全平台，并证明：

```text
network
identity
runtime
supply chain
observability
recovery
IaC
```

都被纳入同一套工程流程。

## 场景

构建：

```text
Client
  |
Reverse Proxy
  |
Frontend
  |
API
  |
Database

Monitoring
Secret Store
CI/CD
Kubernetes
Terraform
```

可以只做设计 + 本地可运行的关键子集，不要求一次实现完整企业平台。

## Phase 1 - Asset Inventory

至少列：

- source code
- container image
- secret
- workload identity
- application data
- logs
- Terraform state
- CI credential
- backup

## Phase 2 - Data Classification

给每个资产标：

```text
public
internal
confidential
secret
```

## Phase 3 - Trust Boundaries

至少画：

1. user -> edge
2. edge -> app
3. app -> data
4. workload -> Kubernetes API
5. CI -> registry
6. CI -> deployment
7. service -> external dependency

## Phase 4 - Network Policy

建立矩阵：

| Source | Destination | Port | Decision |
|---|---|---:|---|
| client | proxy | 443 | allow |
| client | db | 5432 | deny |
| frontend | api | 8080 | allow |
| api | db | 5432 | allow |
| db | internet | any | deny |

## Phase 5 - Identity

为：

- user
- admin
- frontend
- api
- CI

定义不同 identity。

## Phase 6 - Secret

每个 Secret 指定：

- owner
- storage
- TTL
- rotation
- revoke

## Phase 7 - Runtime

每个 Pod 检查：

- non-root
- capabilities
- seccomp
- read-only root filesystem
- resources
- ServiceAccount

## Phase 8 - Supply Chain

设计：

```text
source
 -> build
 -> test
 -> SAST/SCA
 -> image scan
 -> SBOM
 -> sign
 -> registry
 -> deploy
```

## Phase 9 - IaC

写安全 guardrails：

- no public DB
- restricted bind
- logging required
- encryption required
- no wildcard admin policy

## Phase 10 - Observability

设计 dashboard：

- request rate
- 4xx/5xx
- auth failure
- denied network
- pod restart
- vulnerability status

## Phase 11 - Alerts

至少 5 个：

- sensitive path access
- auth failure burst
- unexpected egress
- privilege policy violation
- backup failure

## Phase 12 - Recovery

定义：

```text
RPO
RTO
backup
restore drill
```

## Phase 13 - Incident Exercise

模拟一个本地、无破坏场景：

```text
unexpected sensitive-path access
```

然后完成：

```text
detect
triage
contain
fix
recover
re-test
postmortem
```

## Phase 14 - Compliance Evidence

保存：

- config
- test output
- scan output
- policy result
- logs
- approval/notes

## Phase 15 - Final Architecture Document

至少包含：

```markdown
# Security Architecture

## Scope
## Assets
## Data Classification
## Trust Boundaries
## Network Controls
## Identity and RBAC
## Secrets
## Runtime Security
## Supply Chain
## IaC Guardrails
## Logging and Alerts
## Backup and Recovery
## Incident Response
## Residual Risks
```

## 最终问题

你必须能回答：

1. 哪些服务公开？
2. 为什么公开？
3. 谁可以访问？
4. 访问如何认证？
5. 权限如何限制？
6. 数据是否加密？
7. Workload 能访问哪里？
8. Secret 如何轮换？
9. 镜像从哪里来？
10. 发现异常以后谁处理？
11. 数据丢失如何恢复？
12. 怎样证明修复有效？

## 毕业标准

如果你能完成：

```text
Design
 -> Build
 -> Verify
 -> Observe
 -> Harden
 -> Recover
 -> Automate
 -> Document
```

就已经从“学安全命令”进入“安全工程系统思维”阶段。
