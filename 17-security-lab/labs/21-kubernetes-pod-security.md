# Lab 21 - Kubernetes Pod Security 与 SecurityContext

## 目标

把容器最小权限原则落到 Kubernetes Pod。

重点学习：

- runAsNonRoot
- runAsUser
- allowPrivilegeEscalation
- readOnlyRootFilesystem
- capabilities
- seccomp
- privileged
- hostPath
- hostNetwork

## 1. securityContext

Pod / Container 都可以配置 securityContext。

典型思路：

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
```

## 2. 非 root

```text
runAsNonRoot: true
```

表示 Kubernetes 应拒绝明确以 root 运行的容器配置。

但镜像本身也需要支持非 root。

## 3. allowPrivilegeEscalation

设置：

```text
false
```

可以减少进程通过某些机制获得额外权限。

## 4. Capabilities

推荐思路：

```yaml
capabilities:
  drop:
    - ALL
```

然后只添加业务真正需要的能力。

## 5. readOnlyRootFilesystem

如果应用不需要修改根文件系统：

```yaml
readOnlyRootFilesystem: true
```

临时写入可以单独用：

- emptyDir
- tmpfs-like memory volume

## 6. seccomp

seccomp 用于限制系统调用。

Kubernetes 常见：

```yaml
seccompProfile:
  type: RuntimeDefault
```

这提供运行时默认系统调用过滤。

## 7. privileged

```text
privileged: true
```

通常意味着非常高的权限。

生产 workload 应尽量避免。

## 8. hostPath

hostPath 把节点文件系统挂入 Pod。

风险取决于：

- 路径
- read/write
- workload 权限

尤其敏感：

```text
/etc
/var/lib
/var/run
docker/container runtime socket
```

## 9. hostNetwork / hostPID

这些选项会减少 Pod 与 Host 的隔离。

不要为了“调试方便”默认开启。

## 10. Pod Security Standards

Kubernetes 常用三种概念等级：

- Privileged
- Baseline
- Restricted

学习目标不是死记标签，而是理解 Restricted 强调：

```text
non-root
no privilege escalation
limited capabilities
safe seccomp
```

## 11. 验证

```bash
kubectl get pod -n security-lab -o yaml
```

检查最终实际配置，而不是只看模板。

## 12. 与 RBAC 的区别

RBAC：

```text
Pod identity -> Kubernetes API permission
```

securityContext：

```text
process -> Linux runtime privilege
```

两者完全不同。

## 13. 练习

1. 给一个普通 Web Pod 写 Restricted 风格 securityContext。
2. 列出它必须可写的目录。
3. 解释 privileged Pod 的 blast radius。
4. 解释 hostPath 为什么需要严格审核。
5. 比较 RBAC 与 Linux capabilities。

## 14. 完成标准

你应该能够设计：

> API 权限最小 + Linux 运行时权限最小

两套独立控制。
