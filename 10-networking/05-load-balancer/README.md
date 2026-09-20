# 05 - Load Balancer

这一节把网络层继续推进到 L4/L7。

## L4 与 L7

- L4：根据 IP + TCP/UDP port 转发，对应典型 NLB 思维。
- L7：理解 HTTP Host、Path、Header 后再路由，对应典型 ALB / Ingress 思维。

推荐在本机用 HAProxy 或 nginx 做实验，而不是依赖任何云厂商。

## 最小 HAProxy 实验

启动两个后端：

```powershell
docker run -d --name web1 hashicorp/http-echo -text="web1"
docker run -d --name web2 hashicorp/http-echo -text="web2"
```

随后自己写 HAProxy 配置，把 `web1`、`web2` 放入同一个 backend pool，连续 curl 并观察响应落在哪台后端。

学习重点不是配置文件语法本身，而是：

1. frontend/listener
2. backend/target pool
3. health check
4. round-robin
5. connection timeout
6. backend failure 后的摘除

## 与 Kubernetes 对照

`Service` 解决集群内服务寻址；`Ingress` / Gateway API 解决 HTTP 层入口路由。把这里的 HAProxy 心智模型再映射到 Kubernetes，会比死记对象字段更容易。
