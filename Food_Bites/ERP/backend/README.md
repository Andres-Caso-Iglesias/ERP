# ERP Food Bites — Backend (NestJS)

Backend API para el sistema ERP Food Bites. Construido con NestJS, TypeScript y PostgreSQL.

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Estructura del proyecto, patrones de diseño, stack tecnológico |
| [API.md](./API.md) | Referencia completa de todos los endpoints |
| [SECURITY.md](./SECURITY.md) | Medidas de seguridad implementadas |
| [.env.example](./.env.example) | Variables de entorno documentadas |

## Requisitos

- Node.js >= 18
- PostgreSQL >= 14 (must be installed and running)
- npm >= 9

## Setup Rápido

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus datos de PostgreSQL

# 3. Arrancar en desarrollo
npm run start:dev
```

**El servidor configura la base de datos automáticamente:**
- ✅ Verifica que PostgreSQL esté corriendo
- ✅ Crea la base de datos si no existe
- ✅ Ejecuta las migraciones (crea tablas)
- ✅ Carga datos de ejemplo en desarrollo

No necesitás crear la base de datos manualmente — solo necesitás PostgreSQL corriendo.

El servidor arranca en `http://localhost:5000/api`.

## Scripts

| Comando | Descripción |
|---------|-------------|
| `npm run start:dev` | Desarrollo con hot-reload |
| `npm run build` | Compilar para producción |
| `npm run start:prod` | Ejecutar versión compilada |

## Estructura del Proyecto

```
src/
├── main.ts                 # Entry point (bootstrap + PostgreSQL auto-setup)
├── app.module.ts           # Root module
├── database/
│   ├── database-bootstrap.ts   # Auto-detect & init PostgreSQL
│   ├── database.service.ts     # Connection pool (global)
│   └── migrations/
│       ├── 001_initial.sql     # Tablas: users, clients, inventory, sales, accounting, notifications
│       └── 002_seed_data.sql   # Datos de ejemplo (dev)
├── auth/                   # JWT + bcrypt (register/login)
├── sales/                  # CRUD ventas
├── clients/                # CRUD clientes
├── inventory/              # CRUD inventario
├── accounting/             # CRUD contabilidad
└── notifications/          # CRUD notificaciones
```

## Auto-Setup de PostgreSQL

Al arrancar, el servidor ejecuta automáticamente:

```
🔍 Checking PostgreSQL setup...
✅ PostgreSQL is running
✅ Database "erp_food_bites" already exists
🔄 Running migrations...
   ✅ 001_initial.sql
   ✅ 002_seed_data.sql
✅ Migrations completed
🚀 Server running on port 5000
```

Si PostgreSQL no está corriendo, el servidor muestra un error claro y se detiene:

```
❌ PostgreSQL setup failed
   Make sure PostgreSQL is installed and running.
   Connection: postgresql://postgres:postgres@localhost:5432/erp_food_bites
```

## Seguridad

- **Helmet**: Security headers (XSS, clickjacking, MIME sniffing)
- **Rate Limiting**: 100 req/60s global, 5/min register, 10/min login
- **JWT**: Tokens de 1h, bcrypt con 12 salt rounds
- **Validación**: class-validator con whitelist (rechaza propiedades desconocidas)
- **CORS**: Origen configurable via `CORS_ORIGIN`
- **SQL Injection**: Protegido con tagged templates de postgres.js

Ver [SECURITY.md](./SECURITY.md) para detalles completos.

## API Resumen

| Módulo | Endpoints | Auth |
|--------|-----------|------|
| Auth | POST /register, POST /login | No |
| Sales | GET, GET/:id, POST, PUT/:id, DELETE/:id | JWT |
| Clients | GET, GET/:id, POST, PUT/:id, DELETE/:id | JWT |
| Inventory | GET, GET/:id, POST, PUT/:id, DELETE/:id | JWT |
| Accounting | GET, GET/:id, POST, PUT/:id, DELETE/:id | JWT |
| Notifications | GET, GET/:id, POST, PUT/:id/read, DELETE/:id | JWT |

Ver [API.md](./API.md) para documentación completa de cada endpoint.

## Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `PORT` | Puerto del servidor | 5000 |
| `NODE_ENV` | Entorno (development/production) | development |
| `DATABASE_URL` | Connection string de PostgreSQL | `postgresql://postgres:postgres@localhost:5432/erp_food_bites` |
| `JWT_SECRET` | Secreto para firmar tokens JWT | — (required) |
| `CORS_ORIGIN` | Origen permitido para CORS | http://localhost:3000 |

Ver [.env.example](./.env.example) para más detalles.

## Migraciones

Los archivos SQL en `src/database/migrations/` se ejecutan automáticamente al arrancar.

Para agregar una nueva migración:
1. Crear un archivo `.sql` en `src/database/migrations/` con el siguiente número (ej: `003_add_orders.sql`)
2. Reiniciar el servidor
3. La migración se ejecuta automáticamente

**Formato de nombre**: `XXX_descripcion.sql` (ej: `001_initial.sql`, `002_seed_data.sql`)
