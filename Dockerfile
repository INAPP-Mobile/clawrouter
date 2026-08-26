FROM node:22-slim
RUN npm i -g openclaw @blockrun/clawrouter
EXPOSE 8080
CMD sh -c "clawrouter setup --yes && clawrouter --port ${PORT:-8080}"
