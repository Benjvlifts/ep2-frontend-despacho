# ============================================
# STAGE 1: Build de la aplicación React
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

ARG VITE_API_DESPACHOS_URL=http://localhost:8081
ARG VITE_API_VENTAS_URL=http://localhost:8080
ENV VITE_API_DESPACHOS_URL=$VITE_API_DESPACHOS_URL
ENV VITE_API_VENTAS_URL=$VITE_API_VENTAS_URL

RUN npm run build

# ============================================
# STAGE 2: Servir con Nginx (imagen mínima)
# ============================================
FROM nginx:1.25-alpine

# Configuración principal de nginx (pid file y directorios temporales
# reubicados bajo /tmp/nginx, propiedad de appuser, en vez de /var/run
# y /var/cache/nginx que son rutas de sistema de la imagen base)
COPY nginx-main.conf /etc/nginx/nginx.conf

# Configuración del server block de la aplicación
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist /usr/share/nginx/html

RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser && \
    mkdir -p /tmp/nginx && \
    chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /tmp/nginx && \
    chown appuser:appgroup /etc/nginx/conf.d/default.conf

USER appuser

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]