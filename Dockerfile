FROM node:22-slim
RUN npm i -g @blockrun/clawrouter
EXPOSE 8080
VOLUME /root/.openclaw/blockrun
CMD sh -c "clawrouter setup --yes && clawrouter --port ${PORT:-8080}"
