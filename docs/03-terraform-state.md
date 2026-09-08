# 03 - Terraform State 专题

State 是 Terraform 里最容易被初学者忽视、却是整个工具"能正常工作"的关键机制。
本文讲概念，动手实验见 [12-state-management/README.md](../12-state-management/README.md)。

## 1. State 为什么存在

设想没有 State 会怎样：你写了一个 `resource "docker_container" "web" { name = "web" }"`，
执行 `apply`。半年后你想改一下镜像版本，再次 `apply`。这时 Terraform 必须知道：
"这个叫 `web` 的容器，它现实中的 ID 是什么？它现在的镜像是什么？" 如果每次都要
"猜"或者"用 name 反查"，遇到不支持按名字查询的 API、或者存在同名资源时就会出错。

State 文件就是 Terraform 自己维护的一份"资源身份证登记簿"：resource address ↔
真实资源 ID ↔ 上次已知的完整属性。有了它，Terraform 才能在 `plan` 阶段做精确的
"现实 vs 期望"比较，而不需要每次都靠猜测。

## 2. `terraform.tfstate` 与 `terraform.tfstate.backup`

- `terraform.tfstate`：当前的 State，JSON 格式，**本质上是数据库，不是配置文件**，
  不应该手工编辑。
- `terraform.tfstate.backup`：每次 State 发生变化前，Terraform 自动保存的上一版本备份，
  用于误操作后的手动恢复。

两者都被 [.gitignore](../.gitignore) 排除，原因见该文件注释——最主要的是**State
里可能包含明文敏感信息**，即使对应的 Terraform 变量标记了 `sensitive = true`
（这一点会在 [09-vault](../09-vault/README.md) 章节用一个真实实验验证给你看）。

## 3. State 检查与操作命令

```bash
terraform state list                 # 列出 State 中的所有资源地址
terraform state show <address>       # 显示某个资源的完整属性
terraform state mv <src> <dst>       # 在 State 内部"改名"/"移动"一个资源，
                                      # 不触碰真实资源，只是让 Terraform
                                      # 用新地址去认领同一个真实资源
terraform state rm <address>         # 把某个资源从 State 中移除（但不删除真实资源！
                                      # 之后这个真实资源就变成"Terraform 不知道的孤儿"）
```

## 4. `terraform import`：把手工创建的资源纳管

真实场景：有人手工在控制台创建了一个资源，现在想让 Terraform 接管它，而不是
销毁重建。流程：

```text
1. 手工创建的资源已经存在于现实世界
2. 在 .tf 文件里写一段"看起来应该匹配这个资源"的 resource block
3. terraform import <resource address> <真实资源的 ID>
4. terraform plan  —— 检查 diff 是否为空
   如果 plan 显示还有差异，说明第 2 步写的参数和真实资源不完全一致，
   需要手动修正 .tf 直到 plan 显示"无需变更"
```

动手实验见 [12-state-management/README.md](../12-state-management/README.md) 里
"先手工创建 Docker 容器，再 import" 的完整演练。

## 5. `moved` block：重构时避免销毁重建

当你重命名了一个 resource 的本地名称、或者把一个资源从 root module 移进了
子 module，Terraform 默认的判断是"旧地址的资源没了、新地址多了一个资源"——
于是它会计划**销毁旧的、创建新的**，即使背后对应的是同一个真实资源。

`moved` block 显式告诉 Terraform："这不是两个不同的资源，只是地址变了"：

```hcl
moved {
  from = docker_container.web
  to   = docker_container.frontend
}
```

效果等同于手动执行一次 `terraform state mv docker_container.web docker_container.frontend`，
但好处是**它写在代码里、可以被提交到 Git、可以被团队所有人共享**，而
`state mv` 是一次性的本地命令，不会留下任何"记录"。

## 6. Workspace：轻量级环境隔离

```bash
terraform workspace new dev
terraform workspace new test
terraform workspace select dev
terraform workspace list
```

每个 Workspace 拥有**独立的一份 State**，但**共用同一份 `.tf` 配置代码**。
适合"用完全相同的配置，在多个轻量隔离的环境里各跑一份"的场景（比如同一个人
在本机同时维护 dev / test 两套完全一样的本地实验环境）。

**Workspace 不适合什么场景？** 当不同环境之间配置本身就有较大差异（生产环境
需要更多副本数、不同的资源规格、不同的安全策略）时，更推荐用**不同的目录 +
不同的 tfvars 文件**，而不是 Workspace——因为 Workspace 很容易让人在
`terraform apply` 前忘记检查自己当前在哪个 Workspace，从而在错误的"环境"
上执行了变更（这个错误在 Workspace 名字容易混淆、或者团队协作时尤其危险）。
动手实验见 [01-terraform-basics/README.md](../01-terraform-basics/README.md)
的 Workspace 小节。

## 7. Backend（简介）

本项目所有实验默认使用 **local backend**（State 存在本地磁盘的 `terraform.tfstate`），
这对单机学习足够了。真实团队协作场景下会用远程 Backend（如 AWS S3 + DynamoDB
做 Locking、或 Terraform Cloud），解决"State 集中存储 + 并发写入加锁"的问题。
本项目不深入这部分，但理解了本地 Backend 的行为，再看远程 Backend 文档会容易很多——
它们解决的是同一个问题（State 存哪、怎么防止两人同时 apply 导致 State 损坏），
只是存储介质从本地磁盘换成了远程共享存储。
