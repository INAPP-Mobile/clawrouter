FROM node:22-slim
RUN npm i -g openclaw @blockrun/clawrouter
RUN which openclaw && which clawrouter
ENV PATH="/usr/local/bin:/usr/local/lib/node_modules/.bin:${PATH}"
EXPOSE 8080
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD ["start.sh"]
