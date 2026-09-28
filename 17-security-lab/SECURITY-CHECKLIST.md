# Local Security Lab - Security Checklist

这份清单用于每次完成实验后快速复盘。

## Scope

- [ ] 目标全部属于自己创建的本地实验资源
- [ ] 没有把扫描目标替换成公共 IP/网站
- [ ] Host published port 只绑定必要接口
- [ ] 实验结束后可销毁

## Network

- [ ] 知道 target 的网段
- [ ] 知道默认路由
- [ ] 知道哪些端口开放
- [ ] 不需要的端口已关闭
- [ ] 网络分段符合业务关系
- [ ] default deny 已考虑
- [ ] DNS 流量已考虑

## HTTP/Application

- [ ] 敏感路径未匿名暴露
- [ ] 401/403 行为符合预期
- [ ] 服务端执行授权
- [ ] 管理接口与普通接口边界清晰
- [ ] 错误响应不会泄露过多内部信息

## TLS

- [ ] 敏感通信使用 TLS
- [ ] 不长期关闭证书验证
- [ ] 证书主机名正确
- [ ] 证书在有效期
- [ ] 了解 TLS termination 位置

## Container

- [ ] 非必要不使用 root
- [ ] drop 不需要的 capabilities
- [ ] 考虑 read-only filesystem
- [ ] volume 最小化
- [ ] 不挂 Docker socket
- [ ] secret 不写入 image
- [ ] image version 明确
- [ ] 资源限制合理

## Kubernetes

- [ ] NetworkPolicy 最小连通
- [ ] ServiceAccount 专用
- [ ] RBAC 最小权限
- [ ] 不滥用 cluster-admin
- [ ] 不需要 API 的 Pod 禁止自动挂 token
- [ ] Secret 不提交 Git
- [ ] securityContext 有明确设计

## Terraform / IaC

- [ ] 安全默认值
- [ ] validation 拒绝危险输入
- [ ] plan 检查暴露变化
- [ ] test 包含 allow 和 deny
- [ ] state 不进入 Git
- [ ] sensitive 信息生命周期明确
- [ ] CI 可加入静态安全扫描

## Logging / Detection

- [ ] access log 可用
- [ ] 时间信息可靠
- [ ] 没有记录真实密码/token
- [ ] 有正常 baseline
- [ ] 有异常模式定义
- [ ] 告警考虑误报
- [ ] 事件发生后能重建时间线

## Incident Response

- [ ] 能识别影响资产
- [ ] 能保留证据
- [ ] 能快速 containment
- [ ] 能找到 root cause
- [ ] 能恢复服务
- [ ] 能执行原攻击复测
- [ ] 有 lessons learned
