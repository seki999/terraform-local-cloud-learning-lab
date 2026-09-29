# Lab 20 - 软件供应链与容器镜像安全

## 目标

理解你的应用不仅由“自己写的代码”组成，还包括：

- base image
- package
- library
- build tool
- CI action
- artifact registry

这些都属于供应链。

## 1. 依赖图

```text
source code
 -> package manager
 -> libraries
 -> compiler/build tool
 -> container base image
 -> registry
 -> deployment
```

任何节点都可能引入风险。

## 2. 固定版本

```text
latest
```

可重复性差。

更好的方式：

```text
explicit version
or digest
```

## 3. SBOM

Software Bill of Materials 用来回答：

> 这个 artifact 里面到底包含哪些组件？

SBOM 可以帮助：

- vulnerability matching
- license review
- incident scope

## 4. 镜像扫描

可以研究：

```text
Trivy
Grype
Docker Scout
```

输出通常包括：

- package
- version
- CVE
- severity
- fixed version

不要只看 severity 数字，还要判断：

- 是否实际可达
- 是否有补丁
- 是否暴露到攻击面

## 5. 基础镜像

选择基础镜像要考虑：

- 官方维护
- 更新频率
- 软件包数量
- 兼容性
- 生命周期

## 6. Build Context

Docker build context 不应包含：

- .git
- secret
- backup
- local credential

用 `.dockerignore` 减少无关文件进入构建上下文。

## 7. CI 依赖

CI workflow 也有供应链风险。

需要：

- pin version
- minimal permissions
- protected secrets
- review third-party actions

## 8. Artifact Integrity

理想流程：

```text
build once
 -> sign
 -> store
 -> verify
 -> deploy same artifact
```

避免在不同环境重复“随手构建”。

## 9. Provenance

Provenance 回答：

- 谁构建的？
- 在什么 CI 构建？
- 使用什么 source commit？
- 使用什么依赖？

## 10. Vulnerability Management

扫描不是终点。

流程：

```text
discover
 -> assess exposure
 -> prioritize
 -> patch/mitigate
 -> re-scan
 -> document exception
```

## 11. 练习

1. 为 target 镜像列出 base image。
2. 设计固定版本策略。
3. 写一个 .dockerignore 清单。
4. 解释 SBOM 与 vulnerability scan 的差异。
5. 设计 CI 中 image scan gate。

## 12. 完成标准

你应该理解：

> 软件供应链安全关注的不只是代码，而是从依赖、构建、镜像到部署的完整来源链。
