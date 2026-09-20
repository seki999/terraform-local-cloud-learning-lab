#!/usr/bin/env bash
set -euo pipefail
for ns in router web app db; do
  ip netns del "$ns" 2>/dev/null || true
done
echo "Local routed datacenter removed."
