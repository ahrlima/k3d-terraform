FROM alpine:3.18 AS builder
LABEL stage=builder

WORKDIR /app/static

COPY index.html .

FROM nginx:1.21-alpine
LABEL stage=production

COPY --from=builder /app/static /usr/share/nginx/html/
USER nginx
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]