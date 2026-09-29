# Lab 38 - Network IDS 思维与流量基线

## 目标

理解 IDS 的核心不是“自动知道黑客”，而是根据网络证据识别与基线不同的活动。

## 1. NIDS

Network IDS 观察：

- source/destination
- protocol
- port
- flow
- pattern

工具例子：

- Suricata
- Zeek

本章以概念与本地观察为主。

## 2. Flow Baseline

先记录正常：

```text
attacker/test-client -> target:80
target -> no arbitrary egress
```

如果突然出现：

```text
target -> unknown destination
```

就值得调查。

## 3. Packet vs Flow

Packet：

```text
individual network frame/packet
```

Flow：

```text
communication relationship over time
```

IDS 不一定需要保留所有 payload。

## 4. Encrypted Traffic

TLS 后 payload 不可直接读取，但仍可观察：

- endpoints
- timing
- volume
- connection pattern

## 5. Signature

Signature detection 适合已知模式。

局限：

- 新模式
- encoding variation
- encrypted payload

## 6. Anomaly

Anomaly detection 比较 baseline。

局限：

- normal behavior changes
- false positive

## 7. Zeek 思路

Zeek 更偏网络 metadata/event：

- conn
- dns
- http
- tls

适合学习“网络行为日志化”。

## 8. Suricata 思路

Suricata 更偏：

- signature
- protocol parser
- alert

## 9. 本地学习

用 tcpdump 先建立自己的 flow table：

| Src | Dst | Port | Protocol | Expected |
|---|---|---:|---|---|
| attacker | target | 80 | HTTP | yes |

再讨论什么是异常。

## 10. Alert Context

IDS 告警需要补：

- asset criticality
- identity
- recent change
- application log

## 11. Encryption Boundary

如果需要检查应用语义，更适合在：

- reverse proxy
- application
- API gateway

获取日志，而不是试图破解 TLS。

## 12. 完成标准

你应该能解释 signature、anomaly、packet、flow、metadata，以及为什么 IDS 告警必须结合上下文。
