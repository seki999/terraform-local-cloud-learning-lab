# Lab 23 - Backup、Recovery 与勒索软件韧性

## 目标

安全不只是阻止入侵，也要保证：

> 即使数据损坏或被删除，系统仍能恢复。

学习：

- backup
- restore
- RPO
- RTO
- immutable backup
- offline copy
- restore test

## 1. RPO

Recovery Point Objective：

> 最多可以接受丢失多少时间的数据？

例如：

```text
RPO = 1 hour
```

表示最多接受最近 1 小时数据损失。

## 2. RTO

Recovery Time Objective：

> 发生故障后多久恢复业务？

例如：

```text
RTO = 4 hours
```

## 3. 备份不等于恢复

存在 backup 文件并不代表能够恢复。

必须定期验证：

```text
backup
 -> restore
 -> integrity check
 -> application verification
```

## 4. 3-2-1 思路

经典原则：

```text
3 copies
2 different media
1 offsite/offline
```

现代环境还应考虑不可变备份。

## 5. Immutable Backup

如果攻击者拿到管理员权限，并能删除备份，那么普通备份可能一起失效。

所以需要考虑：

- immutable storage
- object lock
- separate account
- offline copy

## 6. Credential Separation

生产系统 credential 不应该自动拥有：

```text
delete all backups
```

备份系统应有独立权限边界。

## 7. Terraform State

IaC 场景也要备份：

- remote state
- lock
- versioning
- access policy

State 丢失会影响基础设施管理。

## 8. Kubernetes

需要区分：

```text
cluster config
application data
persistent volume data
secret
```

它们的恢复方法可能不同。

## 9. Restore Drill

建议定期做：

```text
create test data
 -> backup
 -> delete test copy
 -> restore to isolated environment
 -> verify checksum/application
```

## 10. 勒索韧性

防护包括：

- least privilege
- endpoint security
- segmentation
- patching
- detection
- immutable backup
- tested recovery

备份只是最后一道重要防线之一。

## 11. 练习

1. 给一个应用定义 RPO/RTO。
2. 列出要备份的 5 类对象。
3. 设计恢复验证清单。
4. 解释为什么备份账号要独立。
5. 设计一个季度 Restore Drill。

## 12. 完成标准

你应该能说明：

> Backup 的价值由 Restore 能力证明，而不是由“我有一个备份文件”证明。
