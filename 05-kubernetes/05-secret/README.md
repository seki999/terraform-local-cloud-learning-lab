# 05-05 - Secret：env / volume 消费 + "base64 不是加密"

## 本章目标

理解 Kubernetes Secret 的消费方式（和 ConfigMap 结构几乎一样），
并**亲手验证两件容易被误解的事**：
1. `kubectl get secret` 默认展示的 base64 编码**不是加密**，任何人
   拿到这段编码都能秒解出明文；
2. Terraform State 里的 Secret 值同样是明文（呼应
   [docs/09-vault-basics.md](../../docs/09-vault-basics.md)）。

## 执行步骤

```bash
cd 05-kubernetes/05-secret
terraform init
terraform apply
```

## 验证方法：base64 不是加密

```bash
kubectl get secret db-credentials -n learning-05-secret -o jsonpath="{.data.password}"
# 会输出一段 base64 编码的字符串，例如 ZGVtby1wYXNzd29yZA==

# 任何人都能直接解码，不需要任何密钥：
kubectl get secret db-credentials -n learning-05-secret -o jsonpath="{.data.password}" | base64 -d
# 输出：demo-password（明文！）
```

**结论**：base64 只是一种编码方式（让二进制/特殊字符安全地放进 JSON/YAML），
**完全不提供任何机密性**。Kubernetes Secret 真正的保护依赖：
etcd 静态加密（Encryption at Rest，需要集群管理员配置，Minikube/Kind
默认不开启）+ RBAC 限制谁能读取 Secret 对象——base64 编码本身不是安全边界。

## 验证方法：Terraform State 里的明文

```bash
Select-String -Path terraform.tfstate -Pattern "db_password" -Context 0,3
# 或者
grep -A3 "db_password" terraform.tfstate
```

你会看到 `var.db_password` 的值以明文形式存在于 State 里
——这和 01-terraform-basics 里验证过的结论完全一致。

## Destroy

```bash
terraform destroy
```

## 思考题

1. 既然 base64 不提供机密性，Kubernetes 为什么还要用它编码 Secret 数据？
   （提示：想想 YAML/JSON 对二进制数据、换行符的表示能力限制）
2. 如果集群开启了 etcd 静态加密，`kubectl get secret -o jsonpath` 这条
   命令的结果会改变吗？为什么（提示：这条命令是通过 API Server
   拿到解密后的数据，而不是直接读 etcd 文件）？

## 动手练习

对比本实验和 [09-vault](../../09-vault/README.md) 里 Vault 管理 Secret
的方式，思考："如果要在真实生产环境里真正保护数据库密码，
Kubernetes 原生 Secret 够用吗？还需要什么？"

## 进阶挑战

给 Namespace 配置一个只读 Secret 权限的 RBAC Role
（结合 [11-rbac](../11-rbac/README.md) 的内容），用一个绑定了受限
ServiceAccount 的 Pod 尝试读取这个 Secret，验证 RBAC 是 Kubernetes
里限制"谁能读到 Secret"的真正机制。
