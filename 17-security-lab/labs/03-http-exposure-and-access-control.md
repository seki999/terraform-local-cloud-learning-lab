# Lab 03 - HTTP 暴露、访问控制与修复复测

## 目标

通过一个可控的错误暴露，学习：

- 资源暴露
- HTTP 状态码
- 应用层访问控制
- 修复前后对比
- 证据驱动的复测

## 1. 脆弱状态

启动实验：

```powershell
docker compose up -d --build
```

从 attacker：

```powershell
docker compose exec attacker curl -i http://target/admin.txt
```

预期：

```text
HTTP/1.1 200 OK
...
LOCAL-LAB-SECRET
```

风险并不在于字符串本身，而在于：

> 一个本不应该公开的资源，可以被未授权客户端直接读取。

## 2. 状态码含义

| 状态码 | 常见安全含义 |
|---|---|
| 200 | 请求成功 |
| 301/302 | 重定向 |
| 400 | 请求格式不合法 |
| 401 | 需要身份认证 |
| 403 | 已理解请求，但拒绝访问 |
| 404 | 资源不存在或故意隐藏 |
| 429 | 请求过多 |
| 500 | 服务端异常 |

状态码本身不是完整安全结论。

例如 404 可能是不存在，也可能是系统为了减少信息泄露而统一返回。

## 3. 读取响应头

```powershell
docker compose exec attacker curl -I http://target/admin.txt
```

再用：

```powershell
docker compose exec attacker curl -v http://target/admin.txt
```

观察：

- TCP connect
- request line
- Host header
- response headers
- body

## 4. 查看服务端证据

```powershell
docker compose logs --tail 30 target
```

找到：

```text
GET /admin.txt
200
```

此时攻击者证据与防守者证据应一致。

## 5. 加固

```powershell
docker cp .\target\hardened.conf local-security-target:/etc/nginx/conf.d/default.conf
docker exec local-security-target nginx -t
docker exec local-security-target nginx -s reload
```

先验证首页：

```powershell
curl.exe -i http://127.0.0.1:18080/
```

再复测敏感资源：

```powershell
docker compose exec attacker curl -i http://target/admin.txt
```

预期：

```text
403 Forbidden
```

## 6. 为什么必须先 nginx -t

安全配置修改最怕两类问题：

1. 修复没有生效；
2. 修复把正常业务也破坏了。

所以：

```text
edit
 -> syntax check
 -> reload
 -> positive test
 -> negative test
```

Positive test：

```text
/ 应该继续 200
```

Negative test：

```text
/admin.txt 应该变 403
```

## 7. 访问控制的四个层次

### 网络层

是否能连到服务。

### 传输层

端口是否开放。

### 应用层

路径是否存在。

### 身份与授权层

当前主体是否允许访问。

安全设计要明确你在哪一层解决问题。

## 8. 403 与隐藏资源

有时系统会选择：

```text
403 Forbidden
```

有时选择：

```text
404 Not Found
```

前者明确告诉客户端“资源存在但你不能访问”；后者减少资源存在性的暴露。

本实验用 403 是为了教学直观。

## 9. 最小权限原则

如果某个资源只需要被后台服务读取，那么它就不应该直接挂在 Web root。

更好的真实系统设计可能是：

```text
public/
  index.html

private/
  admin data
```

而不是仅靠路径规则保护一个本就不该公开的文件。

## 10. 回归测试

每次加固至少执行：

```powershell
curl.exe -f http://127.0.0.1:18080/
docker compose exec attacker curl -s -o /dev/null -w "%{http_code}
" http://target/admin.txt
```

预期：

```text
200
403
```

## 11. 练习

1. 将 hardened.conf 的 403 临时改成 404，观察差异。
2. 在日志中比较加固前 200 与加固后 403。
3. 思考如果资源需要管理员访问，单纯 403 是否足够？
4. 设计“未认证 401，认证后 200”的下一阶段方案。

## 12. 完成标准

你应该能解释：

> 安全修复不是“改了一行配置”，而是要有原始证据、修复动作、正常业务验证和原攻击复测。
