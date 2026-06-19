# ERP Food Bites — Documentación del Proyecto

## Visión General

ERP Food Bites es un sistema de planificación de recursos empresariales (ERP) diseñado para negocios de food service. Permite gestionar ventas, clientes, inventario, contabilidad, notificaciones y más.

### Arquitectura

```
┌─────────────────────────────────────────┐
│              Frontend (Flutter)          │
│  Mobile / Desktop / Web                 │
│  MVVM + Provider State Management       │
└──────────────────┬──────────────────────┘
                   │ HTTP/REST
┌──────────────────▼──────────────────────┐
│              Backend (NestJS)            │
│  REST API + JWT Auth + Security         │
│  Controller → Service → Database        │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Database (PostgreSQL)          │
│  Auto-setup + Migrations                │
└─────────────────────────────────────────┘
```

## Stack Tecnológico

### Backend

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| Framework | NestJS | ^10.4.0 |
| Lenguaje | TypeScript | ^5.5.0 |
| Base de datos | PostgreSQL (via postgres.js) | ^3.4.4 |
| Autenticación | JWT (passport-jwt) | ^4.0.1 |
| Hashing de passwords | bcrypt | ^5.1.1 |
| Validación de inputs | class-validator | ^0.14.1 |
| Security headers | Helmet | ^8.0.0 |
| Rate limiting | @nestjs/throttler | ^6.2.0 |

### Frontend

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| Framework | Flutter | ^3.8.1 |
| Lenguaje | Dart | ^3.8.1 |
| State Management | Provider | ^6.1.5 |
| HTTP Client | http | ^1.2.1 |
| Secure Storage | flutter_secure_storage | ^9.0.0 |

## Estructura del Proyecto

```
ERP/
├── backend/                    # NestJS API
│   ├── src/
│   │   ├── main.ts            # Entry point
│   │   ├── app.module.ts      # Root module
│   │   ├── database/          # PostgreSQL connection + migrations
│   │   ├── auth/              # JWT authentication
│   │   ├── sales/             # Sales module
│   │   ├── clients/           # Clients module
│   │   ├── inventory/         # Inventory module
│   │   ├── accounting/        # Accounting module
│   │   └── notifications/     # Notifications module
│   ├── package.json
│   ├── tsconfig.json
│   └── nest-cli.json
├── frontend/                   # Flutter app
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── config/            # Configuration (API URLs)
│   │   ├── screens/           # Main screens (login, dashboard)
│   │   └── modules/           # Feature modules (MVVM)
│   │       ├── auth/          # Authentication
│   │       ├── sales/         # Sales
│   │       ├── clients/       # Clients
│   │       ├── inventory/     # Inventory
│   │       ├── accounting/    # Accounting
│   │       ├── notifications/ # Notifications
│   │       ├── pos/           # Point of Sale
│   │       ├── purchases/     # Purchases
│   │       ├── reports/       # Reports
│   │       └── human_resources/ # HR
│   └── pubspec.yaml
└── PROJECT.md                  # This file
```

## Módulos del Sistema

### 1. Autenticación (`auth`)
- Registro de usuarios con validación de password fuerte
- Login con JWT (token de 1h)
- bcrypt con 12 salt rounds
- Rate limiting: 5 registros/min, 10 logins/min

### 2. Ventas (`sales`)
- CRUD completo de ventas
- Relación con clientes
- Estados: pending, completed, cancelled

### 3. Clientes (`clients`)
- CRUD completo de clientes
- Email, teléfono, estado (active/inactive)

### 4. Inventario (`inventory`)
- CRUD completo de productos
- Categorías, precios, cantidades

### 5. Contabilidad (`accounting`)
- Registro de transacciones (income/expense)
- Categorías y fechas

### 6. Notificaciones (`notifications`)
- Notificaciones por usuario
- Estados: unread, read
- Marcado como leído

### 7. Punto de Venta (`pos`) — Frontend
- Carrito de compras
- Procesamiento de ventas (mock data por ahora)

### 8. Compras (`purchases`) — Frontend
- Gestión de compras (en desarrollo)

### 9. Informes (`reports`) — Frontend
- Reportes y estadísticas (en desarrollo)

### 10. Recursos Humanos (`human_resources`) — Frontend
- Gestión de empleados (mock data por ahora)

## Seguridad

| Medida | Implementación |
|--------|---------------|
| Security headers | Helmet (XSS, clickjacking, MIME sniffing) |
| Rate limiting | 100 req/60s global, 5/min register, 10/min login |
| CORS | Origen configurable via CORS_ORIGIN |
| Validación de inputs | class-validator con whitelist |
| JWT | Tokens de 1h, Bearer token |
| Password hashing | bcrypt con 12 salt rounds |
| SQL Injection | postgres.js tagged templates |
| Type safety | ParseIntPipe, DTOs tipados |

Ver [SECURITY.md](./backend/SECURITY.md) para detalles completos.

## Base de Datos

### Auto-Setup

El backend configura PostgreSQL automáticamente al arrancar:
1. Verifica que PostgreSQL esté corriendo
2. Crea la base de datos si no existe
3. Ejecuta las migraciones SQL

### Tablas

| Tabla | Descripción |
|-------|-------------|
| `users` | Usuarios del sistema (autenticación) |
| `clients` | Clientes del negocio |
| `inventory` | Productos en inventario |
| `sales` | Ventas realizadas |
| `accounting` | Transacciones contables |
| `notifications` | Notificaciones por usuario |

### Migraciones

Archivos SQL en `backend/src/database/migrations/`:
- `001_initial.sql` — Schema inicial (6 tablas + índices)
- `002_seed_data.sql` — Datos de ejemplo para desarrollo

Para agregar una nueva migración:
1. Crear archivo `XXX_descripcion.sql`
2. Reiniciar el servidor

## Setup

### Requisitos

- Node.js >= 18
- PostgreSQL >= 14
- Flutter SDK >= 3.8.1
- npm >= 9

### Backend

```bash
cd backend
npm install
cp .env.example .env
# Editar .env con tus datos de PostgreSQL
npm run start:dev
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

## API

Base URL: `http://localhost:5000/api`

| Módulo | Endpoints | Auth |
|--------|-----------|------|
| Auth | POST /register, POST /login | No |
| Sales | CRUD | JWT |
| Clients | CRUD | JWT |
| Inventory | CRUD | JWT |
| Accounting | CRUD | JWT |
| Notifications | CRUD + markAsRead | JWT |

Ver [API.md](./backend/API.md) para documentación completa.

## Testing

```bash
cd backend
npm run test        # Unit tests
npm run test:cov    # Coverage report
npm run test:e2e    # End-to-end tests
```

## Desarrollo

### Convenciones

- **Backend**: NestJS patterns (Controller → Service → Database)
- **Frontend**: MVVM (View → ViewModel → Model)
- **Commits**: Conventional commits (feat, fix, chore, etc.)
- **Branches**: main (producción), develop (desarrollo)

### Documentación

| Archivo | Contenido |
|---------|-----------|
| [PROJECT.md](./PROJECT.md) | Este archivo — visión general |
| [ARCHITECTURE.md](./backend/ARCHITECTURE.md) | Arquitectura del backend |
| [API.md](./backend/API.md) | Referencia de endpoints |
| [SECURITY.md](./backend/SECURITY.md) | Medidas de seguridad |
