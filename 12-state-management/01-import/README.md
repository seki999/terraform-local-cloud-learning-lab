# 12-01 - Import：把手工创建的资源纳入 Terraform 管理

## 本章目标

模拟一个真实场景：有人在 Terraform 之外手工创建了一个还在提供服务的
容器，现在想让 Terraform 接管它，但**不能销毁重建**（可能它正在被
访问）。完整走一遍"编写资源定义 → import → 反复调整配置直到
`plan` 显示无变化"这个真实工作流——包括中间会遇到的、
本项目实测踩过的具体报错。

## 架构图

```mermaid
flowchart LR
    Manual["手工执行 docker run\n(容器已在运行)"] -->|terraform import| State["Terraform State\n（现在认领了这个容器）"]
    State -->|反复 plan/调整配置| Match["main.tf 描述\n和真实状态完全一致"]
    Match -->|apply（如果还有差异）| Final["容器全程未被重建"]
```

## 执行步骤

```powershell
cd 12-state-management/01-import

# 1. 模拟"手工创建"的既存资源
.\scripts\create-manual-container.ps1

terraform init

# 2. 尝试用容器名 import —— 会失败！见下方"常见错误"
terraform import docker_container.manual_nginx manually-created-nginx

# 3. 用真正的容器 ID import（本项目实测：kreuzwerker/docker Provider
#    的 import 只认 ID，不认名字）
$CID = docker inspect manually-created-nginx --format '{{.Id}}'
terraform import docker_container.manual_nginx $CID

# 4. 查看 plan，观察和 main.tf 描述之间的差异
terraform plan
```

## 核心概念：import 不是"一步到位"的

import 只是把"这个资源交给 Terraform 管理"这件事记录进 State，
**不会**自动帮你把 `main.tf` 里的资源定义写得和真实状态完全一致
——这一步需要你自己反复用 `terraform plan` 检查差异、修改配置，
直到 `plan` 显示 `No changes` 为止。这正是本实验想让你亲手体会的：

### 真实踩坑记录一：`ports` block 数量不对导致要求重建

`docker run -p 8099:80 ...` 没有指定绑定哪个宿主机 IP 时，
Docker Desktop 实际会**同时在 IPv4 的 `0.0.0.0` 和 IPv6 的 `::`
上各发布一份端口映射**（用
`docker inspect manually-created-nginx --format '{{json .NetworkSettings.Ports}}'`
能直接看到两条记录）。如果 [main.tf](main.tf) 只写一个不带 `ip`
的 `ports` block，`terraform plan` 会显示要销毁重建整个容器——
必须写两个 `ports` block，分别指定 `ip = "0.0.0.0"` 和 `ip = "::"`。

### 真实踩坑记录二：不显式声明 `env` 也会触发重建

即使 `ports` 已经完全匹配，`plan` 依然可能显示
`env = (known after apply) # forces replacement`。这是因为
`env` 在这个 Provider 的 schema 里是"改动即强制重建"的字段，
import 又没有把它读回一个明确的空值，导致 Terraform 在
"未知需要重新计算"和"强制重建"之间画了等号。解决方法：
显式写 `env = []`，把这个字段的值锁定成一个确定的空列表。

## 验证方法

```powershell
docker inspect manually-created-nginx --format 'ID={{.Id}} Started={{.State.StartedAt}}'
terraform apply     # 如果 plan 只显示"计算默认值"式的 in-place 更新，可以放心 apply
terraform plan       # 应该显示 No changes
docker inspect manually-created-nginx --format 'ID={{.Id}} Started={{.State.StartedAt}}'
# 对比两次的 Started 时间戳——应该完全一样，证明容器全程没有被重建
```

## Destroy

```bash
terraform destroy
```

## 常见错误

| 现象 | 原因 | 解决方法 |
|---|---|---|
| `Cannot import non-existent remote object`（用容器名 import 时） | kreuzwerker/docker Provider 的 import 只接受容器 ID，不接受名字 | 用 `docker inspect <name> --format '{{.Id}}'` 拿到真正的 ID 再 import |
| import 成功后 `plan` 显示要销毁重建 | `main.tf` 里的资源定义和真实容器的实际配置不完全一致（常见于 `ports`/`env` 这类字段） | 参照上面"真实踩坑记录"逐项核对，直到 `plan` 不再显示 `forces replacement` |
| `plan` 一直显示一些"多余"的属性变化，但没有 `forces replacement` | 这些通常是 Provider schema 里的默认值字段，import 没有回填 | 可以放心 `apply`——这只是把默认值写进 State，不影响真实容器 |

## 思考题

1. 为什么 Terraform 不能在 `import` 的同时自动帮你生成一份
   完全匹配的 `main.tf`？（提示：某些 Terraform 版本/第三方工具
   如 `terraform plan -generate-config-out` 尝试解决这个问题，
   但不是所有 Provider、所有字段都能完美生成。）
2. 如果 import 之后一直没有耐心调整配置、直接 `apply` 了一个
   会导致"销毁重建"的 plan，会发生什么？这和"没有 import、
   直接从零 apply"最终效果有什么本质区别（提示：想想会不会有
   短暂的服务中断）？

## 动手练习

尝试给手工创建的容器额外加一个环境变量
（`docker run -e FOO=bar ...`），重新走一遍完整流程，
体会需要在 `main.tf` 里补上 `env = ["FOO=bar"]` 才能让 `plan`
恢复"无变化"。

## 进阶挑战

研究 Terraform 的 `import` block（配置式导入，写在 `.tf` 文件里、
配合 `terraform plan -generate-config-out=generated.tf` 自动生成
初始资源定义的现代替代方案），对比它和本实验用的命令行
`terraform import` 方式的优劣。
