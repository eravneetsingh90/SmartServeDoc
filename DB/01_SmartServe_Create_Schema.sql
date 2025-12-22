-- =============================================================================
-- SmartServe POS - Final Full Schema v3
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' SmartServe POS - FINAL SCHEMA v3';
    RAISE NOTICE ' Started at: %', NOW();
    RAISE NOTICE '============================================================';
END $$;

-- =============================================================================
-- ROLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

-- =============================================================================
-- USERS
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role_id INT REFERENCES roles(role_id),
    pin_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- CATEGORIES
-- =============================================================================
CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- =============================================================================
-- BRANDS (ICE CREAM)
-- =============================================================================
CREATE TABLE IF NOT EXISTS brands (
    brand_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- =============================================================================
-- PRODUCTS (LOGICAL BASE)
-- =============================================================================
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category_id INT REFERENCES categories(category_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- PRODUCT VARIANTS (SELLABLE ITEMS)
-- =============================================================================
CREATE TABLE IF NOT EXISTS product_variants (
    variant_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    brand_id INT REFERENCES brands(brand_id), -- NULL for burgers/scoops
    variant_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    tracks_stock BOOLEAN DEFAULT FALSE, -- TRUE only for sealed ice cream
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (product_id, brand_id, variant_name)
);

-- =============================================================================
-- ICE CREAM STOCK (SEALED UNITS ONLY)
-- =============================================================================
CREATE TABLE IF NOT EXISTS stock (
    variant_id INT PRIMARY KEY REFERENCES product_variants(variant_id),
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0)
);

-- =============================================================================
-- ICE CREAM STOCK TRANSACTIONS
-- =============================================================================
CREATE TABLE IF NOT EXISTS stock_transactions (
    stock_txn_id SERIAL PRIMARY KEY,
    variant_id INT REFERENCES product_variants(variant_id),
    change_qty INT NOT NULL,
    reason VARCHAR(20) NOT NULL CHECK (
        reason IN ('PURCHASE','SALE','OPENED','ADJUSTMENT')
    ),
    reference_id INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INGREDIENTS (BURGERS ONLY)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ingredients (
    ingredient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    unit VARCHAR(20) DEFAULT 'PCS',
    is_active BOOLEAN DEFAULT TRUE
);

-- =============================================================================
-- INGREDIENT STOCK
-- =============================================================================
CREATE TABLE IF NOT EXISTS ingredient_stock (
    ingredient_id INT PRIMARY KEY REFERENCES ingredients(ingredient_id),
    quantity NUMERIC(10,2) DEFAULT 0 CHECK (quantity >= 0)
);

-- =============================================================================
-- BURGER RECIPES (VARIANT → INGREDIENT)
-- =============================================================================
CREATE TABLE IF NOT EXISTS product_ingredients (
    variant_id INT REFERENCES product_variants(variant_id) ON DELETE CASCADE,
    ingredient_id INT REFERENCES ingredients(ingredient_id),
    qty_required NUMERIC(10,2) NOT NULL CHECK (qty_required > 0),
    PRIMARY KEY (variant_id, ingredient_id)
);

-- =============================================================================
-- INGREDIENT TRANSACTIONS (BURGER AUDIT)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ingredient_transactions (
    ingredient_txn_id SERIAL PRIMARY KEY,
    ingredient_id INT REFERENCES ingredients(ingredient_id),
    change_qty NUMERIC(10,2) NOT NULL,
    reason VARCHAR(20) NOT NULL CHECK (
        reason IN ('PURCHASE','SALE','WASTE','ADJUSTMENT')
    ),
    reference_id INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- RESTAURANT TABLES (DINE-IN)
-- =============================================================================
CREATE TABLE IF NOT EXISTS restaurant_tables (
    table_id SERIAL PRIMARY KEY,
    display_name VARCHAR(50) NOT NULL, -- T1, T2
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- TABLE STATUS (UI / WORKFLOW)
-- =============================================================================
CREATE TABLE IF NOT EXISTS table_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(30) UNIQUE NOT NULL, -- BLANK, RUNNING, PRINTED
    status_name VARCHAR(50),
    color_hex VARCHAR(10)
);

-- =============================================================================
-- ORDERS (WITH DISCOUNTS + TABLE MAPPING)
-- =============================================================================
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE,
    order_type VARCHAR(20) CHECK (
        order_type IN ('DINE_IN','DELIVERY','PICKUP')
    ),
    table_id INT REFERENCES restaurant_tables(table_id),
    status_id INT REFERENCES table_status(status_id),

    total_amount NUMERIC(10,2) DEFAULT 0 CHECK (total_amount >= 0),

    discount_type VARCHAR(10) CHECK (
        discount_type IN ('FLAT','PERCENT')
    ),
    discount_value NUMERIC(10,2) DEFAULT 0 CHECK (discount_value >= 0),
    discount_reason VARCHAR(100),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);

-- =============================================================================
-- ORDER ITEMS (VARIANT LEVEL + ITEM DISCOUNT)
-- =============================================================================
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    variant_id INT REFERENCES product_variants(variant_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_snapshot NUMERIC(10,2) NOT NULL CHECK (price_snapshot >= 0),
    discount_amount NUMERIC(10,2) DEFAULT 0 CHECK (discount_amount >= 0)
);

-- =============================================================================
-- PAYMENTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    mode VARCHAR(20) CHECK (mode IN ('CASH','UPI','CARD')),
    amount NUMERIC(10,2) CHECK (amount >= 0),
    status VARCHAR(20) CHECK (status IN ('PAID','FAILED')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INDEXES (PERFORMANCE)
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_variants_product ON product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_stock_variant ON stock(variant_id);
CREATE INDEX IF NOT EXISTS idx_ingredient_txn ON ingredient_transactions(ingredient_id);


-- =============================================================================
-- Update
-- =============================================================================

ALTER TABLE categories
ADD COLUMN display_order INT NOT NULL DEFAULT 0;

ALTER TABLE products
ADD COLUMN display_order INT NOT NULL DEFAULT 0;

ALTER TABLE product_variants
ADD COLUMN display_order INT NOT NULL DEFAULT 0;

-- =============================================================================
-- COMPLETION
-- =============================================================================
DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' SmartServe POS FINAL SCHEMA v3 CREATED SUCCESSFULLY';
    RAISE NOTICE ' Completed at: %', NOW();
    RAISE NOTICE '============================================================';
END $$;
