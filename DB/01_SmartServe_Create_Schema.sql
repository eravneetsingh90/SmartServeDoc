-- =============================================================================
-- SmartServe POS - FINAL SCHEMA v4.1 (Unified PK Naming)
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' SmartServe POS - FINAL SCHEMA v4.1';
    RAISE NOTICE ' Started at: %', NOW();
    RAISE NOTICE '============================================================';
END $$;

-- =============================================================================
-- ROLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS roles (
    Id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- =============================================================================
-- USERS
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    Id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role_id INT REFERENCES roles(Id),
    pin_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- CATEGORIES
-- =============================================================================
CREATE TABLE IF NOT EXISTS categories (
    Id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT NOT NULL DEFAULT 0
);

-- =============================================================================
-- BRANDS
-- =============================================================================
CREATE TABLE IF NOT EXISTS brands (
    Id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- =============================================================================
-- PRODUCTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS products (
    Id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category_id INT REFERENCES categories(Id),
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- PRODUCT VARIANTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS product_variants (
    Id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(Id) ON DELETE CASCADE,
    brand_id INT REFERENCES brands(Id),
    variant_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (product_id, brand_id, variant_name)
);

CREATE INDEX IF NOT EXISTS idx_variants_product
    ON product_variants(product_id);

-- =============================================================================
-- PRODUCT INGREDIENTS (RECIPE / BOM)
-- =============================================================================
CREATE TABLE IF NOT EXISTS product_ingredients (
    product_variant_id INT NOT NULL
        REFERENCES product_variants(Id)
        ON DELETE CASCADE,

    ingredient_variant_id INT NOT NULL
        REFERENCES product_variants(Id),

    quantity NUMERIC(10,3) NOT NULL CHECK (quantity > 0),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,

    PRIMARY KEY (product_variant_id, ingredient_variant_id),

    CONSTRAINT chk_no_self_reference
        CHECK (product_variant_id <> ingredient_variant_id)
);

CREATE INDEX IF NOT EXISTS idx_pi_product_variant
    ON product_ingredients(product_variant_id);

-- =============================================================================
-- STOCK
-- =============================================================================
CREATE TABLE IF NOT EXISTS stock (
    Id SERIAL PRIMARY KEY,

    item_type VARCHAR(20) NOT NULL
        CHECK (item_type IN ('VARIANT','INGREDIENT')),

    variant_id INT NOT NULL
        REFERENCES product_variants(Id)
        ON DELETE CASCADE,

    unit VARCHAR(20) NOT NULL,       -- PCS, ML, GM
    min_stock_level NUMERIC(10,2) DEFAULT 0,

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (item_type, variant_id)
);

CREATE INDEX IF NOT EXISTS idx_stock_variant
    ON stock(variant_id);

-- =============================================================================
-- STOCK TRANSACTIONS
-- =============================================================================
CREATE TABLE IF NOT EXISTS stock_transactions (
    Id SERIAL PRIMARY KEY,

    stock_id INT NOT NULL
        REFERENCES stock(Id)
        ON DELETE CASCADE,

    transaction_type VARCHAR(10) NOT NULL
        CHECK (transaction_type IN ('IN','OUT','ADJUST')),

    quantity NUMERIC(10,2) NOT NULL CHECK (quantity > 0),

    reason VARCHAR(30) NOT NULL,
    reference_type VARCHAR(20),
    reference_id INT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stock_tx_stock
    ON stock_transactions(stock_id);

CREATE INDEX IF NOT EXISTS idx_stock_tx_created
    ON stock_transactions(created_at);

-- =============================================================================
-- RESTAURANT TABLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS restaurant_tables (
    Id SERIAL PRIMARY KEY,
    display_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

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
    order_number VARCHAR(20) UNIQUE,

    order_type VARCHAR(20) CHECK (
        order_type IN ('DINE_IN','DELIVERY','PICKUP')
    ),

    table_id INT REFERENCES restaurant_tables(Id),
    status_id INT REFERENCES table_status(Id),
    original_amount NUMERIC(10,2) DEFAULT 0 CHECK (original_amount >= 0),
    total_amount NUMERIC(10,2) DEFAULT 0 CHECK (total_amount >= 0),

    discount_type VARCHAR(10) CHECK (
        discount_type IN ('FLAT','PERCENT')
    ),
    discount_value NUMERIC(10,2) DEFAULT 0 CHECK (discount_value >= 0),
    discount_reason VARCHAR(100),
    is_tracked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_orders_created
    ON orders(created_at);

-- =============================================================================
-- ORDER ITEMS
-- =============================================================================
CREATE TABLE IF NOT EXISTS order_items (
    Id SERIAL PRIMARY KEY,

    order_id INT REFERENCES orders(Id) ON DELETE CASCADE,
    variant_id INT REFERENCES product_variants(Id),

    quantity INT NOT NULL CHECK (quantity > 0),
    price_snapshot NUMERIC(10,2) NOT NULL CHECK (price_snapshot >= 0),
    discount_amount NUMERIC(10,2) DEFAULT 0 CHECK (discount_amount >= 0)
);

CREATE INDEX IF NOT EXISTS idx_order_items_order
    ON order_items(order_id);

-- =============================================================================
-- PAYMENTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS payments (
    Id SERIAL PRIMARY KEY,

    order_id INT REFERENCES orders(Id) ON DELETE CASCADE,

    mode VARCHAR(20) CHECK (mode IN ('CASH','UPI','CARD')),
    amount NUMERIC(10,2) CHECK (amount >= 0),
    status VARCHAR(20) CHECK (status IN ('PAID','FAILED')),

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- COMPLETION
-- =============================================================================

ALTER TABLE products
ADD COLUMN food_type VARCHAR(10)
CHECK (food_type IN ('VEG', 'NON_VEG'));


DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' SmartServe POS FINAL SCHEMA v4.1 CREATED SUCCESSFULLY';
    RAISE NOTICE ' Completed at: %', NOW();
    RAISE NOTICE '============================================================';
END $$;
