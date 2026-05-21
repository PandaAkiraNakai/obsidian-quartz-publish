# obsidian-quartz-publish

Template para publicar un vault de Obsidian como sitio estatico con [Quartz v4](https://quartz.jzhao.xyz/) servido por nginx dentro de un contenedor Docker. Listo para desplegar en [Coolify](https://coolify.io/) o en cualquier plataforma que entienda `docker-compose`.

Un punto de partida sano: build reproducible, sin dependencias en host, cache de assets ya configurado en nginx y un tema mobile-first incluido.

## Stack

- **Obsidian** como editor del vault (markdown plano).
- **Quartz v4** como generador estatico (search, graph, backlinks, callouts, KaTeX).
- **nginx:alpine** sirviendo `public/` con gzip y cache headers correctos.
- **Docker** multi-stage para builds reproducibles.
- **Coolify** (opcional) para auto-deploy desde GitHub.

## Como usar el template

1. Abrir este repo en GitHub y pulsar el boton **Use this template** -> **Create a new repository**.
2. Clonar el repo nuevo en local:
   ```bash
   git clone https://github.com/<tu-usuario>/<tu-repo>.git
   cd <tu-repo>
   ```
3. Copiar el contenido del vault de Obsidian dentro de `content/` (reemplazando los archivos de ejemplo):
   ```bash
   rm -rf content/*
   cp -r /ruta/a/tu/vault/. content/
   ```
   Quartz toma `content/index.md` como pagina raiz. Asegurarse de que ese archivo exista (puede ser el `Index.md` o `README.md` del vault renombrado).
4. Editar `quartz.config.ts` y `quartz.layout.ts` con los datos propios (ver seccion siguiente).
5. Commit y push:
   ```bash
   git add .
   git commit -m "init: mi vault"
   git push
   ```

## Despliegue

### Local con Docker

```bash
docker compose up --build
```

El sitio queda en **http://localhost:8080**. Para reconstruir tras cambios en el vault:

```bash
docker compose up --build --force-recreate
```

### Coolify

1. En Coolify, crear una nueva aplicacion del tipo **Docker Compose**.
2. Conectar el repositorio de GitHub recien creado.
3. En la configuracion del servicio, definir el dominio publico. Coolify inyectara automaticamente las labels de Traefik y el certificado Let's Encrypt mediante el magic env `SERVICE_FQDN_SITE` que ya esta declarado en `docker-compose.yml`.
4. Pulsar **Deploy**. Cada push a `main` disparara un rebuild automatico (~60-90 s).

### Otras plataformas

Cualquier PaaS que ejecute `docker compose up` deberia funcionar (Dokku, Caprover, un VPS con `docker compose`, Render con plan custom, etc.). Si el proxy externo termina TLS, dejar `absolute_redirect off` en `nginx.conf` (ya esta asi por defecto).

## Configuracion minima

### `quartz.config.ts`

Editar al menos:

```ts
configuration: {
  pageTitle: "My Digital Garden",   // titulo del sitio
  baseUrl: "tu-dominio.tld",        // dominio publico, sin protocolo
  locale: "en-US",                  // o "es-ES", "fr-FR", etc.
}
```

El bloque `theme.colors` controla la paleta. Las variables relevantes son `secondary` (acento principal), `tertiary` (acento secundario), `light`/`dark` (fondos) y `highlight` (subrayados). Documentacion completa: https://quartz.jzhao.xyz/configuration

### `quartz.layout.ts`

Personalizar los enlaces del footer y los componentes que aparecen en los sidebars. Por defecto el layout incluye:

- Izquierda: `PageTitle`, `Search`, `Darkmode`, `ReaderMode`, `Explorer`.
- Derecha: `Graph`, `TableOfContents` (solo desktop), `Backlinks`.

### Tema custom (`quartz/styles/custom.scss`)

El template incluye un tema mobile-first con tipografia refinada, cards en las listas, pills en los tags, sticky search en mobile y dark mode. Para ajustar el color de acento:

```scss
:root {
  --accent: #c97b3b;  // cambiar a gusto
}
```

Para cambiar fuentes, editar `theme.typography` en `quartz.config.ts`.

## Estructura del repo

```
.
├── Dockerfile               # build multi-stage (Quartz v4 -> nginx:alpine)
├── docker-compose.yml       # un servicio "site", listo para Coolify y local
├── nginx.conf               # gzip, cache headers, try_files para wikilinks
├── quartz.config.ts         # configuracion principal de Quartz
├── quartz.layout.ts         # layout de paginas (sidebars, footer)
├── quartz/
│   └── styles/
│       └── custom.scss      # tema custom (sobrescribe el de Quartz)
├── content/                 # tu vault va aqui
│   ├── index.md             # pagina raiz (placeholder)
│   └── example.md           # ejemplo de sintaxis Obsidian (callouts, math, etc.)
├── .dockerignore
├── .gitignore
├── LICENSE
└── README.md
```

## Como funciona el build

`Dockerfile` hace dos cosas:

1. **Build stage** (`node:22-slim`): clona Quartz v4 upstream desde GitHub, instala dependencias con `npm ci`, copia sobre el clon los archivos del template (`quartz.config.ts`, `quartz.layout.ts`, `quartz/styles/`, `content/`) y ejecuta `npx quartz build`. Resultado: `/build/public/`.
2. **Runtime stage** (`nginx:alpine`): copia `/build/public/` a `/usr/share/nginx/html/` y arranca nginx con `nginx.conf`.

Para fijar una version concreta de Quartz, pasar el SHA o tag al build:

```bash
docker build --build-arg QUARTZ_REF=<sha-o-tag> -t mysite .
```

## Tips

- **Imagenes y attachments** del vault funcionan si estan dentro de `content/`. Las rutas relativas tipo `![[image.png]]` y `![](image.png)` se resuelven automaticamente.
- **Notas privadas**: cualquier carpeta listada en `ignorePatterns` (en `quartz.config.ts`) se excluye del build. Por defecto: `private`, `templates`, `.obsidian`, `.trash`, `.git`.
- **Drafts**: para excluir una nota, agregar `draft: true` en el frontmatter.
- **RSS y sitemap** se generan automaticamente en `/index.xml` y `/sitemap.xml`.

## Licencia

MIT. Ver [LICENSE](LICENSE).
