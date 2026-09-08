# 09 - Secret 管理与 Vault 基础

动手实验见 [09-vault/README.md](../09-vault/README.md)。

## 1. 为什么不能把密码直接写进 Terraform 变量

最直接的做法——把数据库密码写在 `variables.tf` 的 `default` 里，或者
写进 `terraform.tfvars`——问题是这些文件很容易被不小心提交到 Git、
被同事无意间看到、或者散落在多份配置副本里，一旦泄露、轮换（rotate）
密码的成本很高（需要改所有引用它的地方）。

Secret 管理系统（如 HashiCorp Vault、AWS Secrets Manager、Azure Key Vault）
的思路是：**密码本身不出现在配置代码里**，配置代码里只写"去哪里取密码"，
真正取值发生在运行时，且访问受权限系统控制、有访问审计记录、支持集中轮换。

## 2. Vault 核心概念

| 概念 | 说明 |
|---|---|
| Secret Engine | Vault 里"存储/生成密钥"的插件化后端，最常用的是 **KV（Key-Value）** 引擎 |
| Mount | 把某个 Secret Engine "挂载"到一个路径下（比如挂载 KV 引擎到 `secret/`） |
| Policy | 用 HCL 编写的权限规则，声明"谁能对哪些路径做读/写/删除" |
| Auth Method | 身份认证方式（本项目本地实验用最简单的 Token 认证） |
| Token | 一次认证后拿到的凭证，后续请求带着它来证明身份，受对应 Policy 约束 |
| Role | 把 Auth Method 和 Policy 绑定起来的"角色"，不同角色能访问不同的 Secret |

## 3. Terraform 如何管理 Vault

本项目使用 Terraform 的 `hashicorp/vault` Provider 来管理 Vault 本身的配置
（挂载哪些引擎、写哪些策略），注意这里 Terraform 管理的是**Vault 的配置**，
不是"业务系统运行时去 Vault 取密码"这件事——那是应用代码（或者 Vault Agent）
的职责，不归 Terraform 管：

```hcl
resource "vault_mount" "kv" {
  path = "secret"
  type = "kv-v2"
}

resource "vault_policy" "app_read_only" {
  name   = "app-read-only"
  policy = <<-EOT
    path "secret/data/app/*" {
      capabilities = ["read"]
    }
  EOT
}
```

## 4. 关键陷阱：`sensitive = true` 并不会让 Secret 消失

Terraform 变量/输出上的 `sensitive = true` 只做一件事：**在 CLI 输出
（plan/apply 的终端打印、`terraform output` 默认展示）中把值显示为
`(sensitive value)`，防止值被"不小心看到"或被截图**。

它**不会**：

- 阻止这个值被写入 `terraform.tfstate`（State 里依然是明文）；
- 阻止你用 `terraform output -json` 或
  `terraform state show` 把明文值重新读出来；
- 提供任何加密。

[09-vault/README.md](../09-vault/README.md) 里有一个专门的实验：故意创建一个
`sensitive = true` 的密码变量，然后用命令直接从 `terraform.tfstate` 里
把明文密码读出来，让你亲眼验证这个结论——这也是为什么本项目的
`.gitignore`（见根目录该文件的注释）会排除所有 `*.tfstate` 文件。

## 5. 真正保护 Secret 的方式

- State 本身加密存储（远程 Backend 通常支持，比如 S3 Backend 配合 SSE 加密）；
- 严格限制谁能读取 State（IAM/访问控制)；
- 密码这类真正敏感的值，理想情况下**根本不通过 Terraform 变量传递**，
  而是让应用运行时直接向 Vault（或 AWS Secrets Manager 等）请求，
  Terraform 只负责创建"这个密码应该存在"的坑位（比如
  `vault_kv_secret_v2` 资源本身，或者干脆只创建访问策略，
  实际密码由人或自动化轮换流程写入，不经过 Terraform apply）。

## 6. 对应真实云环境

| 本地 | 真实云 |
|---|---|
| Vault KV Secret Engine | AWS Secrets Manager / Parameter Store、Azure Key Vault、GCP Secret Manager |
| Vault Policy | AWS IAM Policy、Azure RBAC |
| Vault Token Auth | AWS IAM Role、Azure Managed Identity（生产中更推荐这类"无需手工分发凭证"的机制） |
