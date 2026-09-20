#!/usr/bin/env bash
set -euo pipefail

NAMESPACES=(router web app db)
for ns in "${NAMESPACES[@]}"; do
  ip netns del "$ns" 2>/dev/null || true
  ip netns add "$ns"
  ip -n "$ns" link set lo up
done

make_link() {
  local left_ns="$1" left_if="$2" left_ip="$3"
  local right_ns="$4" right_if="$5" right_ip="$6"

  ip link add "$left_if" type veth peer name "$right_if"
  ip link set "$left_if" netns "$left_ns"
  ip link set "$right_if" netns "$right_ns"
  ip -n "$left_ns" addr add "$left_ip" dev "$left_if"
  ip -n "$right_ns" addr add "$right_ip" dev "$right_if"
  ip -n "$left_ns" link set "$left_if" up
  ip -n "$right_ns" link set "$right_if" up
}

make_link router r-web 10.10.10.1/24 web web0 10.10.10.10/24
make_link router r-app 10.10.20.1/24 app app0 10.10.20.10/24
make_link router r-db  10.10.30.1/24 db  db0  10.10.30.10/24

ip -n web route add default via 10.10.10.1
ip -n app route add default via 10.10.20.1
ip -n db  route add default via 10.10.30.1

ip netns exec router sysctl -q -w net.ipv4.ip_forward=1

echo "Local routed datacenter is ready."
ip netns exec router ip -br addr
