# ============================================================
# main.tf —— Docker 网络隔离实验：CIDR / Gateway / 跨网络互通
# ============================================================

# --------------------------------------------------------------
# 两个完全独立的 user-defined 网络，各自显式指定 CIDR 网段和网关。
# 不写 ipam_config 时 Docker 会自动分配网段，这里显式写出来，
# 是为了让"子网(Subnet)""网关(Gateway)"这些概念在 `docker network
# inspect` 的输出里直接可见、可对照。
# --------------------------------------------------------------
resource "docker_network" "net_a" {
  name = "learning-net-a"

  ipam_config {
    subnet  = "172.28.1.0/24" # CIDR：这个网络里能分配的 IP 地址范围
    gateway = "172.28.1.1"    # 网关：该网络内容器访问外部网络的出口地址
  }
}

resource "docker_network" "net_b" {
  name = "learning-net-b"

  ipam_config {
    subnet  = "172.28.2.0/24"
    gateway = "172.28.2.1"
  }
}

resource "docker_image" "busybox" {
  name         = "busybox:1.36"
  keep_locally = true
}

# alpha 只连进 net_a
resource "docker_container" "alpha" {
  name    = "net-alpha"
  image   = docker_image.busybox.image_id
  command = ["sh", "-c", "sleep 3600"]

  networks_advanced {
    name = docker_network.net_a.name
  }
}

# beta 只连进 net_b —— 和 alpha 完全没有交集，两者理应无法互通
resource "docker_container" "beta" {
  name    = "net-beta"
  image   = docker_image.busybox.image_id
  command = ["sh", "-c", "sleep 3600"]

  networks_advanced {
    name = docker_network.net_b.name
  }
}

# --------------------------------------------------------------
# gateway 容器同时连进 net_a 和 net_b —— 模拟"跨网络路由/网关"角色。
# 它自己既能连到 alpha，也能连到 beta，但 alpha 和 beta 之间
# 依然无法直接互通（这正是本实验要验证的核心结论：
# Docker 的网络隔离是"网络级别"的，不会因为某个第三方容器
# 同时加入两个网络，就让这两个网络本身互通）。
# --------------------------------------------------------------
resource "docker_container" "gateway" {
  name    = "net-gateway"
  image   = docker_image.busybox.image_id
  command = ["sh", "-c", "sleep 3600"]

  networks_advanced {
    name = docker_network.net_a.name
  }
  networks_advanced {
    name = docker_network.net_b.name
  }
}
