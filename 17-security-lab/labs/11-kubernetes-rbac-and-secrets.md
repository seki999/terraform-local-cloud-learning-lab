# Lab 11 - Kubernetes RBAC、ServiceAccount 与 Secret

## 目标

在 Kubernetes 中学习“身份”和“权限”。

重点：

- ServiceAccount
- Role
- ClusterRole
- RoleBinding
- ClusterRoleBinding
- Secret
- least privilege
- kubectl auth can-i

## 1. 身份路径

一个 Pod 调 Kubernetes API 时：

```text
Pod
 -> ServiceAccount
 -> Token / identity
 -> RBAC evaluation
 -> allowed / denied
```

## 2. 不要默认给 cluster-admin

最危险的简化之一：

```text
application service account
 -> cluster-admin
```

这样任何应用层问题都有可能放大成集群级风险。

## 3. Role 与 ClusterRole

Role：

- namespace scoped

ClusterRole：

- 可以定义 cluster-scoped 权限
- 也可通过 RoleBinding 在 namespace 内绑定

## 4. 最小权限例子

假设应用只需要读取 ConfigMap：

```yaml
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list"]
```

不要顺手给：

```text
*
*
```

## 5. kubectl auth can-i

这是非常有价值的验证工具：

```bash
kubectl auth can-i get pods
kubectl auth can-i delete pods
```

也可以模拟某个 ServiceAccount：

```bash
kubectl auth can-i get configmaps   --as=system:serviceaccount:<namespace>:<serviceaccount>
```

只在你的本地集群验证。

## 6. 权限矩阵

| Identity | Get ConfigMap | List Pods | Delete Pods | Read Secrets |
|---|---:|---:|---:|---:|
| app-reader | yes | no | no | no |
| ops-viewer | yes | yes | no | no |
| admin | yes | yes | yes | controlled |

安全设计要把这个表写清楚。

## 7. Secret 不是“自动安全保险箱”

Kubernetes Secret 的重点是：

- 独立资源类型
- 更适合权限控制
- 可被挂载或注入

但 base64 并不是加密。

所以仍然要关注：

- RBAC
- etcd encryption at rest
- external secret manager
- rotation
- audit

## 8. 不要在日志里输出 Secret

典型风险：

```text
application starts
 -> debug log prints ENV
 -> secret appears in logs
```

因此敏感配置处理要覆盖完整生命周期。

## 9. ServiceAccount 自动挂载

不是所有 Pod 都需要访问 Kubernetes API。

如果不需要，考虑：

```yaml
automountServiceAccountToken: false
```

减少不必要 credential 暴露。

## 10. RoleBinding 与 ClusterRoleBinding

RoleBinding 的影响范围小，优先使用 namespace scoped 设计。

ClusterRoleBinding 会把权限扩展到整个 cluster，使用时需要更谨慎。

## 11. 验证失败也很重要

测试至少包含：

```text
expected allow
expected deny
```

只有 allow 测试无法证明权限足够收敛。

## 12. 常见错误

- ServiceAccount 共用
- 给了 verbs ["*"]
- 给了 resources ["*"]
- ClusterRoleBinding 范围过大
- 应用不需要 API 却保留 token
- Secret 被写进 Git

## 13. 练习

1. 创建一个只读 ConfigMap 的 Role。
2. 绑定到专用 ServiceAccount。
3. 用 `kubectl auth can-i` 验证 get=yes。
4. 验证 delete pod=no。
5. 解释为什么 base64 Secret 不等于加密。

## 14. 完成标准

你应该能解释：

> Kubernetes 权限设计的核心是“每个工作负载有自己的身份，并且只获得完成任务所需的最小 API 权限”。
