#!/bin/bash
set -e

EXTERNAL_PORT=${PORT:-8080}
INTERNAL_PORT=8081
export INTERNAL_PORT

# Start clawrouter in background on loopback only
clawrouter --port ${INTERNAL_PORT} &

# Wait for clawrouter health endpoint (direct, loopback Host is accepted)
for i in $(seq 1 30); do
  if curl -sf http://127.0.0.1:${INTERNAL_PORT}/health > /dev/null 2>&1; then
    echo "[start.sh] ClawRouter ready on 127.0.0.1:${INTERNAL_PORT}"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "[start.sh] ClawRouter failed to start" >&2
    exit 1
  fi
  sleep 1
done

# Front it with a Host-rewriting proxy: ClawRouter's local guard rejects
# any non-loopback Host header, so we rewrite Host and strip browser-guard
# headers (Origin / Sec-Fetch-*) before forwarding.
echo "[start.sh] Proxying 0.0.0.0:${EXTERNAL_PORT} -> 127.0.0.1:${INTERNAL_PORT}"
exec node /usr/local/bin/proxy.js