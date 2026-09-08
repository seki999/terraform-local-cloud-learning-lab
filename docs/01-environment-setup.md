# 01 - 环境搭建（Windows 11 + PowerShell）

本文档假设你使用 **Windows 11 + PowerShell**，这是本项目的默认开发环境。

## 1. 总览：需要安装什么

| 软件 | 建议版本 | 用途 |
|---|---|---|
| Terraform | >= 1.7 | 核心 IaC 工具 |
| Docker Desktop | 最新稳定版，启用 WSL2 后端 | 运行容器 / Kind / LocalStack / Vault 等一切服务 |
| Git | 最新稳定版 | 版本控制 |
| VS Code | 最新稳定版 | 编辑器 |
| VS Code 插件：HashiCorp Terraform | - | `.tf` 语法高亮、格式化、跳转定义 |
| kubectl | 与 Kubernetes 版本兼容 | Stage 3 起需要 |
| Minikube | 最新稳定版 | Stage 3 |
| Kind | 最新稳定版 | Stage 4 起需要 |
| Helm | v3.x | Stage 6 |

## 2. 安装步骤

### 2.1 启用 WSL2（Docker Desktop 的依赖）

以管理员身份打开 PowerShell：

```powershell
wsl --install
```

安装完成后重启电脑。这一步是 Docker Desktop 在 Windows 上高性能运行容器的基础——
Docker Desktop 实际上是在 WSL2 里的一个轻量级 Linux 虚拟机中运行 Linux 内核和容器
运行时（containerd），Windows 侧只是客户端 UI 和 CLI 转发。这也是为什么"Docker
桌面版能在 Windows 上运行 Linux 容器"——本质上容器仍然运行在 Linux 内核上，只是
这个 Linux 内核被 WSL2 悄悄管理起来了。

### 2.2 安装 Docker Desktop

从 [docker.com](https://www.docker.com/products/docker-desktop/) 下载安装。安装向导里勾选
"Use WSL 2 instead of Hyper-V"。安装完成后启动 Docker Desktop，等待左下角状态变为
绿色（Docker is running）。

验证：

```powershell
docker version
docker run hello-world
```

### 2.3 安装 Terraform

推荐用 [winget](https://learn.microsoft.com/windows/package-manager/winget/)：

```powershell
winget install HashiCorp.Terraform
```

或手动从 [releases.hashicorp.com/terraform](https://releases.hashicorp.com/terraform/) 下载
zip，解压后把所在目录加入系统 `PATH` 环境变量。

验证：

```powershell
terraform -version
```

### 2.4 安装 kubectl / Minikube / Kind / Helm

```powershell
winget install Kubernetes.kubectl
winget install Kubernetes.minikube
winget install Kubernetes.kind
winget install Helm.Helm
```

验证：

```powershell
kubectl version --client
minikube version
kind version
helm version
```

### 2.5 安装 Git 与 VS Code

```powershell
winget install Git.Git
winget install Microsoft.VisualStudioCode
```

在 VS Code 扩展商店搜索并安装 **HashiCorp Terraform**（发布者 HashiCorp）。

## 3. PowerShell 执行策略

如果运行本项目里的 `.ps1` 辅助脚本时遇到

```text
无法加载文件 xxx.ps1，因为在此系统上禁止运行脚本
```

这是 Windows 默认的执行策略（execution policy）在阻止未签名脚本运行。为当前用户放开限制
（不影响系统级安全设置）：

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

`RemoteSigned` 的含义：本地编写的脚本可以直接运行，但从网络下载的脚本需要数字签名。
这是安全性和易用性之间一个常见的折中，不需要改成 `Unrestricted`。

## 4. 全量环境验证清单

```powershell
terraform -version
docker version
docker run hello-world
git --version
code --version
kubectl version --client
minikube version
kind version
helm version
```

全部无报错，即代表环境准备完毕，可以开始 [01-terraform-basics](../01-terraform-basics/README.md)。

## 5. 常见安装问题

详见 [05-debugging-guide.md](05-debugging-guide.md)，其中专门覆盖：

- Docker daemon unavailable（Docker Desktop 未启动 / WSL2 未就绪）
- PowerShell 执行策略拦截脚本
- Windows 路径分隔符导致的 Terraform 报错
- WSL2 相关的网络/性能问题
