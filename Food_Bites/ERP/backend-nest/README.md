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
- PostgreSQL >= 14
- npm >= 9

## Setup Rápido

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus datos de PostgreSQL

# 3. Crear la base de datos
psql -U postgres -c "CREATE DATABASE erp_food_bites"

# 4. Arrancar en desarrollo
npm run start:dev
```

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
├── main.ts                 # Entry point (helmet, CORS, validation)
├── app.module.ts           # Root module
├── database/               # Conexión PostgreSQL (global)
├── auth/                   # JWT + bcrypt (register/login)
├── sales/                  # CRUD ventas
├── clients/                # CRUD clientes
├── inventory/              # CRUD inventario
├── accounting/             # CRUD contabilidad
└── notifications/          # CRUD notificaciones
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
| `DATABASE_URL` | Connection string de PostgreSQL | — |
| `JWT_SECRET` | Secreto para firmar tokens JWT | — |
| `CORS_ORIGIN` | Origen permitido para CORS | http://localhost:3000 |

Ver [.env.example](./.env.example) para más detalles.
