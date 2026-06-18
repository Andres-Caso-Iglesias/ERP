# API Reference — ERP Food Bites Backend

Base URL: `http://localhost:5000/api`

## Authentication

All endpoints except `/auth/*` require a JWT token in the `Authorization` header:
```
Authorization: Bearer <token>
```

---

## Auth Module

### POST /api/auth/register
Register a new user.

**Rate Limit**: 5 requests per minute

**Request Body**:
```json
{
  "username": "string (3-50 chars, alphanumeric + underscore)",
  "password": "string (8-128 chars, must contain uppercase, lowercase, number, special char)"
}
```

**Response (201)**:
```json
{
  "msg": "User registered successfully",
  "user": {
    "id": 1,
    "username": "john_doe"
  }
}
```

**Errors**:
- `400` — Validation failed (missing fields, weak password)
- `409` — Username already exists
- `429` — Rate limit exceeded

---

### POST /api/auth/login
Authenticate user and get JWT token.

**Rate Limit**: 10 requests per minute

**Request Body**:
```json
{
  "username": "string",
  "password": "string"
}
```

**Response (200)**:
```json
{
  "msg": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "username": "john_doe"
  }
}
```

**Errors**:
- `400` — Invalid credentials
- `429` — Rate limit exceeded

---

## Sales Module

All endpoints require JWT authentication.

### GET /api/sales
Get all sales (ordered by date descending).

**Response (200)**:
```json
[
  {
    "id": 1,
    "client_id": 1,
    "sale_date": "2025-09-15T10:00:00Z",
    "total": 25.50,
    "status": "pending",
    "created_at": "2025-09-15T10:00:00Z"
  }
]
```

---

### GET /api/sales/:id
Get a single sale by ID.

**Response (200)**: Sale object

**Errors**:
- `404` — Sale not found

---

### POST /api/sales
Create a new sale.

**Request Body**:
```json
{
  "clientId": 1,
  "saleDate": "2025-09-15T10:00:00Z",
  "total": 25.50,
  "status": "pending"
}
```

**Response (201)**: Created sale object

**Validation**:
- `clientId` — required, number
- `saleDate` — required, ISO date string
- `total` — required, number >= 0.01
- `status` — optional, string

---

### PUT /api/sales/:id
Update an existing sale.

**Request Body** (all fields optional):
```json
{
  "clientId": 1,
  "saleDate": "2025-09-15T10:00:00Z",
  "total": 30.00,
  "status": "completed"
}
```

**Response (200)**: Updated sale object

**Errors**:
- `404` — Sale not found

---

### DELETE /api/sales/:id
Delete a sale.

**Response (200)**:
```json
{ "msg": "Sale deleted successfully" }
```

**Errors**:
- `404` — Sale not found

---

## Clients Module

All endpoints require JWT authentication.

### GET /api/clients
Get all clients (ordered by name).

### GET /api/clients/:id
Get a single client by ID.

### POST /api/clients
Create a new client.

**Request Body**:
```json
{
  "name": "string (required, 1-100 chars)",
  "email": "string (optional, valid email)",
  "phone": "string (optional, max 20 chars)",
  "status": "string (optional, default: active)"
}
```

### PUT /api/clients/:id
Update an existing client (all fields optional).

### DELETE /api/clients/:id
Delete a client.

---

## Inventory Module

All endpoints require JWT authentication.

### GET /api/inventory
Get all products (ordered by product_name).

### GET /api/inventory/:id
Get a single product by ID.

### POST /api/inventory
Create a new product.

**Request Body**:
```json
{
  "productName": "string (required, 1-100 chars)",
  "quantity": 50,
  "price": 1.50,
  "category": "string (required, 1-50 chars)"
}
```

### PUT /api/inventory/:id
Update an existing product (all fields optional).

### DELETE /api/inventory/:id
Delete a product.

---

## Accounting Module

All endpoints require JWT authentication.

### GET /api/accounting
Get all entries (ordered by transaction_date descending).

### GET /api/accounting/:id
Get a single entry by ID.

### POST /api/accounting
Create a new entry.

**Request Body**:
```json
{
  "transactionDate": "2025-09-15T10:00:00Z",
  "description": "string (required, 1-255 chars)",
  "amount": 150.00,
  "type": "string (required, 1-20 chars, e.g. 'income' or 'expense')",
  "category": "string (optional, max 50 chars, default: 'general')"
}
```

### PUT /api/accounting/:id
Update an existing entry (all fields optional).

### DELETE /api/accounting/:id
Delete an entry.

---

## Notifications Module

All endpoints require JWT authentication. Notifications are scoped to the authenticated user.

### GET /api/notifications
Get all notifications for the authenticated user (ordered by created_at descending).

### GET /api/notifications/:id
Get a single notification by ID (must belong to authenticated user).

### POST /api/notifications
Create a new notification.

**Request Body**:
```json
{
  "userId": 1,
  "message": "string (required, 1-500 chars)"
}
```

### PUT /api/notifications/:id/read
Mark a notification as read.

**Response (200)**: Updated notification with `status: "read"`

### DELETE /api/notifications/:id
Delete a notification (must belong to authenticated user).

---

## Error Response Format

All errors follow NestJS default format:
```json
{
  "statusCode": 404,
  "message": "Sale with ID 999 not found",
  "error": "Not Found"
}
```

## Rate Limiting

| Endpoint | Limit | Window |
|----------|-------|--------|
| Global | 100 requests | 60 seconds |
| POST /auth/register | 5 requests | 60 seconds |
| POST /auth/login | 10 requests | 60 seconds |
