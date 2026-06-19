# Security Measures — ERP Food Bites Backend

## Overview

This backend implements defense-in-depth security measures to protect against common web vulnerabilities.

## Security Layers

### 1. Security Headers (Helmet)

**What**: Sets HTTP security headers to protect against XSS, clickjacking, MIME sniffing, etc.

**Implementation** (`main.ts`):
```typescript
import helmet from 'helmet';
app.use(helmet());
```

**Headers set by Helmet**:
- `X-Content-Type-Options: nosniff` — Prevents MIME type sniffing
- `X-Frame-Options: DENY` — Prevents clickjacking
- `X-XSS-Protection: 1; mode=block` — Enables XSS filter
- `Strict-Transport-Security` — Enforces HTTPS (production)
- `Content-Security-Policy` — Restricts resource loading
- `X-DNS-Prefetch-Control: off` — Prevents DNS prefetching
- `Referrer-Policy: no-referrer` — Controls referrer information

---

### 2. Rate Limiting (Throttler)

**What**: Limits the number of requests per time window to prevent brute force and DDoS attacks.

**Implementation** (`app.module.ts`):
```typescript
ThrottlerModule.forRoot([{
  ttl: 60000,    // 60 seconds window
  limit: 100,    // 100 requests per window per IP
}])
```

**Per-endpoint limits**:
| Endpoint | Limit | Reason |
|----------|-------|--------|
| Global | 100/min | General protection |
| POST /auth/register | 5/min | Prevent mass registration |
| POST /auth/login | 10/min | Prevent brute force |

---

### 3. CORS Configuration

**What**: Restricts which origins can make cross-origin requests.

**Implementation** (`main.ts`):
```typescript
app.enableCors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  credentials: true,
});
```

**Configuration**:
- `CORS_ORIGIN` env variable controls allowed origin
- Only specified HTTP methods are allowed
- Credentials (cookies, headers) are supported

---

### 4. Input Validation & Sanitization

**What**: Validates and sanitizes ALL incoming data to prevent injection attacks.

**Implementation** (`main.ts`):
```typescript
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,            // Strips unknown properties
    forbidNonWhitelisted: true, // Throws error for unknown properties
    transform: true,            // Auto-transforms to DTO instances
    transformOptions: {
      enableImplicitConversion: true,
    },
  }),
);
```

**DTO Validation Examples**:
```typescript
// Registration - strong password policy
@Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])/, {
  message: 'password must contain uppercase, lowercase, number and special char',
})
password: string;

// Username - restricted character set
@Matches(/^[a-zA-Z0-9_]+$/, {
  message: 'username must contain only letters, numbers and underscores',
})
username: string;
```

**Protection against**:
- SQL Injection (via postgres.js tagged templates + input validation)
- XSS (via input sanitization)
- Mass assignment (via whitelist)
- Invalid data types (via transform + validation)

---

### 5. Authentication (JWT)

**What**: Stateless token-based authentication.

**Implementation**:
- Access token with 1-hour expiry
- Bearer token in Authorization header
- Password hashed with bcrypt (12 salt rounds)

**Token payload**:
```json
{
  "sub": 1,           // User ID
  "username": "john",
  "iat": 1234567890,  // Issued at
  "exp": 1234571490   // Expires (1h)
}
```

**Password hashing**:
```typescript
const SALT_ROUNDS = 12;
const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
```

---

### 6. Password Policy

**What**: Enforces strong passwords during registration.

**Rules**:
- Minimum 8 characters
- Maximum 128 characters
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one digit (0-9)
- At least one special character (@$!%*?&#)

**Implementation** (`register.dto.ts`):
```typescript
@Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])/, {
  message: 'password must contain at least one lowercase, one uppercase, one number and one special character',
})
password: string;
```

---

### 7. SQL Injection Protection

**What**: Prevents SQL injection attacks.

**Implementation**: postgres.js tagged template literals:
```typescript
// SAFE - parameterized query
const [user] = await sql`SELECT * FROM users WHERE username = ${username}`;

// INSECURE - string concatenation (NEVER do this)
// const [user] = await sql`SELECT * FROM users WHERE username = ${username}`;
```

Tagged templates automatically escape all interpolated values.

---

### 8. Error Handling

**What**: Centralized error handling that doesn't leak sensitive information.

**Implementation**: NestJS HTTP exceptions:
```typescript
// Never expose internal errors to client
throw new NotFoundException(`Sale with ID ${id} not found`);

// Generic server error for unexpected failures
res.status(500).json({ msg: 'Error del servidor' });
```

**Information exposed**:
- HTTP status code
- Human-readable error message
- Error type (for debugging)

**Information NOT exposed**:
- Stack traces
- Database queries
- Internal file paths
- Connection details

---

### 9. Route Protection

**What**: All business endpoints require authentication.

**Implementation** (`sales.controller.ts`):
```typescript
@Controller('sales')
@UseGuards(JwtAuthGuard)  // ALL routes in this controller require JWT
export class SalesController { ... }
```

**Unprotected routes** (public):
- POST /api/auth/register
- POST /api/auth/login

**Protected routes** (JWT required):
- All /api/sales/* endpoints
- All /api/clients/* endpoints
- All /api/inventory/* endpoints
- All /api/accounting/* endpoints
- All /api/notifications/* endpoints

---

### 10. Type Safety

**What**: Prevents type-related vulnerabilities.

**Implementation**:
```typescript
// ParseIntPipe ensures URL params are integers
@Param('id', ParseIntPipe) id: number

// class-validator ensures body types
@IsNumber() total: number;
@IsDateString() saleDate: string;
@IsString() @MinLength(1) name: string;
```

---

## Security Checklist

- [x] Security headers (Helmet)
- [x] Rate limiting (Throttler)
- [x] CORS restriction
- [x] Input validation (class-validator)
- [x] Input sanitization (whitelist)
- [x] JWT authentication
- [x] Strong password policy
- [x] bcrypt password hashing (12 rounds)
- [x] SQL injection protection (tagged templates)
- [x] No sensitive data in responses
- [x] Type-safe URL parameters
- [x] Error messages don't leak internals

## Environment Variables Security

**NEVER commit these to version control**:
- `DATABASE_URL` — Contains database credentials
- `JWT_SECRET` — Secret key for token signing
- `CORS_ORIGIN` — Allowed origins

**`.env.example`** is committed as a template (no real values).

## Recommended Production Additions

| Measure | Why | How |
|---------|-----|-----|
| HTTPS | Encrypt traffic | nginx/Caddy reverse proxy |
| Refresh tokens | Extend sessions securely | Separate token rotation |
| IP whitelisting | Restrict access | Firewall rules |
| Audit logging | Track suspicious activity | Custom interceptor |
| Brute force protection | Progressive delays | @nestjs/throttler config |
| API key auth | Service-to-service | Custom guard |
