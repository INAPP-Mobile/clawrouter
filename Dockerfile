# CACHEBUST: 2026-10-06T05:30
FROM node:26-slim

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN npm i -g openclaw @blockrun/clawrouter

COPY start.sh /usr/local/bin/start.sh
COPY proxy.js /usr/local/bin/proxy.js
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080

ENTRYPOINT ["bash", "/usr/local/bin/start.sh"]