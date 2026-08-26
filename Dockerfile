FROM node:22-slim
RUN npm i -g openclaw @blockrun/clawrouter
EXPOSE 8080
CMD sh -c "clawrouter --port ${PORT:-8080}"
