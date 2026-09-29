# Lab 37 - 文件权限与数据保护

## 目标

理解应用数据最终往往落到文件系统，文件权限是最基础也最容易忽视的控制之一。

## 1. Linux Permission

```bash
ls -l
stat FILE
```

理解：

```text
owner
group
other
read
write
execute
```

## 2. 最小权限

敏感文件不应：

```text
world-readable
```

例如私钥通常只应由特定账户读取。

## 3. Directory Permission

目录权限中的 execute 表示：

> 是否允许进入/遍历目录。

它与普通文件 execute 含义不同。

## 4. umask

umask 影响新建文件默认权限。

需要结合应用需求选择，而不是盲目设极端值。

## 5. ACL

传统 owner/group/other 不够时，可使用 ACL 做更细粒度访问控制。

## 6. Windows ACL

Windows 使用 NTFS ACL。

关注：

- inheritance
- owner
- allow
- deny
- group membership

## 7. 临时文件

应用临时文件可能包含敏感内容。

需要考虑：

- directory
- permission
- cleanup
- crash residue

## 8. Logs

日志也可能包含：

- email
- IP
- user ID
- path
- token fragment

日志目录权限必须明确。

## 9. Backup Copy

复制文件做 backup 后，权限可能变化。

安全检查不能只看原文件。

## 10. Container Volume

Volume 把 Host 数据带入容器。

要检查：

- read-only
- path scope
- ownership
- container UID mapping

## 11. Kubernetes Volume

同样需要区分：

- ConfigMap
- Secret
- emptyDir
- PVC
- hostPath

风险完全不同。

## 12. Data Retention

不需要的数据不应永久保存。

流程：

```text
collect
 -> use
 -> retain
 -> archive/delete
```

## 13. 完成标准

你应该能从文件、目录、Volume、Backup、Log 五个维度检查数据访问权限。
