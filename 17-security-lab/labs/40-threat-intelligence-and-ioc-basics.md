# Lab 40 - Threat Intelligence 与 IOC 基础

## 目标

理解威胁情报如何帮助调查，同时避免把 IOC 当成绝对真相。

## 1. IOC

Indicator of Compromise 可能包括：

- IP
- domain
- URL
- file hash
- certificate fingerprint

## 2. IOC 的局限

IP 可能：

- shared
- cloud
- CDN
- reassigned

Domain 也可能快速变化。

所以 IOC 只是线索。

## 3. TTP

Tactics, Techniques, Procedures 更关注行为模式。

它通常比单一 IP 更可迁移。

## 4. Context

情报至少要带：

- source
- date
- confidence
- scope
- why relevant

## 5. Freshness

Threat Intel 会过期。

旧 IOC 可能已经不再有价值。

## 6. Internal Intel

企业自己的：

- incident history
- blocked patterns
- common phishing
- asset context

也是重要情报。

## 7. Detection Enrichment

告警：

```text
outbound connection to X
```

结合：

```text
X is known suspicious in current intel
```

可提升优先级。

## 8. Do Not Auto-Block Blindly

情报源误报可能导致业务中断。

自动阻断需要：

- confidence
- business context
- rollback

## 9. MITRE ATT&CK

ATT&CK 可用于描述：

- tactic
- technique

帮助统一语言。

不要把 ATT&CK 当作“攻击教程目录”，本课程用它做防御映射。

## 10. Local Lab Mapping

例如：

```text
Recon
Credential Access
Discovery
Collection
```

可以映射本课程已有控制，但仍以防御验证为目的。

## 11. 完成标准

你应该能区分 IOC 与行为/TTP，并理解情报的时效、置信度和上下文。
