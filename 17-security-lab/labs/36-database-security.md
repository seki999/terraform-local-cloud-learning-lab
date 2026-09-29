# Lab 36 - Database Security：最小权限、网络与审计

## 目标

数据库通常保存最高价值数据，因此需要独立安全边界。

## 1. 网络

典型三层结构：

```text
client -> web -> api -> db
```

原则：

```text
client -X-> db
web    -X-> db (unless designed)
api     -> db
```

数据库不应为了方便调试直接公开。

## 2. Database Identity

应用应使用专用数据库账户。

不要：

```text
application -> DB superuser
```

## 3. 权限

应用可能只需要：

```text
SELECT
INSERT
UPDATE
```

并不一定需要：

```text
DROP
CREATE USER
GRANT
```

## 4. Schema Separation

不同应用或租户可通过：

- database
- schema
- role

降低彼此影响范围。

## 5. Parameterized Query

数据库访问应优先参数绑定，而不是字符串拼接。

安全测试关注：

- 用户输入是否进入 query structure
- ORM 是否正确使用参数
- 动态 SQL 是否有边界

## 6. Encryption in Transit

应用到 DB 也可能需要 TLS，尤其跨主机/跨网络。

## 7. Encryption at Rest

磁盘/数据库加密可以降低离线数据泄露风险，但不能替代运行时访问控制。

## 8. Backup

数据库 backup 同样是敏感资产。

必须保护：

- access
- encryption
- retention
- restore
- deletion rights

## 9. Audit

高价值操作可记录：

- login
- failed login
- privilege change
- schema change
- export
- destructive operation

## 10. Connection Pool

Pool credential 仍需要最小权限。

还要关注：

- connection lifetime
- credential rotation
- stale connection

## 11. Secret Rotation

数据库密码轮换应考虑：

```text
new credential
 -> update app
 -> verify
 -> revoke old
```

## 12. Managed DB

云托管数据库减少部分运维工作，但客户仍负责：

- network
- IAM
- user privilege
- encryption config
- backup policy
- data

## 13. 完成标准

你应该能把数据库保护分成：网络、身份、SQL 权限、加密、备份和审计。
