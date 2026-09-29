# Lab 26 - 本地实验到 AWS / OCI / Azure 的安全映射

## 目标

把本地学习迁移到真实云概念。

注意：这是概念映射，不是 1:1 产品等价。

## 1. Network

本地：

```text
Docker bridge
Linux namespace
route
nftables
```

云：

```text
VPC / VNet
Subnet
Route Table
Security Group / NSG
NACL / Security List
```

## 2. Public Exposure

本地：

```text
127.0.0.1 bind
0.0.0.0 bind
```

云：

```text
private IP
public IP
internet gateway
load balancer
```

核心问题相同：

> 谁能到达这个 endpoint？

## 3. IAM

Kubernetes：

```text
ServiceAccount
Role
RoleBinding
```

云：

```text
IAM user/role
policy
workload identity
instance profile
```

## 4. Secret

本地：

- file
- environment
- Vault

云：

- AWS Secrets Manager
- OCI Vault
- Azure Key Vault

## 5. Logs

本地：

- Docker logs
- Loki
- Prometheus

云：

- CloudWatch
- OCI Logging
- Azure Monitor

## 6. Encryption

本地：

- TLS
- encrypted storage concept

云：

- KMS
- managed certificate
- storage encryption

## 7. Egress

本地：

```text
internal network
route
firewall
```

云：

```text
NAT Gateway
egress firewall
route table
private endpoint
```

## 8. Private Service Access

云上常通过：

- private endpoint
- service endpoint
- private link

减少通过公共互联网访问托管服务。

## 9. Shared Responsibility

云厂商负责部分基础设施安全，但客户仍负责：

- IAM
- data
- network exposure
- workload config
- secret
- application security

## 10. Misconfiguration

云安全事故常见来源不是复杂漏洞，而是：

- overly broad IAM
- public storage
- public DB
- open security group
- leaked key
- disabled logging

这和本地 lab 的核心逻辑高度一致。

## 11. Terraform

Terraform 可以把云安全控制编码：

- private subnet
- no public IP
- restricted CIDR
- encryption enabled
- logging enabled
- least privilege role

## 12. 练习

1. 把 Docker network 映射到 VPC/Subnet。
2. 把 NetworkPolicy 与 Security Group 区分。
3. 把 ServiceAccount/RBAC 映射到 IAM。
4. 为一个三层应用画云安全架构。
5. 写 8 条 Terraform 云安全 guardrail。

## 13. 完成标准

你应该能把本地实验中的“可达性、身份、权限、加密、日志”迁移到任何主流云。
