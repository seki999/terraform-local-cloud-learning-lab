# Security Glossary

## Attack Surface

系统中攻击者能够接触的接口、端口、协议、身份入口和功能集合。

## Asset

需要保护的对象，例如数据、凭据、服务、配置、权限。

## Authentication

验证“你是谁”。

## Authorization

判断“你可以做什么”。

## Availability

系统在需要时是否可用。

## Baseline

正常状态的参照，例如正常端口、正常请求频率、正常日志模式。

## CIA Triad

Confidentiality、Integrity、Availability。

## Containment

事件发生后先限制影响扩大的动作。

## Defense in Depth

多层防御。网络、身份、应用、容器、日志等不同控制共同工作。

## Egress

从工作负载向外发出的网络流量。

## Enumeration

枚举可用端口、服务、路径、资源等信息。

## Evidence

可以支持结论的客观信息，例如日志、抓包、命令输出。

## Exposure

本不应该被某主体访问的资源被暴露。

## Firewall

基于规则控制网络流量是否允许通过。

## Hardening

减少不必要功能、权限和暴露面的过程。

## IAM

Identity and Access Management。

## Incident

需要调查和响应的安全事件。

## Ingress

进入工作负载的网络流量。

## Least Privilege

主体只拥有完成任务所需的最小权限。

## Network Segmentation

把网络划分为不同信任区域，并限制区域之间的通信。

## NetworkPolicy

Kubernetes 中控制 Pod ingress/egress 的策略资源。

## Reconnaissance

攻击/评估最初的信息收集阶段。

## RBAC

Role-Based Access Control，基于角色的访问控制。

## Residual Risk

完成修复后仍然剩余的风险。

## Secret

密码、Token、Key 等敏感认证材料。

## ServiceAccount

Kubernetes workload 常用的机器身份。

## Threat

可能对资产造成不良影响的事件或行为。

## Threat Model

对资产、入口、信任边界、威胁和控制进行系统化分析。

## TLS

保护传输机密性、完整性并提供服务身份验证的协议。

## Vulnerability

可被利用的弱点，包括代码缺陷和配置错误。

## Zero Trust

不因为“在内网”就默认可信，而是持续验证身份、权限和上下文。

## 记忆方式

把主要概念串起来：

```text
Asset
 -> Threat
 -> Exposure/Vulnerability
 -> Attack Surface
 -> Evidence
 -> Control
 -> Residual Risk
```
