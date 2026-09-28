# Lab 10 - Kubernetes NetworkPolicy

## 目标

把 Docker 网络分段思想迁移到 Kubernetes。

学习：

- Pod-to-Pod 默认连通
- NetworkPolicy
- default deny
- ingress allow
- egress allow
- label selector
- 验证矩阵

## 1. 为什么 Kubernetes 还要 NetworkPolicy

很多集群默认情况下，同一网络中的 Pod 可以互相通信。

应用可能长这样：

```text
frontend
 -> api
 -> database
```

理想规则：

```text
frontend -> api      allow
api -> database      allow
frontend -> database deny
random pod -> db     deny
```

## 2. 前置条件

NetworkPolicy 是否真正生效取决于 CNI。

不是“创建 YAML 就一定生效”。

先确认你的 Minikube/Kind 网络插件是否支持 NetworkPolicy。

## 3. default deny 思路

典型策略：

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

含义不是“删除网络”，而是让被策略选择的 Pod 默认没有允许的流量。

## 4. 只允许 frontend -> api

概念：

```yaml
podSelector:
  matchLabels:
    app: api
ingress:
  - from:
      - podSelector:
          matchLabels:
            app: frontend
    ports:
      - protocol: TCP
        port: 8080
```

重点是 label，而不是固定 Pod IP。

## 5. 为什么使用 label

Pod 会重建，IP 会变化。

Kubernetes 的策略应该围绕 workload identity：

```text
app=frontend
app=api
role=db
```

而不是手写动态 IP。

## 6. 验证矩阵

| Source | Destination | Expected |
|---|---|---|
| frontend | api:8080 | allow |
| debug | api:8080 | deny |
| api | db:5432 | allow |
| frontend | db:5432 | deny |

必须测正向与反向。

## 7. kubectl 验证

查看：

```bash
kubectl get networkpolicy -A
kubectl describe networkpolicy -n <namespace>
```

测试时使用你自己创建的测试 Pod。

## 8. DNS 例外

启用 egress default deny 后，一个很常见的问题是：

> Pod 连 DNS 都访问不了。

因为 DNS 本身也是网络流量。

因此要明确允许：

```text
workload -> cluster DNS UDP/TCP 53
```

具体 label/namespace 取决于集群环境。

## 9. NetworkPolicy 不解决什么

它不直接解决：

- HTTP 用户权限
- TLS 证书
- Secret 泄露
- container root
- image vulnerability

它是网络层的 workload segmentation。

## 10. Namespace 隔离

除了 podSelector，还可以结合 namespaceSelector。

典型需求：

```text
only namespace=frontend
can access namespace=backend
```

需要注意 selector 组合语义。

## 11. 常见错误

- CNI 不支持，策略看起来存在但不执行
- label 写错
- 忘记 DNS
- 只做 ingress，不考虑 egress
- policyTypes 与规则不一致
- 测试 Pod 本身 label 不符合预期

## 12. 排障顺序

```text
Pod Ready?
 -> Service endpoints?
 -> DNS?
 -> NetworkPolicy selected?
 -> source labels?
 -> destination labels?
 -> port/protocol?
 -> CNI supports policy?
```

## 13. 练习

1. 设计 frontend/api/db 三层 policy。
2. 先 default deny。
3. 逐条允许必要流量。
4. 建立 4x4 connectivity matrix。
5. 解释为什么 IP allowlist 在 Kubernetes 里通常不如 label-based policy 稳定。

## 14. 完成标准

你应该能说明：

> NetworkPolicy 的目标不是“让网络更复杂”，而是把 Pod 间默认互信改成基于业务关系的最小连通。
