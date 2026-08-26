FROM node:22-slim

# Install socat for port forwarding + curl for healthcheck wait
RUN apt-get update && apt-get install -y socat curl && rm -rf /var/lib/apt/lists/*

RUN npm i -g openclaw @blockrun/clawrouter

# start.sh: clawrouter binds 127.0.0.1 only, so we forward 0.0.0.0 -> localhost
RUN cat > /usr/local/bin/start.sh << 'EOF'
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
EOF

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080
