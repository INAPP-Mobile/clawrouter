FROM node:22-slim
RUN npm i -g openclaw @blockrun/clawrouter
ENV PATH="/usr/local/lib/node_modules/.bin:${PATH}"
EXPOSE 8080
CMD sh -c "clawrouter setup --yes && clawrouter --port ${PORT:-8080}"
