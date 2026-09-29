# Lab 22 - 可观测性、Metrics 与安全告警

## 目标

把 08-monitoring 中的 Prometheus / Grafana / Loki 思维和安全检测连接起来。

学习：

- logs
- metrics
- traces
- alert
- threshold
- baseline
- SLI/SLO 与安全事件

## 1. 三类信号

```text
Logs    -> 发生了什么
Metrics -> 发生了多少
Traces  -> 请求经过哪里
```

安全分析常需要组合使用。

## 2. HTTP Metrics

常见指标：

- request_total
- status_code count
- latency
- active connections
- denied request count

安全相关观察：

```text
403 suddenly increases
404 suddenly increases
login failures increase
traffic source changes
```

## 3. Counter

Counter 适合累计事件：

```text
http_requests_total
auth_failures_total
```

通过 rate() 看一段时间的变化速度。

## 4. Gauge

Gauge 表示当前状态：

- active sessions
- queue length
- open connections

## 5. Histogram

Histogram 常用于：

- latency
- request size

异常请求可能带来不同的 size/latency 模式，但不能仅凭指标判定攻击。

## 6. Log + Metric Correlation

例：

```text
Metric:
403 rate increased

Log:
same source repeatedly requests /admin
```

两者结合比单独一个信号更有解释力。

## 7. Alert 设计

不好的告警：

```text
one 404 -> page immediately
```

更合理：

```text
rate of denied requests exceeds baseline
for a sustained window
```

## 8. Severity

告警等级应结合影响：

- Info
- Warning
- High
- Critical

不是所有安全异常都应该叫 Critical。

## 9. Dashboard

安全观察面板可以包含：

- requests by status
- top denied paths
- top sources
- error rate
- authentication failures
- network denies

## 10. Loki

如果仓库已经使用 Loki，可以把 Nginx logs 汇总，再按：

```text
status
path
container
source
```

查询。

## 11. Alert Fatigue

告警太多会让真正重要事件被忽略。

需要：

- tune threshold
- deduplicate
- suppress known noise
- add context

## 12. Runbook

每个高价值告警应带：

```text
What does this mean?
Where to check?
How to validate?
How to contain?
Who owns it?
```

## 13. 练习

1. 设计 403 rate 告警。
2. 设计 404 enumeration 告警。
3. 写出两个 false positive。
4. 设计 dashboard 的 6 个 panel。
5. 为一个告警写 5 步 runbook。

## 14. 完成标准

你应该理解：

> 监控数据只有在有 baseline、上下文和响应流程时，才真正变成安全检测能力。
