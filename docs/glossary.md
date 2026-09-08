# 术语词典（Glossary）中英对照

按主题分组，每个术语给出中英文名称与简短解释。

## Terraform / IaC 核心概念

**Infrastructure as Code（基础设施即代码 / IaC）**
把基础设施的期望状态写成可版本控制的代码文件，用工具自动对比现状并执行变更，
取代手工点击控制台的管理方式。

**Provider（提供者）**
Terraform 用来对接某一类具体系统（Docker、Kubernetes、AWS、Vault……）的插件，
负责把 HCL 资源声明翻译成目标系统的实际 API 调用。

**Resource（资源）**
一份 Terraform 配置里声明的、由 Terraform 负责创建和管理生命周期的具体对象
（一个容器、一个网络、一个 S3 桶……）。

**Data Source（数据源）**
只读查询一个已存在、但不由当前配置管理的资源信息。

**State（状态）**
Terraform 用来记录"上次 apply 后各资源真实情况"的账本文件，
是计算 plan diff 的基础。

**Module（模块）**
一组可复用的 Terraform 资源集合，封装在独立目录中，可以被多次调用。

**Backend（后端）**
State 实际存储的位置和访问方式（本地磁盘、S3、Terraform Cloud 等）。

**Workspace（工作区）**
在同一份配置代码下，维护多份相互独立 State 的轻量级机制。

**Dependency Graph（依赖图）**
Terraform 根据资源间的引用关系构建的有向无环图（DAG），决定执行顺序和并发度。

**Idempotency（幂等性）**
同一份配置反复执行，只要现实没有被外部改动，结果应保持一致（多次执行等于执行一次）。

**Desired State（期望状态）**
`.tf` 配置文件里描述的"世界应该是什么样"，与"现实状态"相对。

**Drift（漂移）**
现实世界的资源状态因为被外部手段（非 Terraform）修改，导致与 State/配置不一致的现象。

**Immutable Infrastructure（不可变基础设施）**
不在原地修改运行中的资源，而是创建全新的替代资源、再销毁旧资源的运维哲学，
与 `create_before_destroy` 等 Terraform 生命周期机制密切相关。

## Kubernetes / 容器

**Container（容器）**
共享宿主机操作系统内核、但拥有独立文件系统和进程空间的轻量级隔离运行环境。

**Pod**
Kubernetes 最小调度单位，包含一个或多个共享网络命名空间和存储的容器。

**Service**
为一组动态变化的 Pod 提供稳定访问入口（虚拟 IP + DNS 名）的 Kubernetes 对象。

**Ingress**
把集群外部 HTTP(S) 流量按域名/路径规则路由到不同 Service 的对象。

**Namespace（命名空间）**
Kubernetes 集群内的逻辑隔离边界，用于多租户或多环境划分。

## 本项目专有工具

**LocalStack**
本地运行的 AWS 云模拟器，暴露与真实 AWS 高度兼容的 API，适合零成本学习但不能完全替代真实 AWS。

**Vault**
HashiCorp 出品的 Secret 管理与加密服务，集中管理密码、密钥、证书的存取与轮换。

**Prometheus**
拉取式（pull-based）的时间序列指标采集与存储系统，Kubernetes 生态的事实监控标准。

**Grafana**
把 Prometheus/Loki 等数据源的数据可视化为仪表盘、并支持配置告警的开源平台。
