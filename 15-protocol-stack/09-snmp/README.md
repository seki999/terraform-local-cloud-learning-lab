# 09 - SNMP / SNMP Trap

SNMP 在网络设备与监控系统里非常常见。

## 基本角色

```text
Manager  <---- GET/GETNEXT ----  Agent
Manager  <------ TRAP ---------  Agent
```

## 默认端口

- UDP 161：查询 Agent
- UDP 162：Trap Receiver

## 核心术语

- MIB
- OID
- Agent
- Manager
- GET
- GETNEXT
- WALK
- TRAP
- INFORM

## OID

OID 是树状命名空间中的对象标识，例如：

```text
1.3.6.1....
```

学习 SNMP 时不要只记字符串，要理解：

```text
MIB 定义对象
OID 定位对象
SNMP PDU 携带操作和数据
```

## 本地实验建议

Ubuntu/WSL2：

```bash
sudo apt install -y snmp snmptrapd
```

监听 UDP 162：

```bash
sudo tcpdump -nn -i any udp port 162
```

然后从另一个 namespace/container 发送 Trap。

## 抓包时观察

- Source IP
- Destination IP
- UDP 162
- SNMP version
- community（v1/v2c）
- OID
- varbind

## SNMPv3

生产系统更应关注 SNMPv3：

- authentication
- privacy/encryption
- username/security level

不要把教学用 v2c community 当成生产安全实践。
