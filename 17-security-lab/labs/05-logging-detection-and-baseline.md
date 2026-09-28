# Lab 05 - 日志、检测与安全基线

## 目标

从“被攻击者”视角学习：

- 什么日志值得保留
- 怎样建立正常基线
- 怎样识别异常模式
- 怎样设计最简单的检测规则
- 怎样验证检测规则不会产生大量误报

## 1. 查看日志

```powershell
docker compose logs --tail 50 target
```

实时跟踪：

```powershell
docker compose logs -f target
```

从 attacker 请求：

```powershell
docker compose exec attacker curl http://target/
docker compose exec attacker curl http://target/admin.txt
```

## 2. 一条访问日志告诉了你什么

常见字段包括：

- source IP
- timestamp
- method
- URI
- protocol
- status
- response bytes
- referrer
- user-agent

安全分析最基本的问题：

```text
Who
When
From where
Requested what
Result
How often
```

## 3. 正常基线

先定义正常行为：

```text
GET /            -> 200
GET /favicon.ico -> 404 (possible)
GET /admin.txt   -> should not occur for normal users
```

如果没有 baseline，异常检测就没有参照。

## 4. 简单异常模式

在实验里，可以把以下行为当作需要关注：

- 短时间大量 404
- 多次请求敏感路径
- 多次 401/403
- 非常规 method
- 异常 User-Agent
- 单一来源高频访问

不要把“异常”直接等同“攻击”；安全告警是线索，不是判决。

## 5. 生成可控的异常请求

只在本地 attacker：

```powershell
docker compose exec attacker sh -c "for p in /admin.txt /private /debug /backup; do curl -s -o /dev/null -w '%{http_code} %{url_effective}\n' http://target$p; done"
```

然后：

```powershell
docker compose logs --tail 50 target
```

观察模式。

## 6. 检测思路

概念规则：

```text
IF source_ip sends >= N denied/not-found requests
WITHIN T seconds
THEN raise suspicious-enumeration alert
```

实际生产环境还要考虑：

- NAT 后多人共用 IP
- 健康检查
- 搜索引擎
- 自动化客户端
- 合法扫描器
- 重试逻辑

## 7. 日志完整性

日志至少要考虑：

- 时间是否一致
- 容器重启后是否保留
- 谁能删除日志
- 是否集中收集
- 是否有足够字段
- 是否泄露敏感信息

日志也可能成为敏感数据。

例如不要记录：

- Authorization header
- password
- session token
- API secret

## 8. 检测和阻断不是一回事

```text
Detect = 知道发生了什么
Prevent = 阻止发生
Respond = 发生后采取行动
Recover = 恢复和验证
```

成熟安全体系需要四者配合。

## 9. 建立事件时间线

示例：

```text
10:00:00 GET /               200
10:00:05 GET /admin.txt      200
10:01:20 config hardened
10:01:30 GET /admin.txt      403
```

这条时间线已经可以说明：

- 问题存在
- 何时修复
- 修复后行为变化

## 10. 练习

1. 建立 10 条正常请求。
2. 再产生 4 条异常路径请求。
3. 手动区分正常与异常。
4. 写一个简单检测条件。
5. 解释至少 2 种可能误报。

## 11. 完成标准

你应该能说明：

> 安全检测不是“看到 404 就报警”，而是先建立正常行为基线，再根据频率、上下文和结果判断风险。
