# 09 - Wi-Fi Commands

Windows 上排查 Wi-Fi 很常见。

## 当前无线连接

```powershell
netsh wlan show interfaces
```

重点看：

- SSID
- BSSID
- Band
- Channel
- Radio type
- Receive rate
- Transmit rate
- Signal

## 驱动

```powershell
netsh wlan show drivers
Get-NetAdapter
Get-NetAdapterAdvancedProperty
```

## WLAN 报告

```powershell
netsh wlan show wlanreport
```

系统会生成 WLAN report，可以分析连接/断线历史。

## 常见排障

```text
Wi-Fi link rate 高
但 Internet 慢
```

说明不能只看无线物理链路，还要继续检查：

- ping gateway
- DNS
- WAN
- browser/proxy
- packet loss
- router load

因此 Wi-Fi 命令属于“链路层/接口状态工具”，不是单纯某一个协议命令。
