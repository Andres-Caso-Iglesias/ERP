# Architecture — ERP Food Bites Backend

## Overview

NestJS backend following a modular architecture with clear separation of concerns.

## Project Structure

```
src/
├── main.ts                      # Application entry point
├── app.module.ts                # Root module (imports all feature modules)
├── database/
│   ├── database.module.ts       # Global database module
│   ├── database.service.ts      # PostgreSQL connection pool
│   └── index.ts                 # Barrel exports
├── auth/
│   ├── auth.module.ts           # Authentication module
│   ├── auth.controller.ts       # Auth endpoints (register, login)
│   ├── auth.service.ts          # Auth business logic
│   ├── dto/
│   │   ├── register.dto.ts      # Registration validation
│   │   └── login.dto.ts         # Login validation
│   ├── guards/
│   │   └── jwt-auth.guard.ts    # JWT authentication guard
│   └── strategies/
│       └── jwt.strategy.ts      # Passport JWT strategy
├── sales/
│   ├── sales.module.ts
│   ├── sales.controller.ts
│   ├── sales.service.ts
│   └── dto/
│       ├── create-sale.dto.ts
│       └── update-sale.dto.ts
├── clients/
│   ├── clients.module.ts
│   ├── clients.controller.ts
│   ├── clients.service.ts
│   └── dto/
│       ├── create-client.dto.ts
│       └── update-client.dto.ts
├── inventory/
│   ├── inventory.module.ts
│   ├── inventory.controller.ts
│   ├── inventory.service.ts
│   └── dto/
│       ├── create-product.dto.ts
│       └── update-product.dto.ts
├── accounting/
│   ├── accounting.module.ts
│   ├── accounting.controller.ts
│   ├── accounting.service.ts
│   └── dto/
│       ├── create-entry.dto.ts
│       └── update-entry.dto.ts
└── notifications/
    ├── notifications.module.ts
    ├── notifications.controller.ts
    ├── notifications.service.ts
    └── dto/
        ├── create-notification.dto.ts
        └── update-notification.dto.ts
```

## Design Patterns

### Module Pattern
Each business domain (sales, clients, inventory, etc.) is a self-contained NestJS module with:
- **Controller**: Handles HTTP requests and responses
- **Service**: Contains business logic and database queries
- **DTOs**: Data Transfer Objects for input validation

### Dependency Injection
All dependencies are injected via NestJS's DI container:
- `DatabaseService` is `@Global()` — available everywhere without importing
- `AuthService` is exported from `AuthModule` — available to other modules
- `JwtAuthGuard` is applied per-controller via `@UseGuards()`

### Tagged Template Queries
All database queries use postgres.js tagged template literals:
```typescript
const [user] = await sql`SELECT * FROM users WHERE id = ${id}`;
```
This provides automatic SQL injection protection.

## Data Flow

```
HTTP Request
    │
    ▼
Controller (validates input via DTOs)
    │
    ▼
Service (business logic)
    │
    ▼
DatabaseService (PostgreSQL connection)
    │
    ▼
Response (JSON)
```

## Security Architecture

See SECURITY.md for detailed security measures.

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | NestJS | ^10.4.0 |
| Language | TypeScript | ^5.5.0 |
| Database | PostgreSQL (via postgres.js) | ^3.4.4 |
| Authentication | JWT (passport-jwt) | ^4.0.1 |
| Password Hashing | bcrypt | ^5.1.1 |
| Validation | class-validator | ^0.14.1 |
| Security Headers | Helmet | ^8.0.0 |
| Rate Limiting | @nestjs/throttler | ^6.2.0 |

## Conventions

- All DTOs use `class-validator` decorators for validation
- All services use `DatabaseService.getSql()` for database access
- All controllers use `@UseGuards(JwtAuthGuard)` except auth endpoints
- URL parameters use `ParseIntPipe` for type safety
- Errors are thrown as NestJS HTTP exceptions (NotFoundException, UnauthorizedException, etc.)
- All database tables use snake_case naming
- All TypeScript files include JSDoc file headers
