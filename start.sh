#!/bin/bash
set -e

EXTERNAL_PORT=${PORT:-8080}
INTERNAL_PORT=8081

# Start clawrouter in background on loopback only
clawrouter --port ${INTERNAL_PORT} &

# Wait for clawrouter health endpoint
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

# Forward all-interfaces external port to loopback internal port
echo "[start.sh] Forwarding 0.0.0.0:${EXTERNAL_PORT} -> 127.0.0.1:${INTERNAL_PORT}"
exec socat TCP-LISTEN:${EXTERNAL_PORT},fork,reuseaddr TCP:127.0.0.1:${INTERNAL_PORT}
