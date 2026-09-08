# 04 - Terraform Module 专题

动手实验见 [11-modules/README.md](../11-modules/README.md)，本文讲概念。

## 1. 什么是 Module

Module 就是"一个包含 `.tf` 文件的目录"。你写的每一份 Terraform 配置其实都已经是
一个 Module——你直接运行 `terraform init/apply` 的那个目录，叫 **root module（根模块）**。
Module 的价值在于**复用**：把一组经常一起出现的资源（比如"一个 Docker 网络 +
一个连上它的服务"）封装成一个子目录，之后可以在 root module 里多次调用它，
而不用每次都复制粘贴同样的 `resource` 代码。

## 2. Root Module vs Child Module

```text
11-modules/
├── main.tf              <- root module：调用下面的 child module
└── modules/
    ├── docker-network/  <- child module
    ├── docker-service/  <- child module
    ├── kubernetes-app/  <- child module
    └── monitoring/      <- child module
```

Root module 通过 `module` block 调用 child module：

```hcl
module "web" {
  source = "./modules/docker-service"   # 指向 child module 所在目录

  # 下面是传给 child module 的输入参数（对应 child 里的 variable）
  service_name = "web"
  image        = "nginx:latest"
}
```

## 3. Input（输入）

Child module 通过自己目录下的 `variables.tf` 声明它能接收哪些输入：

```hcl
# modules/docker-service/variables.tf
variable "service_name" {
  type        = string
  description = "服务名称，会用作容器名"
}

variable "image" {
  type        = string
  description = "容器镜像"
}
```

Root module 调用时传入的 `service_name = "web"` 就是给这个 variable 赋值。
Child module 内部的资源可以直接用 `var.service_name` 引用。

## 4. Output（输出）

Child module 通过自己目录下的 `outputs.tf` 把内部资源的某些属性"暴露"给
调用它的上层：

```hcl
# modules/docker-service/outputs.tf
output "container_id" {
  value = docker_container.this.id
}
```

Root module 里可以这样引用子模块的输出：

```hcl
output "web_container_id" {
  value = module.web.container_id
}
```

**关键点**：Child module 内部没有在 `outputs.tf` 里显式输出的属性，
root module **完全看不到、也无法引用**——这是一种封装（encapsulation），
和面向对象编程里的"私有字段"是同一个思想。

## 5. Module 组合（Composition）与多次调用

一个 Module 可以被调用任意多次，只要每次调用用不同的本地名称：

```hcl
module "frontend" {
  source       = "./modules/docker-service"
  service_name = "frontend"
  image        = "nginx:latest"
}

module "backend" {
  source       = "./modules/docker-service"
  service_name = "backend"
  image        = "node:20-alpine"
}
```

Terraform 会把它们当成两个完全独立的资源集合来管理，State 里的地址分别是
`module.frontend.docker_container.this` 和 `module.backend.docker_container.this`。

Module 之间也可以互相依赖（Composition）：

```hcl
module "network" {
  source = "./modules/docker-network"
}

module "web" {
  source       = "./modules/docker-service"
  network_name = module.network.network_name   # 引用另一个 module 的 output
}
```

## 6. Module 版本化的思想

本项目里的 module 都是**本地路径引用**（`source = "./modules/xxx"`），没有
版本号的概念——因为它们和调用者在同一个仓库里，天然保持同步。

但在真实团队协作中，Module 经常发布成**独立的、带版本号的制品**，
调用方式类似：

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"   # 只使用 5.x 版本，避免上游发布不兼容的 6.0 时意外升级
}
```

这样做的意义：Module 的开发者可以持续迭代和发布新版本，而使用者的代码
"锁定"在一个兼容的版本区间，不会因为上游改动而在不知情的情况下被破坏——
这和 npm/pip 的依赖版本管理是同一个思想。理解了本地 module 的
input/output/组合方式，再理解"带版本号的远程 module"只是多了一层
"从哪里下载、下载哪个版本"的问题，核心用法不变。
