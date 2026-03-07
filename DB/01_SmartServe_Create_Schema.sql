-- =============================================================================
-- SmartServe POS - SAAS SCHEMA v6.0 (Multi-Tenant, Production Ready)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- TENANTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS tenants (
    Id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    subdomain VARCHAR(100) UNIQUE,
    plan VARCHAR(50),
    timezone VARCHAR(50),
    currency VARCHAR(10) DEFAULT 'INR',
    order_counter INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- ROLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS roles (
    Id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- =============================================================================
-- PERMISSIONS
-- =============================================================================
CREATE TABLE IF NOT EXISTS permissions (
    Id SERIAL PRIMARY KEY,
    permission_code VARCHAR(100) UNIQUE NOT NULL
);

-- =============================================================================
-- ROLE PERMISSIONS
-- =============================================================================
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INT REFERENCES roles(Id) ON DELETE CASCADE,
    permission_id INT REFERENCES permissions(Id) ON DELETE CASCADE,
    PRIMARY KEY(role_id, permission_id)
);

-- =============================================================================
-- USERS
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(100),
    email VARCHAR(150),
    role_id INT REFERENCES roles(Id),
    pin_hash VARCHAR(255),
    password_hash VARCHAR(255),
    last_login_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT ux_users_tenant_username UNIQUE (tenant_id, username)
);

CREATE INDEX idx_users_tenant ON users(tenant_id);
-- =============================================================================
-- USER ROLES (RBAC SUPPORT)
-- =============================================================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT REFERENCES users(Id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(Id) ON DELETE CASCADE,
    PRIMARY KEY(user_id, role_id)
);

-- =============================================================================
-- CATEGORIES
-- =============================================================================
CREATE TABLE IF NOT EXISTS categories (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (tenant_id, name)
);

CREATE INDEX idx_categories_tenant ON categories(tenant_id);

-- =============================================================================
-- BRANDS
-- =============================================================================
CREATE TABLE IF NOT EXISTS brands (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (tenant_id, name)
);

CREATE INDEX idx_brands_tenant ON brands(tenant_id);

-- =============================================================================
-- PRODUCTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS products (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    category_id INT REFERENCES categories(Id),
    food_type VARCHAR(10) CHECK (food_type IN ('VEG','NON_VEG')),
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_tenant ON products(tenant_id);

-- =============================================================================
-- PRODUCT VARIANTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS product_variants (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(Id) ON DELETE CASCADE,
    brand_id INT REFERENCES brands(Id),
    variant_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (tenant_id, product_id, brand_id, variant_name)
);

CREATE INDEX idx_variants_tenant_product
ON product_variants(tenant_id, product_id);

-- =============================================================================
-- PRODUCT INGREDIENTS (BOM)
-- =============================================================================
CREATE TABLE IF NOT EXISTS product_ingredients (
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    product_variant_id INT NOT NULL REFERENCES product_variants(Id) ON DELETE CASCADE,
    ingredient_variant_id INT NOT NULL REFERENCES product_variants(Id),
    quantity NUMERIC(10,3) NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (tenant_id, product_variant_id, ingredient_variant_id),
    CHECK (product_variant_id <> ingredient_variant_id)
);

-- =============================================================================
-- STOCK
-- =============================================================================
CREATE TABLE IF NOT EXISTS stock (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('VARIANT','INGREDIENT')),
    variant_id INT NOT NULL REFERENCES product_variants(Id) ON DELETE CASCADE,
    unit VARCHAR(20) NOT NULL,
    current_quantity NUMERIC(10,2) DEFAULT 0,
    min_stock_level NUMERIC(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (tenant_id, item_type, variant_id)
);

CREATE INDEX idx_stock_tenant_variant
ON stock(tenant_id, variant_id);

-- =============================================================================
-- STOCK TRANSACTIONS
-- =============================================================================
CREATE TABLE IF NOT EXISTS stock_transactions (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    stock_id INT NOT NULL REFERENCES stock(Id) ON DELETE CASCADE,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('IN','OUT','ADJUST')),
    quantity NUMERIC(10,2) NOT NULL CHECK (quantity > 0),
    reason VARCHAR(30) NOT NULL,
    reference_type VARCHAR(20),
    reference_id INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_stock_tx_tenant_created
ON stock_transactions(tenant_id, created_at);

-- =============================================================================
-- RESTAURANT TABLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS restaurant_tables (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    display_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tables_tenant ON restaurant_tables(tenant_id);

-- =============================================================================
-- TABLE STATUS
-- =============================================================================
CREATE TABLE IF NOT EXISTS table_status (
    Id SERIAL PRIMARY KEY,
    status_code VARCHAR(30) UNIQUE NOT NULL,
    status_name VARCHAR(50),
    color_hex VARCHAR(10)
);

-- =============================================================================
-- ORDERS
-- =============================================================================
CREATE TABLE IF NOT EXISTS orders (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    order_number VARCHAR(20) NOT NULL,
    order_type VARCHAR(20) CHECK (order_type IN ('DINE_IN','DELIVERY','PICKUP')),
    order_source VARCHAR(20) DEFAULT 'POS',
    table_id INT REFERENCES restaurant_tables(Id),
    status_id INT REFERENCES table_status(Id),
    created_by INT REFERENCES users(Id),
    original_amount NUMERIC(10,2) DEFAULT 0 CHECK (original_amount >= 0),
    total_amount NUMERIC(10,2) DEFAULT 0 CHECK (total_amount >= 0),
    discount_type VARCHAR(10) CHECK (discount_type IN ('FLAT','PERCENT')),
    discount_value NUMERIC(10,2) DEFAULT 0 CHECK (discount_value >= 0),
    discount_reason VARCHAR(100),
    payment_status VARCHAR(20),
    is_tracked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    UNIQUE (tenant_id, order_number)
);

CREATE INDEX idx_orders_tenant_created
ON orders(tenant_id, created_at);

-- =============================================================================
-- ORDER ITEMS
-- =============================================================================
CREATE TABLE IF NOT EXISTS order_items (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    order_id INT REFERENCES orders(Id) ON DELETE CASCADE,
    variant_id INT REFERENCES product_variants(Id),
    product_name_snapshot VARCHAR(150),
    variant_name_snapshot VARCHAR(100),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_snapshot NUMERIC(10,2) NOT NULL CHECK (price_snapshot >= 0),
    discount_amount NUMERIC(10,2) DEFAULT 0 CHECK (discount_amount >= 0)
);

CREATE INDEX idx_order_items_tenant_order
ON order_items(tenant_id, order_id);

-- =============================================================================
-- PAYMENTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS payments (
    Id SERIAL PRIMARY KEY,
    tenant_id INT NOT NULL REFERENCES tenants(Id) ON DELETE CASCADE,
    order_id INT REFERENCES orders(Id) ON DELETE CASCADE,
    mode VARCHAR(20) CHECK (mode IN ('CASH','UPI','CARD')),
    amount NUMERIC(10,2) CHECK (amount >= 0),
    status VARCHAR(20) CHECK (status IN ('PAID','FAILED')),
    transaction_ref VARCHAR(100),
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payments_tenant
ON payments(tenant_id);

-- =============================================================================
-- END
-- =============================================================================