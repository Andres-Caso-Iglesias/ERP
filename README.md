# ERP Food Bites

Sistema ERP para gestion de negocios de food service. Backend en NestJS, frontend en Flutter, base de datos PostgreSQL con auto-configuracion.

## Arquitectura

```
Flutter (Mobile/Desktop/Web)
        |
    HTTP/REST
        |
    NestJS API
        |
    PostgreSQL
```

## Requisitos

- Node.js >= 18
- PostgreSQL >= 14
- Flutter SDK >= 3.8.1

## Instalacion

### Backend

```bash
cd Food_Bites/ERP/backend
npm install
cp .env.example .env
```

Editar `.env` con los datos de conexion a PostgreSQL. El servidor crea la base de datos y las tablas automaticamente al arrancar.

```bash
npm run start:dev
```

El API queda disponible en `http://localhost:5000/api`.

### Frontend

```bash
cd Food_Bites/ERP/frontend
flutter pub get
flutter run
```

## Modulos

| Modulo | Backend | Frontend | Estado |
|--------|---------|----------|--------|
| Auth (JWT) | Si | Si | Completo |
| Ventas | Si | Si | Completo |
| Clientes | Si | Si | Completo |
| Inventario | Si | Si | Completo |
| Contabilidad | Si | Si | Completo |
| Notificaciones | Si | Si | Completo |
| Punto de Venta | No | Si | Mock data |
| Compras | No | Si | En desarrollo |
| Informes | No | Si | En desarrollo |
| Recursos Humanos | No | Si | Mock data |

## API

Metodo | Endpoint | Auth | Descripcion
-------|----------|------|------------
POST | /api/auth/register | No | Registrar usuario
POST | /api/auth/login | No | Iniciar sesion
GET | /api/sales | JWT | Listar ventas
POST | /api/sales | JWT | Crear venta
PUT | /api/sales/:id | JWT | Actualizar venta
DELETE | /api/sales/:id | JWT | Eliminar venta
GET | /api/clients | JWT | Listar clientes
POST | /api/clients | JWT | Crear cliente
PUT | /api/clients/:id | JWT | Actualizar cliente
DELETE | /api/clients/:id | JWT | Eliminar cliente
GET | /api/inventory | JWT | Listar productos
POST | /api/inventory | JWT | Crear producto
PUT | /api/inventory/:id | JWT | Actualizar producto
DELETE | /api/inventory/:id | JWT | Eliminar producto
GET | /api/accounting | JWT | Listar transacciones
POST | /api/accounting | JWT | Crear transaccion
PUT | /api/accounting/:id | JWT | Actualizar transaccion
DELETE | /api/accounting/:id | JWT | Eliminar transaccion
GET | /api/notifications | JWT | Listar notificaciones
POST | /api/notifications | JWT | Crear notificacion
PUT | /api/notifications/:id/read | JWT | Marcar como leida
DELETE | /api/notifications/:id | JWT | Eliminar notificacion

Documentacion completa en [backend/API.md](Food_Bites/ERP/backend/API.md).

## Seguridad

- Helmet: headers de seguridad (XSS, clickjacking, MIME sniffing)
- Rate limiting: 100 req/60s global, 5/min registro, 10/min login
- JWT: tokens de 1h, bcrypt con 12 rondas de salt
- Validacion de inputs: class-validator con whitelist (rechaza propiedades desconocidas)
- CORS: origen configurable via `CORS_ORIGIN`
- SQL injection: protegido con tagged templates de postgres.js

Documentacion completa en [backend/SECURITY.md](Food_Bites/ERP/backend/SECURITY.md).

## Testing

```bash
cd Food_Bites/ERP/backend
npm run test        # Tests unitarios
npm run test:cov    # Reporte de cobertura
```

## Base de Datos

El backend configura PostgreSQL automaticamente:

1. Verifica que PostgreSQL este corriendo
2. Crea la base de datos `erp_food_bites` si no existe
3. Ejecuta las migraciones SQL (`001_initial.sql`, `002_seed_data.sql`)

Para agregar migraciones: crear un archivo `XXX_descripcion.sql` en `backend/src/database/migrations/` y reiniciar el servidor.

## Estructura del Proyecto

```
ERP/
├── Food_Bites/ERP/
│   ├── backend/              NestJS API
│   │   ├── src/
│   │   │   ├── auth/         Autenticacion JWT
│   │   │   ├── sales/        Modulo de ventas
│   │   │   ├── clients/      Modulo de clientes
│   │   │   ├── inventory/    Modulo de inventario
│   │   │   ├── accounting/   Modulo contable
│   │   │   ├── notifications/ Notificaciones
│   │   │   └── database/     Conexion y migraciones
│   │   └── package.json
│   └── frontend/             Aplicacion Flutter
│       ├── lib/
│       │   ├── modules/      Modulos MVVM
│       │   ├── screens/      Pantallas principales
│       │   └── config/       Configuracion
│       └── pubspec.yaml
├── PROJECT.md                Documentacion completa
└── README.md                 Este archivo
```

## Licencia

ISC
