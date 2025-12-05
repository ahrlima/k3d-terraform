FROM node:18-alpine AS builder

RUN addgroup -g 1000 appgroup \
    && adduser -u 1000 -G appgroup -s /bin/sh -D appuser

WORKDIR /app

RUN chown appuser:appgroup /app
USER appuser

COPY package*.json ./

RUN npm install

COPY . .

FROM node:18-alpine AS production

RUN addgroup -g 1000 appgroup \
    && adduser -u 1000 -G appgroup -s /bin/sh -D appuser

WORKDIR /usr/src/app
RUN chown appuser:appgroup /usr/src/app

USER appuser

COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/app.js .

EXPOSE 3000

CMD [ "node", "app.js" ]