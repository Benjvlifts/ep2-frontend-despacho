# 🖥️ Frontend Despachos — Innovatech Chile

Frontend del sistema de gestión de despachos de Innovatech Chile, desarrollado con React + Vite y desplegado en AWS EC2 mediante contenedores Docker.

## 🛠️ Tecnologías
- React 18 + Vite + JavaScript
- Tailwind CSS
- Nginx (servidor de archivos estáticos en producción)
- Docker con multi-stage build
- GitHub Actions (CI/CD)
- Amazon ECR (registro de imágenes)

## 🚀 Ejecutar localmente

### Sin Docker
```bash
npm install
npm run dev
# Abrir http://localhost:5173
```

### Con Docker
```bash
docker compose up --build
# Abrir http://localhost
```

## 🐳 Dockerfile — Multi-stage build

**Stage 1 (builder):** `node:20-alpine` — instala dependencias y compila la app con `npm run build`
**Stage 2 (nginx):** `nginx:1.25-alpine` — sirve los archivos estáticos compilados

El usuario del contenedor es **no root** (appuser, UID 1001) por el principio de mínimo privilegio.

## 🔄 Pipeline CI/CD

Se activa con `push` en la rama `deploy`:
1. Checkout del código
2. Login a Amazon ECR
3. Build de imagen con las URLs del backend como `--build-arg`
4. Push de imagen a ECR (tags: `latest` y hash del commit)
5. SSH a EC2 → pull de imagen → reinicio del contenedor

## 📁 Variables de entorno
| Variable | Descripción | Ejemplo |
|---|---|---|
| `VITE_API_DESPACHOS_URL` | URL del backend Despachos | `http://IP_EC2:8081` |
| `VITE_API_VENTAS_URL` | URL del backend Ventas | `http://IP_EC2:8080` |
