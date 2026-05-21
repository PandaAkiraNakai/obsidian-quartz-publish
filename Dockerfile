# syntax=docker/dockerfile:1.7

# 1) Build stage: clona Quartz v4 y genera el sitio estático con `content/` como vault
FROM node:22-slim AS builder

ARG QUARTZ_REF=v4
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clonar Quartz v4 upstream; la rama `v4` recibe fixes continuos.
# Para fijar una versión concreta, pasar QUARTZ_REF=<tag-o-sha> en el build.
RUN git clone --depth 1 --branch "${QUARTZ_REF}" https://github.com/jackyzha0/quartz.git .

# Instalar dependencias de Quartz (lockfile de upstream)
RUN npm ci --no-audit --no-fund

# Sobrescribir config con la del template
COPY quartz.config.ts quartz.layout.ts ./

# Sobrescribir estilos custom (si existen). El `|| true` evita fallar si no hay overrides.
COPY quartz/styles/ ./quartz/styles/

# Traer el contenido del vault. Quartz usa `content/` por defecto.
RUN rm -rf content
COPY content/ ./content/

# Construir sitio estático → /build/public
RUN npx quartz build

# 2) Runtime: nginx alpine sirviendo /public
FROM nginx:alpine AS runtime

# Limpiar la welcome-page que trae la imagen base
RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /build/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ > /dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
