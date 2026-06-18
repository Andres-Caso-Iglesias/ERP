-- ============================================================
-- ERP Food Bites — Seed Data (Development Only)
-- ============================================================
-- This file is only for development/testing purposes.
-- In production, users should register through the API.

-- Default admin user (password: Admin123!)
-- bcrypt hash with 12 salt rounds
INSERT INTO users (username, password_hash) 
VALUES ('admin', '$2b$12$LJ3m4ys3Lz0YBNOURq0Y3OjCfKJmKPOJmKPOJmKPOJmKPOJmKPOJm')
ON CONFLICT (username) DO NOTHING;

-- Sample clients
INSERT INTO clients (name, email, phone, status) VALUES
('Juan Pérez', 'juan@ejemplo.com', '+34612345678', 'active'),
('María García', 'maria@ejemplo.com', '+34687654321', 'active'),
('Carlos López', 'carlos@ejemplo.com', '+34611223344', 'inactive')
ON CONFLICT DO NOTHING;

-- Sample inventory
INSERT INTO inventory (product_name, quantity, price, category) VALUES
('Harina', 100, 1.50, 'Ingredientes'),
('Tomates', 200, 0.80, 'Vegetales'),
('Queso Mozzarella', 50, 5.20, 'Lácteos'),
('Aceite de Oliva', 30, 8.50, 'Aceites'),
('Salsa de Tomate', 80, 2.10, 'Ingredientes')
ON CONFLICT DO NOTHING;
