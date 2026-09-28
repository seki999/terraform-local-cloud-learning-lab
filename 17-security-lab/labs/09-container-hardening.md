# Lab 09 - 容器安全与运行时加固

## 目标

从“容器能运行”进一步学习“容器应该以什么权限运行”。

重点：

- root / non-root
- Linux capabilities
- read-only filesystem
- writable volume
- image provenance
- resource limits
- secrets
- 容器和宿主机边界

## 1. 查看当前身份

```powershell
docker compose exec target id
docker compose exec attacker id
```

思考：

- 进程以什么 UID/GID 运行？
- 是否真的需要 root？

## 2. root 为什么风险更高

容器不是虚拟机。

容器和宿主机共享内核，因此高权限容器一旦遇到运行时漏洞或错误挂载，影响可能更大。

原则：

```text
If root is not required, do not run as root.
```

## 3. Linux capabilities

root 权限可以拆成能力，例如：

- NET_ADMIN
- NET_RAW
- SYS_ADMIN
- CHOWN
- SETUID

容器加固常见做法：

```yaml
cap_drop:
  - ALL
```

然后只加回真正需要的 capability。

## 4. NET_RAW 与安全工具

攻击/诊断容器为了 tcpdump、ping 等网络操作，可能需要更多能力。

这正好说明：

> 工具容器和业务容器的权限需求不同。

不要因为“调试方便”就让所有业务容器都拥有相同权限。

## 5. read_only

概念配置：

```yaml
read_only: true
```

如果应用必须写临时目录，可单独提供：

```yaml
tmpfs:
  - /tmp
```

形成：

```text
filesystem default read-only
only required paths writable
```

## 6. no-new-privileges

Docker 可使用：

```yaml
security_opt:
  - no-new-privileges:true
```

目的：减少进程通过 setuid 等机制获得新权限的机会。

## 7. 资源限制

安全不仅是“黑客”。

没有限制的资源消耗也可能影响可用性。

需要考虑：

- CPU
- memory
- pids
- file descriptors

本地学习时可以观察：

```powershell
docker stats
```

## 8. image pinning

使用：

```yaml
image: some-image:latest
```

方便，但可重复性较差。

更稳定的方案是固定明确版本，甚至 digest。

安全含义：

- 你知道部署的是什么；
- 更新是显式动作；
- 回滚更容易。

## 9. 镜像最小化

更小的镜像通常意味着：

- 更少的软件包
- 更少的攻击面
- 更少的补丁对象

但“小”本身不是安全保证，还要考虑来源和维护状态。

## 10. 不要把 secret 写进 image

错误方式：

```dockerfile
ENV PASSWORD=real-secret
```

或者：

```text
COPY production.key /app/key
```

这些信息可能进入 image layer。

更好的思路：

- runtime secret injection
- dedicated secret store
- short-lived credential

## 11. bind mount 风险

如果把宿主机敏感路径挂进容器：

```text
host filesystem
 -> container
```

容器可能获得本来不应该拥有的数据访问能力。

特别注意 Docker socket：

```text
/var/run/docker.sock
```

通常相当于给予非常高的 Docker 控制能力。

## 12. 安全配置检查表

业务容器逐项检查：

- [ ] 是否非 root
- [ ] 是否 drop capabilities
- [ ] 是否 read-only
- [ ] 是否只挂必要 volume
- [ ] 是否没有 Docker socket
- [ ] 是否没有真实 secret baked into image
- [ ] 是否固定 image version
- [ ] 是否有 health check
- [ ] 是否有限制资源
- [ ] 是否有日志

## 13. 练习

1. 查看 target 的当前 UID。
2. 列出 target 真正需要的 capability。
3. 思考哪些目录必须可写。
4. 比较 `latest` 和固定版本的可重复性。
5. 解释为什么 attacker 工具容器可以比 target 拥有更多诊断能力，但不应该用于生产业务。

## 14. 完成标准

你应该能说明：

> 容器安全的核心不是“容器天然隔离”，而是最小权限、最小文件系统写权限、最小能力和明确镜像来源。
