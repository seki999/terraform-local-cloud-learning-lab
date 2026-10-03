# 03 - Terraform + Minikube

> Stage 3 / 12 ｜ 前置章节：[02-docker](../02-docker/README.md) ｜
> 概念参考：[docs/06-kubernetes-basics.md](../docs/06-kubernetes-basics.md)

## 一、本章目标

第一次用 Terraform 管理**真正的 Kubernetes 集群**（Minikube 提供的单节点集群）。
本章会创建一个完整可访问的小应用，并额外创建一组专门用于 Kubernetes Dashboard 学习的资源。
除了 Namespace / ConfigMap / Secret / PVC / Deployment / Service / Ingress 之外，
还会覆盖 Pod / StatefulSet / DaemonSet / Job / CronJob / NodePort / ServiceAccount /
Role / RoleBinding / ClusterRole / ClusterRoleBinding / ResourceQuota / LimitRange /
NetworkPolicy / PodDisruptionBudget / HorizontalPodAutoscaler 等常见对象。

另外，ReplicaSet / EndpointSlice / PersistentVolume / ControllerRevision 等对象会由
Kubernetes Controller 或 Minikube 自动派生出来，因此不需要全部手工写成 Terraform 资源。
这样可以同时学习“Terraform 直接管理的对象”和“Kubernetes 根据控制器关系自动生成的对象”。

## 二、架构图

```mermaid
flowchart TB
    Browser["浏览器 / curl"] --> Ingress["Ingress\n(ingress-nginx addon)"]
    Ingress --> Service["Service (ClusterIP)"]
    Service --> Pod1["Pod #1\n(nginx)"]
    Service --> Pod2["Pod #2\n(nginx)"]

    ConfigMap["ConfigMap\nweb-content"] -.挂载.-> Pod1
    ConfigMap -.挂载.-> Pod2
    Secret["Secret\napp-secret"] -.env 注入.-> Pod1
    Secret -.env 注入.-> Pod2
    PVC["PersistentVolumeClaim\nweb-data"] -.挂载.-> Pod1
    PVC -.挂载.-> Pod2

    subgraph NS["Namespace: terraform-learning"]
        Service
        Pod1
        Pod2
        ConfigMap
        Secret
        PVC
    end
```

## 三、前置知识

完成第 1-2 章；读过 [docs/06-kubernetes-basics.md](../docs/06-kubernetes-basics.md)
了解 Pod / Deployment / Service / Ingress 的基本概念。

**环境要求**：Minikube 已安装。本章不假设集群已启动——请先运行下面的初始化脚本。

## 四、核心概念

概念详解全部在 [docs/06-kubernetes-basics.md](../docs/06-kubernetes-basics.md)，
这里补充"Terraform 特有"的部分：

- **`kubernetes_*` 资源和 `kubectl apply -f xxx.yaml` 的关系**：
  两者最终都是对 Kubernetes API Server 发起同样的 REST 请求，
  区别在于 Terraform 会先计算 diff、维护 State、能感知"这个资源
  是不是被我创建的、现在该不该删除"，而裸 `kubectl apply` 没有
  这一层状态管理（虽然 `kubectl apply` 也有自己的一套
  "last-applied-configuration" 注解机制，但表达能力和 Terraform
  的 plan/state 机制不是一回事）。
- **`wait_until_bound` / Kubernetes Provider 的"等待"语义**：
  见 [main.tf](main.tf) 中 PVC 资源的注释——Terraform 的 apply
  不是"提交请求就算完成"，而是会等到资源达到某种"就绪"状态。

## 五、文件结构

```text
03-minikube/
├── README.md
├── versions.tf              <- kubernetes provider 配置（含 config_context 讲解）
├── variables.tf
├── main.tf                  <- Web 应用主线：Namespace/ConfigMap/Secret/PVC/Deployment/Service/Ingress
├── dashboard-resources.tf   <- Dashboard 学习资源：Pod/StatefulSet/DaemonSet/Job/CronJob/RBAC/HPA 等
├── outputs.tf
├── terraform.tfvars.example
└── scripts/
    ├── start-minikube.ps1   <- 独立于 Terraform 的集群启动脚本
    └── open-dashboard.ps1   <- 打开 Minikube / Kubernetes Web Dashboard
```

## 六、Terraform 代码讲解

见 [main.tf](main.tf) 内联注释。核心设计决策：

- 所有资源的 `metadata.namespace` 都引用
  `kubernetes_namespace.this.metadata[0].name` 而不是直接写
  `var.namespace_name` 字符串——这是为了让 Terraform 建立
  **资源对 Namespace 的隐式依赖**（回顾
  [docs/02-terraform-fundamentals.md](../docs/02-terraform-fundamentals.md) 第 8 节）。
- Secret 通过 `env { value_from { secret_key_ref {...} } }` 注入容器，
  而不是把值直接写进 `env { value = ... }`——这是 Kubernetes 原生的
  "从 Secret 取值"机制。
- Liveness / Readiness Probe 的区别在 [main.tf](main.tf) 里有详细对比注释，
  完整专题见 [05-kubernetes/13-probes-resources](../05-kubernetes/13-probes-resources/README.md)。

## 七、执行步骤

```powershell
# 1. 启动 Minikube 集群 + 启用 ingress addon（独立于 Terraform 的一次性准备工作）
cd 03-minikube
.\scripts\start-minikube.ps1

# 2. 正式进入 Terraform 工作流
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## 八、验证方法

```powershell
kubectl get all -n terraform-learning
kubectl get configmap,secret,pvc -n terraform-learning
kubectl describe pvc web-data -n terraform-learning   # 确认 STATUS 是 Bound

# 方式一：端口转发（最简单、最可靠）

# 1. 查看 Terraform 输出的端口转发命令
terraform output -raw port_forward_command

# 输出类似：
# kubectl port-forward -n terraform-learning svc/web 8080:80

# 2. 在另一个 PowerShell 窗口中实际执行：
kubectl port-forward -n terraform-learning svc/web 8080:80

# 保持这个窗口运行。正常时会看到类似：
# Forwarding from 127.0.0.1:8080 -> 80
# Forwarding from [::1]:8080 -> 80

# 3. 再开一个终端验证：
curl.exe http://localhost:8080

# 注意：terraform output 只负责打印命令，不会自动执行 kubectl port-forward。
# 在 Windows PowerShell 中，curl 通常是 Invoke-WebRequest 的别名，
# 因此这里显式使用 curl.exe，避免和 PowerShell 别名混淆。

# 方式二：通过 Ingress 访问（需要 ingress addon 已启用）
terraform output curl_via_ingress_command
# 复制输出的命令直接运行
# 如果 docker 驱动下直接访问不通，尝试在另一个终端运行 `minikube tunnel`
# 后重试——这是 Windows + docker 驱动下 LoadBalancer/Ingress 网络转发的
# 已知限制，端口转发方式（方式一）不受此影响，请优先使用它验证。
```

## 九、Dashboard 资源覆盖范围

本章现在专门增加了 `dashboard-resources.tf`，用于尽量覆盖 Dashboard 中常见的 Kubernetes 对象。
官方文档说明 Dashboard 会显示“most Kubernetes object kinds”，具体可见菜单会随 Kubernetes /
Dashboard 版本、RBAC 权限和启用的 addon 改变，因此这里采用“覆盖常见内建对象 + 展示自动派生对象”的方式。

| 分类 | 本章可观察资源 | 创建方式 |
|---|---|---|
| Cluster / Admin | Namespace | Terraform |
| Cluster / Admin | Node | Minikube 自动提供 |
| Storage | StorageClass `standard` | Minikube addon |
| Storage | PersistentVolumeClaim | Terraform |
| Storage | PersistentVolume | PVC 动态供给后自动生成 |
| Workloads | Deployment | Terraform |
| Workloads | ReplicaSet | Deployment 自动生成 |
| Workloads | Pod | Deployment / StatefulSet / DaemonSet / Job 自动生成，另有 standalone Pod |
| Workloads | StatefulSet | Terraform |
| Workloads | DaemonSet | Terraform |
| Workloads | Job | Terraform |
| Workloads | CronJob | Terraform |
| Workloads | ControllerRevision | StatefulSet / DaemonSet 自动生成 |
| Services | ClusterIP Service | Terraform |
| Services | NodePort Service | Terraform |
| Services | Headless Service | Terraform |
| Services | Ingress | Terraform |
| Services | EndpointSlice | Service 自动生成 |
| Config | ConfigMap | Terraform |
| Config | Secret | Terraform |
| Access Control | ServiceAccount | Terraform |
| Access Control | Role / RoleBinding | Terraform |
| Access Control | ClusterRole / ClusterRoleBinding | Terraform |
| Policy | ResourceQuota | Terraform |
| Policy | LimitRange | Terraform |
| Policy | NetworkPolicy | Terraform |
| Availability | PodDisruptionBudget | Terraform |
| Autoscaling | HorizontalPodAutoscaler v2 | Terraform；指标需要 metrics-server |
| Events / Logs | Events、Pod Logs | Kubernetes 自动产生 / Dashboard 查看 |

可以用下面的命令一次性确认大部分资源：

```powershell
kubectl get all -n terraform-learning
kubectl get configmap,secret,pvc,resourcequota,limitrange,serviceaccount -n terraform-learning
kubectl get role,rolebinding,networkpolicy,poddisruptionbudget,hpa -n terraform-learning
kubectl get statefulset,daemonset,job,cronjob -n terraform-learning
kubectl get ingress,endpointslice -n terraform-learning
kubectl get clusterrole,clusterrolebinding | Select-String terraform-learning
kubectl get pv,storageclass
```

> 注意：并不是所有 Kubernetes API 资源都适合在这一章手工创建。例如 Node 由 Minikube 提供，
> ReplicaSet/EndpointSlice/ControllerRevision 是控制器派生对象，PersistentVolume 通常由
> StorageClass + PVC 动态供给。强行手工创建这些对象反而会掩盖 Kubernetes Controller 的工作机制。

## 十、Minikube Dashboard（Web UI）

Minikube 内置了 Kubernetes Dashboard。除了使用 `kubectl get ...` 查看资源，
也可以直接在浏览器里用图形界面观察本章创建的 Kubernetes 资源及其状态。

最简单的启动方式：

```powershell
minikube dashboard
```

该命令会启动 Dashboard 的本地代理，并自动打开默认浏览器。
使用 Dashboard 期间请保持这个 PowerShell 窗口运行；结束时按 `Ctrl+C`
即可停止本地代理（不会停止 Minikube 集群）。

本仓库也提供了辅助脚本：

```powershell
.\scripts\open-dashboard.ps1
```

为了让 HPA 和 Dashboard 更完整地显示 CPU / 内存指标，推荐本章直接使用：

```powershell
.\scripts\open-dashboard.ps1 -EnableMetrics
```

打开 Dashboard 后，在界面中把 Namespace 切换为：

```text
terraform-learning
```

然后可以查看本章创建的主要资源：

- **Workloads / Deployments**：查看 `web` Deployment、副本数、滚动更新状态；
- **Pods**：查看两个 nginx Pod 是否为 Running，以及重启次数和事件；
- **Services**：查看 `web` ClusterIP Service、端口与 selector；
- **ConfigMaps**：查看 `web-content`；
- **Secrets**：查看 `app-secret` 的对象状态（敏感值不会直接作为普通明文展示）；
- **PersistentVolumeClaims**：查看 `web-data` 是否为 Bound；
- **Ingresses**：查看 `web` Ingress、Host 和后端 Service；
- **Events**：排查 Pending、CrashLoopBackOff、镜像拉取失败、探针失败等问题。

如果不希望自动打开浏览器，只想取得 Dashboard URL：

```powershell
minikube dashboard --url
```

如果还想在 Dashboard 中辅助观察 CPU / 内存指标，可以启用
`metrics-server` addon：

```powershell
minikube addons enable metrics-server
```

或者直接使用本仓库脚本：

```powershell
.\scripts\open-dashboard.ps1 -EnableMetrics
```

> Dashboard 是观察和排障工具，不会替代 Terraform State。建议同时对照
> `terraform state list`、`kubectl get ...` 和 Dashboard，理解
> Terraform、Kubernetes API 与实际运行资源之间的关系。

## 十一、Kubernetes 学习卡片

下面的内容采用“**标题一行 + 内容一行 + 卡片之间空一行**”的格式，方便直接复制到记忆卡片工具中。

```text
Pod
Kubernetes 中真正运行应用的最小部署单位。一个 Pod 可以包含一个或多个紧密协作的 Container；Pod 被删除或重建后 IP 可能发生变化。

Deployment
用于管理无状态应用，例如 Nginx、Spring Boot、Web API。它负责维护指定数量的 Pod，并支持自动重建、扩缩容、滚动更新和回滚。

ReplicaSet
负责保证指定数量的 Pod 始终存在。通常不直接创建，而是由 Deployment 自动创建和管理。关系是 Deployment → ReplicaSet → Pod。

StatefulSet
用于管理需要稳定身份和持久存储的有状态应用。Pod 名称固定，例如 mysql-0、mysql-1，适合数据库、Kafka、Redis Cluster 等。

DaemonSet
保证每个符合条件的 Node 上运行一个 Pod。常用于日志采集、监控 Agent、网络插件和安全 Agent。

Job
用于执行一次性任务。任务成功完成后 Pod 可以结束，不需要一直运行。适合数据库迁移、批处理、备份和数据转换。

CronJob
按照 Cron 时间规则周期性创建 Job。关系是 CronJob → Job → Pod，例如每晚备份数据库或每 5 分钟执行检查任务。

ReplicationController
早期 Kubernetes 用来维持 Pod 副本数量的资源，现在基本已经被 ReplicaSet 和 Deployment 取代。

Service
为一组 Pod 提供稳定的网络入口。即使 Pod 被重建、IP 改变，客户端仍然可以通过 Service 的固定名称或 ClusterIP 访问应用。

ClusterIP
Service 的默认类型，只能从 Kubernetes 集群内部访问。非常适合微服务之间的内部通信。

NodePort
在 Kubernetes Node 上开放一个固定端口，并把流量转发给 Service 和后端 Pod。访问形式通常是 NodeIP:NodePort。

LoadBalancer
通过外部负载均衡器暴露 Service。云环境中通常对应 AWS ELB、Azure Load Balancer 等；Minikube 中通常需要 minikube tunnel。

Ingress
提供 HTTP/HTTPS 的高级路由规则，可以根据域名或 URL Path 把流量转发给不同 Service。典型链路是 Ingress → Service → Pod。

Ingress Controller
真正执行 Ingress 转发规则的程序。Ingress 本身只是规则，必须有 Nginx、Traefik 等 Ingress Controller 才能真正处理请求。

IngressClass
指定某个 Ingress 应该由哪个 Ingress Controller 处理。例如 ingressClassName: nginx 表示交给 Nginx Ingress Controller。

ConfigMap
保存非敏感配置，例如环境名称、日志级别、URL、Nginx 配置文件等。Pod 可以把 ConfigMap 作为环境变量或文件挂载。

Secret
保存密码、Token、API Key、证书等敏感数据。Pod 可以通过环境变量或 Volume 使用 Secret，但 Kubernetes Secret 默认并不等于强加密存储。

PersistentVolumeClaim
简称 PVC，是应用向 Kubernetes 提出的存储申请，例如“我要 1Gi、ReadWriteOnce 的磁盘”。Pod 通常通过 PVC 使用持久化存储。

PersistentVolume
简称 PV，代表真正提供给 Kubernetes 使用的存储资源。它可以对应本地磁盘、NFS、AWS EBS、Azure Disk 等。

PVC 与 PV
Pod 通常不直接寻找磁盘，而是 Pod → PVC → PV。PVC 表示存储需求，PV 表示真正提供的存储资源。

StorageClass
定义存储的类型和动态创建规则。例如 standard、fast-ssd。PVC 指定 StorageClass 后，Kubernetes 可以自动创建对应 PV。

Dynamic Provisioning
动态存储供给机制。创建 PVC 后，StorageClass 对应的 Provisioner 自动创建 PV，不需要管理员提前手工准备磁盘。

Namespace
Kubernetes 集群中的逻辑资源隔离单位。可以用 dev、test、prod 或不同团队划分资源，例如当前的 terraform-learning。

Node
Kubernetes 集群中的工作机器，可以是物理机、虚拟机或云主机。Pod 最终都会被调度到某个 Node 上运行。

Event
记录 Kubernetes 中发生的重要事件，例如 Pod 调度、镜像拉取、容器启动、PVC 创建、挂载失败等，是排障的重要信息来源。

ServiceAccount
Pod 在 Kubernetes API 中使用的身份。它不是普通人的登录账号，通常用于让应用安全地访问 Kubernetes API。

Role
定义某个 Namespace 内允许执行哪些 Kubernetes API 操作，例如允许 get、list、watch Pods。

RoleBinding
把 Role 中定义的权限授予某个用户、Group 或 ServiceAccount。关系是 ServiceAccount → RoleBinding → Role。

ClusterRole
定义集群级或可跨 Namespace 使用的权限，也可以控制 Node、Namespace、PersistentVolume 等集群级资源。

ClusterRoleBinding
把 ClusterRole 权限授予用户、Group 或 ServiceAccount。它通常具有比普通 RoleBinding 更大的作用范围。

RBAC
Role Based Access Control，基于角色的访问控制。Kubernetes 通过 Role、ClusterRole、RoleBinding、ClusterRoleBinding 控制 API 权限。

NetworkPolicy
控制 Pod 之间允许哪些网络通信，可以理解成 Kubernetes 内部的微分段防火墙，例如只允许 Frontend Pod 访问 Backend Pod。

EndpointSlice
记录一个 Service 当前实际对应哪些 Pod IP 和端口。Service 根据这些 EndpointSlice 把请求发送到健康的后端 Pod。

Deployment 到 Pod
最常见的应用控制链：Deployment → ReplicaSet → Pod → Container。Deployment 管目标状态，ReplicaSet 管副本数，Pod 真正运行 Container。

Ingress 到 Pod
典型 Web 请求链路：客户端 → Ingress Controller → Ingress → Service → EndpointSlice → Pod。

Kubernetes 存储链路
典型持久化存储关系：Pod → PVC → PV；StorageClass 可以根据 PVC 的需求自动创建 PV。

Kubernetes 权限链路
Namespace 内典型权限关系：Pod → ServiceAccount → RoleBinding → Role。

Kubernetes 集群级权限链路
集群级权限关系：ServiceAccount → ClusterRoleBinding → ClusterRole。

Deployment 与 StatefulSet
Deployment 的 Pod 通常可以互相替代，适合无状态应用；StatefulSet 的 Pod 拥有稳定编号、网络身份和存储，更适合有状态应用。

Deployment 与 DaemonSet
Deployment 根据 replicas 决定运行多少个 Pod；DaemonSet 通常按照 Node 数量运行，每个 Node 一个 Pod。

Deployment 与 Job
Deployment 的程序通常需要持续运行；Job 的目标是把某项任务执行完成，完成后退出属于正常状态。

Job 与 CronJob
Job 表示执行一次任务；CronJob 表示按照时间计划不断创建新的 Job。

ConfigMap 与 Secret
ConfigMap 用于普通配置，Secret 用于密码和 Token 等敏感信息。两者都可以通过环境变量或 Volume 提供给 Pod。

Service 与 Ingress
Service 解决“如何稳定找到一组 Pod”；Ingress 解决“HTTP/HTTPS 请求应该根据域名或路径转发到哪个 Service”。

Service 与 Pod
Pod 的 IP 会变化，Service 提供稳定入口，并通过 Label Selector 找到符合条件的 Pod。

PVC Bound
PVC 状态为 Bound 表示 Kubernetes 已经找到或动态创建了满足要求的 PV，存储申请已经成功。

RWO
ReadWriteOnce，表示这个 Volume 可以被一个 Node 以读写方式挂载。它不是简单等同于“只能被一个 Pod 使用”。

Minikube StorageClass
Minikube 默认通常提供 standard StorageClass，并通过本地 Provisioner 动态创建用于实验的 PersistentVolume。

Kubernetes Controller
持续比较“期望状态”和“实际状态”，发现不一致就自动修正。例如 Deployment 要求 2 个 Pod，只剩 1 个时会自动再创建 1 个。

Desired State
期望状态是你告诉 Kubernetes“我想要什么”，例如 replicas=2。Kubernetes Controller 会不断努力让实际状态接近期望状态。

Self-healing
Kubernetes 的自愈能力。例如 Deployment 管理的 Pod 崩溃或被删除后，Controller 会自动创建新的 Pod 恢复期望副本数。
```

## 十二、Terraform State 变化

```bash
terraform state list
terraform state show kubernetes_deployment.web
```

观察 `kubernetes_deployment.web` 的 State 里记录了完整的 Pod 模板 spec——
这也是为什么"仅仅修改镜像 tag"这种小改动，`plan` 也能精确计算出
"只需要更新这一个字段"，而不是把整个资源标记为需要重建。

## 十三、Destroy

```bash
terraform destroy
```

这只会清理 Terraform 管理的 7 类资源，**不会删除 Minikube 集群本身**——
集群的生命周期由 `scripts/start-minikube.ps1` 独立管理（如果你想连集群
一起清理，运行 `minikube delete`，但这会影响其他章节共用的同一个集群，
请谨慎操作）。

## 十四、常见错误

| 现象 | 原因 | 解决方法 |
|---|---|---|
| `Error: Post ".../namespaces": dial tcp ... connection refused` | Minikube 没有启动，或 kubeconfig 端口信息过期 | 运行 `scripts/start-minikube.ps1`，或手动 `minikube status` + `minikube update-context` |
| PVC 一直 `Pending`，`terraform apply` 卡住不动 | `storage-provisioner` addon 未启用，或 StorageClass 名字不对 | `minikube addons list` 确认 `storage-provisioner` 是 enabled；`kubectl get storageclass` 确认存在名为 `standard` 的 StorageClass |
| Ingress 规则创建成功，但 curl 不通 | ingress addon 未启用，或 Windows + docker 驱动下网络转发限制 | 确认 `minikube addons list` 里 `ingress` 已启用；优先用"验证方法"里的端口转发方式排除网络转发因素 |
| `nginx.ingress.kubernetes.io/rewrite-target` 相关报错 | ingress-nginx Controller 还没就绪，Ingress 资源和 IngressClass 不匹配 | `kubectl get pods -n ingress-nginx`，确认 Controller Pod 是 Running |
| kubectl 显示的 context 不是 minikube | 系统里同时存在其他集群 context（比如 Kind） | `kubectl config use-context minikube`，或直接依赖本章 provider 配置里显式指定的 `config_context`（Terraform 自身不受 kubectl 当前 context 影响） |

## 十五、思考题

1. 为什么 Secret 用 `secret_key_ref` 注入，而不是直接在 Deployment 里
   写 `env { value = var.api_key }`？两者在 State 里的敏感性有区别吗？
2. 如果把 `replica_count` 从 2 改成 4，`kubectl get pods` 会发生什么？
   Terraform 的 State 会怎么变化？
3. Readiness Probe 失败和 Liveness Probe 失败，分别会导致什么？
   如果两者都设置成一样的检测逻辑，有什么潜在问题？
4. Ingress 和 Service 都能"路由流量"，为什么不能只用 Service 的
   `NodePort` 类型对外暴露，而要额外引入 Ingress？

## 十六、动手练习

1. 修改 `welcome_message` 变量，重新 `apply`，用端口转发验证页面内容变化。
2. 故意把 `storage_class` 改成一个不存在的名字（比如 `"does-not-exist"`），
   观察 `terraform apply` 卡住/超时的行为，然后改回 `"standard"`。
3. 用 `kubectl exec` 进入某个 Pod，执行
   `echo "hello" >> /var/log/nginx/test.log`，然后删除这个 Pod
   （`kubectl delete pod ...`），观察 Deployment 自动重建新 Pod 后，
   `/var/log/nginx/test.log` 里的内容是否还在——用来验证 PVC 数据的持久性。
4. 把 Deployment 的 `resources.limits.memory` 改小（比如 `"8Mi"`，
   小到不够 nginx 启动），观察 Pod 进入 `OOMKilled` / `CrashLoopBackOff`
   状态，然后改回合理值。

## 十七、进阶挑战

1. 把 `ingress_host` 改造成支持多个域名/路径规则的列表，
   用 `dynamic "rule"` 生成多条 Ingress 规则。
2. 给 Deployment 加上 `lifecycle { create_before_destroy = true }`，
   对比默认行为，观察副本数变化时 Pod 替换顺序的差异。
3. 提前浏览 [05-kubernetes](../05-kubernetes/README.md)，
   尝试自己给本章的 Deployment 增加一个 `startup_probe`
   （启动探针），用来处理"应用启动特别慢"的场景。
