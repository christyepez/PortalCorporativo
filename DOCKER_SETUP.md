# Docker Setup - Ejecución desde Docker Hub

## 🚀 Inicio Rápido

### Opción 1: Descargar y ejecutar desde Docker Hub (RECOMENDADO)

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

**Acceso:**
- API Gateway: http://localhost:8080
- SQL Server: localhost:1433
- Redis: localhost:6379
- MinIO Console: http://localhost:9001
- Seq Logs: http://localhost:5341

### Opción 2: Compilar localmente

```bash
docker compose -f docker-compose.build.yml build
docker compose -f docker-compose.prod.yml up -d
```

## 📁 Archivos Docker

### `docker-compose.build.yml`
- Compila imágenes desde código fuente
- Usa volúmenes bind mount para sincronización en tiempo real
- Para **DESARROLLO**

### `docker-compose.prod.yml`
- Descarga imágenes pre-compiladas de Docker Hub
- Sin volúmenes bind mount
- Para **PRODUCCIÓN**

## 🐳 Imágenes en Docker Hub

Todas las imágenes están disponibles en:
- https://hub.docker.com/u/christyepez
- https://hub.docker.com/r/christyepez/portal-corporativo-api-gateway
- Y más...

## ✅ Configuración

### Variables de Entorno

Copia `.env.example` a `.env` y configura:

```bash
cp .env.example .env
```

### Estructura de Carpetas

```
.
├── docker-compose.build.yml    (desarrollo)
├── docker-compose.prod.yml     (producción)
├── docker-compose.yml          (antiguo, no usar)
└── .env
```

## 📋 Comandos Útiles

### Levantar servicios
```bash
docker compose -f docker-compose.prod.yml up -d
```

### Ver logs
```bash
docker compose -f docker-compose.prod.yml logs -f
```

### Parar servicios
```bash
docker compose -f docker-compose.prod.yml down
```

### Limpiar volúmenes
```bash
docker compose -f docker-compose.prod.yml down -v
```

## 🔄 Flujo de Trabajo

### Desarrollo (Laptop 1)
1. Editar código localmente
2. `docker compose -f docker-compose.build.yml build` (compilar)
3. `docker compose -f docker-compose.prod.yml up -d` (ejecutar)
4. Los cambios se sincronizan via volúmenes bind mount

### Producción (Laptop 2, Servidor)
1. `docker compose -f docker-compose.prod.yml pull` (descargar)
2. `docker compose -f docker-compose.prod.yml up -d` (ejecutar)
3. ¡Listo! Sin compilación necesaria

## 📦 Qué se incluye

✅ Todo containerizado en Docker
✅ Imágenes compiladas en Docker Hub
✅ Volúmenes bind mount para desarrollo
✅ Health checks configurados
✅ Sincronización con OneDrive
✅ Listo para producción

## 🆘 Troubleshooting

### Error: "image not found"
- Ejecuta: `docker compose -f docker-compose.prod.yml pull`
- Verifica conexión a internet
- Verifica que Docker Hub esté disponible

### Puerto ya en uso
- Edita `.env` y cambia los puertos
- O detén otros contenedores: `docker ps`

### Ver logs detallados
```bash
docker compose -f docker-compose.prod.yml logs -f --tail=100
```

## 📚 Más información

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com)
- [GitHub Repo](https://github.com/christyepez/PortalCorporativo)
