FROM alpine:3.18 AS builder
WORKDIR /app/static
COPY index.html .

FROM nginx:1.21-alpine
COPY --from=builder /app/static /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]