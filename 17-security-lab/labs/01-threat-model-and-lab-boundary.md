# Lab 01 - 威胁建模与实验边界

## 目标

在真正开始扫描和验证之前，先回答三个问题：

1. 我在保护什么资产？
2. 攻击者从哪里进入？
3. 哪些行为算成功，哪些行为算失败？

本实验只针对本仓库创建的本地容器和本地 Kubernetes 资源。不要把示例中的 target、IP、端口替换成未授权的真实系统。

## 1. 为什么安全实验要先做边界

安全学习很容易变成“工具堆砌”。更工程化的方式是先定义：

```text
Asset
 -> Entry Point
 -> Trust Boundary
 -> Threat
 -> Evidence
 -> Control
 -> Re-test
```

例如本章最小靶场：

```text
Asset:          admin.txt
Entry Point:    HTTP/80
Trust Boundary: attacker <-> target
Threat:         未授权读取
Evidence:       HTTP 200 + access log
Control:        deny / authentication / network isolation
Re-test:        HTTP 403 or authenticated-only
```

## 2. 资产分类

把实验资产按价值分层：

| 资产 | 示例 | 泄露风险 |
|---|---|---|
| 公共内容 | index.html | 低 |
| 内部信息 | admin.txt | 中 |
| 凭据 | token/password | 高 |
| 配置 | nginx.conf / kubeconfig | 高 |
| 运行权限 | root / cluster-admin | 极高 |

思考：如果系统只暴露一个网页，但网页里泄露了管理 URL，这算不算安全问题？答案是：要看它是否扩大后续攻击面。

## 3. 信任边界

在本地实验里至少有四层边界：

```text
Windows Host
  |
Docker Engine
  |
security_lab bridge
  |
target container
  |
application/resource
```

每一层都可能有不同的控制：

- Host firewall
- Docker port publishing
- Docker network
- Container user/capabilities
- Nginx access control
- Application authorization

## 4. STRIDE 简化版

可以用 STRIDE 思路检查每个实验：

| 类别 | 含义 | 本实验例子 |
|---|---|---|
| S | Spoofing | 冒充合法调用方 |
| T | Tampering | 修改配置/请求 |
| R | Repudiation | 日志不足导致无法追溯 |
| I | Information Disclosure | admin.txt 泄露 |
| D | Denial of Service | 过量请求 |
| E | Elevation of Privilege | 取得不应有权限 |

本课程不会把重点放在破坏性 DoS 或真实提权，而是放在可控、可观察、可修复的本地验证。

## 5. 建立实验记录

建议每个 Lab 都保存一份最小实验记录：

```text
Date:
Lab:
Target:
Expected:
Command:
Observed:
Evidence:
Fix:
Re-test:
Conclusion:
```

例如：

```text
Lab:        03
Target:     http://target/admin.txt
Expected:   vulnerable state returns 200
Observed:   200 OK
Evidence:   curl output + nginx access log
Fix:        return 403
Re-test:    403 Forbidden
Conclusion: exposure removed
```

## 6. 成功标准

安全实验的“成功”不是“我运行了命令”，而是：

- 你能解释为什么这个命令有效；
- 你能指出证据在哪；
- 你能提出修复；
- 修复以后重新执行原测试；
- 你能说明风险是否真正降低。

## 7. 练习

1. 列出本章中至少 5 个资产。
2. 对每个资产标记公开/内部/敏感。
3. 画出 Windows -> Docker -> target 的信任边界。
4. 为 admin.txt 写出一条完整 Attack -> Evidence -> Fix -> Re-test 链。
5. 思考为什么“只监听 127.0.0.1”是网络层控制，而“返回 403”是应用层控制。

## 8. 完成标准

你应该能用自己的话说明：

> 威胁建模不是预测所有攻击，而是帮助我们知道“要保护什么、入口在哪里、证据是什么、修复是否有效”。
