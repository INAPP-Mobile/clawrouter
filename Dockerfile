FROM node:22-slim

# Install socat for port forwarding + curl for healthcheck wait
RUN apt-get update && apt-get install -y socat curl && rm -rf /var/lib/apt/lists/*

RUN npm i -g openclaw @blockrun/clawrouter

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080
CMD ["start.sh"]
