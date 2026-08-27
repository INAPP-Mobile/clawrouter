# CACHEBUST: 2026-08-26T09:10
FROM node:25-slim

RUN apt-get update && apt-get install -y socat curl && rm -rf /var/lib/apt/lists/*

RUN npm i -g openclaw @blockrun/clawrouter

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080

ENTRYPOINT ["bash", "/usr/local/bin/start.sh"]
