# 05 - Kubernetes 深入实验

> Stage 5 / 12 ｜ 前置章节：[04-kind](../04-kind/README.md) ｜
> 概念参考：[docs/06-kubernetes-basics.md](../docs/06-kubernetes-basics.md)

## 本章目标

前面几章已经用过 Namespace / Deployment / Service / ConfigMap / Secret /
PVC / Ingress。这一章把 Kubernetes 剩下的核心对象逐一拆开、独立成
13 个小实验，每个都能单独 `init/apply/destroy`，专注讲清楚**一个对象**。

## 使用的集群

统一使用第 4 章创建的 Kind 集群（context `kind-terraform-lab`）。
如果该集群已被删除，先回到 [04-kind](../04-kind/README.md) 重新创建：

```powershell
cd ..\04-kind
.\scripts\create-cluster.ps1
```

## 子实验列表

| 目录 | 对象 | 一句话说明 |
|---|---|---|
| [01-namespace](01-namespace/README.md) | Namespace | 逻辑隔离边界，ResourceQuota 初探 |
| [02-deployment](02-deployment/README.md) | Deployment / ReplicaSet | 滚动升级与版本历史 |
| [03-service](03-service/README.md) | Service | ClusterIP / NodePort / Headless 对比 |
| [04-configmap](04-configmap/README.md) | ConfigMap | 环境变量注入 vs 文件挂载两种消费方式 |
| [05-secret](05-secret/README.md) | Secret | Opaque vs 内置类型，State 里的明文陷阱 |
| [06-pvc](06-pvc/README.md) | PersistentVolumeClaim | StorageClass 动态供给全过程 |
| [07-statefulset](07-statefulset/README.md) | StatefulSet | 有序编号 Pod 与稳定网络标识 |
| [08-daemonset](08-daemonset/README.md) | DaemonSet | 每节点一份，天然对比 04-kind 的手工打散 |
| [09-job-cronjob](09-job-cronjob/README.md) | Job / CronJob | 一次性任务与定时任务 |
| [10-ingress](10-ingress/README.md) | Ingress | 多路径/多域名路由规则组合 |
| [11-rbac](11-rbac/README.md) | ServiceAccount/Role/RoleBinding/ClusterRole/ClusterRoleBinding | 最小权限模型 |
| [12-networkpolicy](12-networkpolicy/README.md) | NetworkPolicy | 默认全通 vs 显式白名单隔离 |
| [13-probes-resources](13-probes-resources/README.md) | Resource Request/Limit、三种 Probe | QoS 等级与自愈机制 |

## 学习建议

这 13 个子实验**不要求严格按顺序**，但 01 → 02 → 03 → 04/05 → 06 之间有
递进关系（Namespace 是一切的容器，Deployment 消费 ConfigMap/Secret，
Service 暴露 Deployment），建议至少按这个子集的顺序完成。
07-13 相对独立，可以根据兴趣挑选。

## 统一约定

- 每个子实验都在自己的 Namespace 里创建资源（名称形如
  `learning-05-XX`），互不干扰，可以任意顺序 apply/destroy；
- 每个子实验的镜像统一使用 `nginx:1.27-alpine` 或
  `hashicorp/http-echo:latest`，避免引入新的学习成本；
- 每个子实验都遵循和前面章节一致的 provider 配置
  （`config_context = "kind-terraform-lab"`）。
