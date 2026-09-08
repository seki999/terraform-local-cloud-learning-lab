# Terraform 命令速查表

## 核心工作流

```bash
terraform init                 # 初始化：下载 Provider 插件、初始化 Backend、锁定版本
terraform init -upgrade        # 允许升级 Provider/Module 到符合约束的最新版本
terraform fmt                  # 按官方风格格式化当前目录下所有 .tf 文件
terraform fmt -recursive       # 递归格式化所有子目录
terraform validate             # 语法与内部一致性校验（不连接任何 Provider，不需要凭证）
terraform plan                 # 计算 期望状态 vs 现实状态 的差异，不做任何改动
terraform plan -out=plan.tfplan  # 把计划保存成文件，供后续精确 apply（避免 plan 和 apply 之间现实又变了）
terraform apply                # 执行变更（默认会先跑一次 plan 并要求手动输入 yes）
terraform apply plan.tfplan     # 精确执行之前保存的计划
terraform apply -auto-approve   # 跳过确认提示（脚本化/CI 场景使用，学习时不建议养成习惯）
terraform destroy              # 销毁本配置管理的所有资源
terraform destroy -target=<address>  # 只销毁指定的某个资源（谨慎使用）
```

## 查看结果

```bash
terraform show                 # 以人类可读格式展示当前 State
terraform show plan.tfplan      # 以人类可读格式展示保存的 plan 文件
terraform output                # 显示 root module 的所有 output
terraform output <name>         # 显示某一个 output 的值
terraform output -json          # 以 JSON 格式输出（脚本消费用）
terraform console               # 进入交互式表达式求值控制台，用于调试 HCL 表达式
terraform graph                 # 输出依赖图（DOT 格式，需要 Graphviz 渲染成图片）
terraform providers             # 显示当前配置用到的所有 Provider 及版本
```

## State 操作

```bash
terraform state list                    # 列出 State 中所有资源地址
terraform state show <address>          # 显示某个资源的完整属性
terraform state mv <src> <dst>          # 在 State 内部移动/改名资源（不影响真实资源）
terraform state rm <address>            # 把资源从 State 移除（不删除真实资源，慎用）
terraform import <address> <real_id>    # 把已存在的真实资源导入 State
terraform force-unlock <LOCK_ID>        # 强制释放 State 锁（确认无其他进程在写时才用）
```

## Workspace

```bash
terraform workspace list                # 列出所有 Workspace
terraform workspace new <name>          # 创建新 Workspace
terraform workspace select <name>       # 切换到某个 Workspace
terraform workspace show                # 显示当前所在 Workspace
terraform workspace delete <name>       # 删除某个 Workspace（其 State 必须为空）
```

## 变量相关

```bash
terraform plan -var="key=value"              # 命令行传入单个变量
terraform plan -var-file="prod.tfvars"        # 指定变量文件
TF_VAR_key=value terraform plan               # 用环境变量传入变量（PowerShell: $env:TF_VAR_key="value"）
```

## 测试（13-testing 章节会用到）

```bash
terraform test                   # 运行 .tftest.hcl 测试文件（需要较新版本 Terraform）
```
