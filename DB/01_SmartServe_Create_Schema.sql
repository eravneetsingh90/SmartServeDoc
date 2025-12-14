-- ============================================================================
-- SmartServe Database Schema Creation Script
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'SmartServe Database Schema Creation';
    RAISE NOTICE 'Started at: %', NOW();
    RAISE NOTICE '============================================================================';
END $$;

-- ============================================================================
-- ROLES TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: roles';
    
    CREATE TABLE IF NOT EXISTS roles (
        role_id SERIAL PRIMARY KEY,
        role_name VARCHAR(50) NOT NULL UNIQUE
    );
    
    RAISE NOTICE '✓ Table roles created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table roles: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- USERS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: users';
    
    CREATE TABLE IF NOT EXISTS users (
        user_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        role_id INTEGER NOT NULL REFERENCES roles(role_id),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table users created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table users: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- CATEGORIES TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: categories';
    
    CREATE TABLE IF NOT EXISTS categories (
        category_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        is_active BOOLEAN DEFAULT TRUE
    );
    
    RAISE NOTICE '✓ Table categories created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table categories: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- FLAVORS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: flavors';
    
    CREATE TABLE IF NOT EXISTS flavors (
        flavor_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE
    );
    
    RAISE NOTICE '✓ Table flavors created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table flavors: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- SERVING TYPES TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: serving_types';
    
    CREATE TABLE IF NOT EXISTS serving_types (
        serving_type_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE
    );
    
    RAISE NOTICE '✓ Table serving_types created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table serving_types: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- BRANDS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: brands';
    
    CREATE TABLE IF NOT EXISTS brands (
        brand_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE
    );
    
    RAISE NOTICE '✓ Table brands created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table brands: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: products';
    
    CREATE TABLE IF NOT EXISTS products (
        product_id SERIAL PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        category_id INTEGER NOT NULL REFERENCES categories(category_id),
        flavor_id INTEGER REFERENCES flavors(flavor_id),
        serving_type_id INTEGER NOT NULL REFERENCES serving_types(serving_type_id),
        brand_id INTEGER REFERENCES brands(brand_id),
        price NUMERIC(10,2) NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table products created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table products: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- ORDERS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: orders';
    
    CREATE TABLE IF NOT EXISTS orders (
        order_id SERIAL PRIMARY KEY,
        order_number INTEGER UNIQUE,
        order_type VARCHAR(20) CHECK (order_type IN ('DINE_IN', 'TAKEAWAY')),
        status VARCHAR(20) CHECK (status IN ('NEW','PREPARING','COMPLETED','CANCELLED')),
        total_amount NUMERIC(10,2),
        created_by INTEGER REFERENCES users(user_id),
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table orders created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table orders: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- ORDER ITEMS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: order_items';
    
    CREATE TABLE IF NOT EXISTS order_items (
        order_item_id SERIAL PRIMARY KEY,
        order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
        product_id INTEGER NOT NULL REFERENCES products(product_id),
        quantity INTEGER NOT NULL,
        price_snapshot NUMERIC(10,2) NOT NULL,
        notes TEXT
    );
    
    RAISE NOTICE '✓ Table order_items created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table order_items: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- KOT (KITCHEN ORDER TICKET) TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: kot';
    
    CREATE TABLE IF NOT EXISTS kot (
        kot_id SERIAL PRIMARY KEY,
        order_id INTEGER UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
        status VARCHAR(20) CHECK (status IN ('NEW','IN_PROGRESS','READY')),
        printed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table kot created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table kot: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- INGREDIENTS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: ingredients';
    
    CREATE TABLE IF NOT EXISTS ingredients (
        ingredient_id SERIAL PRIMARY KEY,
        name VARCHAR(150) NOT NULL UNIQUE,
        base_unit VARCHAR(20) NOT NULL,
        ideal_variance_percent NUMERIC(5,2) DEFAULT 8.0,
        is_active BOOLEAN DEFAULT TRUE
    );
    
    RAISE NOTICE '✓ Table ingredients created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table ingredients: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- STOCK TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: stock';
    
    CREATE TABLE IF NOT EXISTS stock (
        ingredient_id INTEGER PRIMARY KEY REFERENCES ingredients(ingredient_id),
        current_qty NUMERIC(12,2) NOT NULL DEFAULT 0
    );
    
    RAISE NOTICE '✓ Table stock created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table stock: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- PRODUCT RECIPES TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: product_recipes';
    
    CREATE TABLE IF NOT EXISTS product_recipes (
        product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
        ingredient_id INTEGER REFERENCES ingredients(ingredient_id),
        qty_required NUMERIC(10,2) NOT NULL,
        PRIMARY KEY (product_id, ingredient_id)
    );
    
    RAISE NOTICE '✓ Table product_recipes created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table product_recipes: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- STOCK TRANSACTIONS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: stock_transactions';
    
    CREATE TABLE IF NOT EXISTS stock_transactions (
        stock_txn_id SERIAL PRIMARY KEY,
        ingredient_id INTEGER REFERENCES ingredients(ingredient_id),
        change_qty NUMERIC(10,2) NOT NULL,
        reason VARCHAR(30) CHECK (reason IN ('SALE','PURCHASE','WASTE','ADJUSTMENT')),
        reference_id INTEGER,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table stock_transactions created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table stock_transactions: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- STOCK ADJUSTMENTS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: stock_adjustments';
    
    CREATE TABLE IF NOT EXISTS stock_adjustments (
        adjustment_id SERIAL PRIMARY KEY,
        ingredient_id INTEGER REFERENCES ingredients(ingredient_id),
        expected_qty NUMERIC(10,2),
        actual_qty NUMERIC(10,2),
        variance_qty NUMERIC(10,2),
        reason VARCHAR(50),
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table stock_adjustments created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table stock_adjustments: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- VENDORS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: vendors';
    
    CREATE TABLE IF NOT EXISTS vendors (
        vendor_id SERIAL PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
        phone VARCHAR(20),
        gst_no VARCHAR(20),
        is_active BOOLEAN DEFAULT TRUE
    );
    
    RAISE NOTICE '✓ Table vendors created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table vendors: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- PURCHASE BILLS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: purchase_bills';
    
    CREATE TABLE IF NOT EXISTS purchase_bills (
        purchase_bill_id SERIAL PRIMARY KEY,
        vendor_id INTEGER REFERENCES vendors(vendor_id),
        bill_number VARCHAR(50),
        bill_date DATE,
        total_amount NUMERIC(10,2),
        image_url TEXT,
        ocr_status VARCHAR(20) CHECK (ocr_status IN ('PENDING','SUCCESS','FAILED')),
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table purchase_bills created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table purchase_bills: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- PURCHASE BILL PARSED ITEMS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: purchase_bill_parsed_items';
    
    CREATE TABLE IF NOT EXISTS purchase_bill_parsed_items (
        parsed_item_id SERIAL PRIMARY KEY,
        purchase_bill_id INTEGER REFERENCES purchase_bills(purchase_bill_id) ON DELETE CASCADE,
        raw_item_text TEXT,
        extracted_name VARCHAR(200),
        quantity NUMERIC(10,2),
        unit VARCHAR(20),
        unit_price NUMERIC(10,2),
        confidence_score NUMERIC(5,2)
    );
    
    RAISE NOTICE '✓ Table purchase_bill_parsed_items created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table purchase_bill_parsed_items: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- PURCHASE ITEMS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: purchase_items';
    
    CREATE TABLE IF NOT EXISTS purchase_items (
        purchase_item_id SERIAL PRIMARY KEY,
        purchase_bill_id INTEGER REFERENCES purchase_bills(purchase_bill_id) ON DELETE CASCADE,
        ingredient_id INTEGER REFERENCES ingredients(ingredient_id),
        quantity NUMERIC(10,2),
        unit_price NUMERIC(10,2),
        total_amount NUMERIC(10,2)
    );
    
    RAISE NOTICE '✓ Table purchase_items created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table purchase_items: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- INGREDIENT ALIASES TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: ingredient_aliases';
    
    CREATE TABLE IF NOT EXISTS ingredient_aliases (
        alias_id SERIAL PRIMARY KEY,
        ingredient_id INTEGER REFERENCES ingredients(ingredient_id) ON DELETE CASCADE,
        alias_name VARCHAR(150) NOT NULL
    );
    
    RAISE NOTICE '✓ Table ingredient_aliases created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table ingredient_aliases: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- UNIT CONVERSIONS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: unit_conversions';
    
    CREATE TABLE IF NOT EXISTS unit_conversions (
        from_unit VARCHAR(20),
        to_unit VARCHAR(20),
        conversion_factor NUMERIC(10,4),
        PRIMARY KEY (from_unit, to_unit)
    );
    
    RAISE NOTICE '✓ Table unit_conversions created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table unit_conversions: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- PAYMENTS TABLE
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Creating table: payments';
    
    CREATE TABLE IF NOT EXISTS payments (
        payment_id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
        mode VARCHAR(20) CHECK (mode IN ('CASH','UPI','CARD')),
        amount NUMERIC(10,2),
        status VARCHAR(20) CHECK (status IN ('PAID','FAILED')),
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    RAISE NOTICE '✓ Table payments created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create table payments: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- INDEXES
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Creating indexes...';
    
    CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
    RAISE NOTICE '✓ Index idx_orders_created_at created';
    
    CREATE INDEX IF NOT EXISTS idx_stock_txn_ingredient ON stock_transactions(ingredient_id);
    RAISE NOTICE '✓ Index idx_stock_txn_ingredient created';
    
    CREATE INDEX IF NOT EXISTS idx_purchase_bill_vendor ON purchase_bills(vendor_id);
    RAISE NOTICE '✓ Index idx_purchase_bill_vendor created';
    
    CREATE INDEX IF NOT EXISTS idx_products_flavor ON products(flavor_id);
    RAISE NOTICE '✓ Index idx_products_flavor created';
    
    CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
    RAISE NOTICE '✓ Index idx_products_category created';
    
    CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
    RAISE NOTICE '✓ Index idx_order_items_order_id created';
    
    CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
    RAISE NOTICE '✓ Index idx_order_items_product_id created';
    
    RAISE NOTICE '✓ All indexes created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to create some indexes: %', SQLERRM;
        RAISE;
END $$;

-- ============================================================================
-- COMPLETION
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'SmartServe Database Schema Creation Completed Successfully!';
    RAISE NOTICE 'Completed at: %', NOW();
    RAISE NOTICE '============================================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '  - 22 tables created';
    RAISE NOTICE '  - 7 indexes created';
    RAISE NOTICE '  - All foreign key relationships established';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '  1. Verify tables: SELECT tablename FROM pg_tables WHERE schemaname = ''public'';';
    RAISE NOTICE '  2. Insert seed data if needed';
    RAISE NOTICE '  3. Set up application connection';
    RAISE NOTICE '';
END $$;
