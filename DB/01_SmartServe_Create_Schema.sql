CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE roles (
    role_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    role_id UUID NOT NULL REFERENCES roles(role_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE flavors (
    flavor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE serving_types (
    serving_type_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE brands (
    brand_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    category_id UUID NOT NULL REFERENCES categories(category_id),
    flavor_id UUID REFERENCES flavors(flavor_id),
    serving_type_id UUID NOT NULL REFERENCES serving_types(serving_type_id),
    brand_id UUID REFERENCES brands(brand_id),
    price NUMERIC(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number SERIAL,
    order_type VARCHAR(20) CHECK (order_type IN ('DINE_IN', 'TAKEAWAY')),
    status VARCHAR(20) CHECK (status IN ('NEW','PREPARING','COMPLETED','CANCELLED')),
    total_amount NUMERIC(10,2),
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    price_snapshot NUMERIC(10,2) NOT NULL,
    notes TEXT
);

CREATE TABLE kot (
    kot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    status VARCHAR(20) CHECK (status IN ('NEW','IN_PROGRESS','READY')),
    printed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE ingredients (
    ingredient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL UNIQUE,
    base_unit VARCHAR(20) NOT NULL,
    ideal_variance_percent NUMERIC(5,2) DEFAULT 8.0,
    is_active BOOLEAN DEFAULT TRUE
);
CREATE TABLE stock (
    ingredient_id UUID PRIMARY KEY REFERENCES ingredients(ingredient_id),
    current_qty NUMERIC(12,2) NOT NULL DEFAULT 0
);
CREATE TABLE product_recipes (
    product_id UUID REFERENCES products(product_id) ON DELETE CASCADE,
    ingredient_id UUID REFERENCES ingredients(ingredient_id),
    qty_required NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (product_id, ingredient_id)
);
CREATE TABLE stock_transactions (
    stock_txn_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID REFERENCES ingredients(ingredient_id),
    change_qty NUMERIC(10,2) NOT NULL,
    reason VARCHAR(30) CHECK (reason IN ('SALE','PURCHASE','WASTE','ADJUSTMENT')),
    reference_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE stock_adjustments (
    adjustment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID REFERENCES ingredients(ingredient_id),
    expected_qty NUMERIC(10,2),
    actual_qty NUMERIC(10,2),
    variance_qty NUMERIC(10,2),
    reason VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE vendors (
    vendor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    gst_no VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE
);
CREATE TABLE purchase_bills (
    purchase_bill_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES vendors(vendor_id),
    bill_number VARCHAR(50),
    bill_date DATE,
    total_amount NUMERIC(10,2),
    image_url TEXT,
    ocr_status VARCHAR(20) CHECK (ocr_status IN ('PENDING','SUCCESS','FAILED')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE purchase_bill_parsed_items (
    parsed_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_bill_id UUID REFERENCES purchase_bills(purchase_bill_id) ON DELETE CASCADE,
    raw_item_text TEXT,
    extracted_name VARCHAR(200),
    quantity NUMERIC(10,2),
    unit VARCHAR(20),
    unit_price NUMERIC(10,2),
    confidence_score NUMERIC(5,2)
);
CREATE TABLE purchase_items (
    purchase_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_bill_id UUID REFERENCES purchase_bills(purchase_bill_id) ON DELETE CASCADE,
    ingredient_id UUID REFERENCES ingredients(ingredient_id),
    quantity NUMERIC(10,2),
    unit_price NUMERIC(10,2),
    total_amount NUMERIC(10,2)
);
CREATE TABLE ingredient_aliases (
    alias_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID REFERENCES ingredients(ingredient_id) ON DELETE CASCADE,
    alias_name VARCHAR(150) NOT NULL
);
CREATE TABLE unit_conversions (
    from_unit VARCHAR(20),
    to_unit VARCHAR(20),
    conversion_factor NUMERIC(10,4),
    PRIMARY KEY (from_unit, to_unit)
);
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(order_id) ON DELETE CASCADE,
    mode VARCHAR(20) CHECK (mode IN ('CASH','UPI','CARD')),
    amount NUMERIC(10,2),
    status VARCHAR(20) CHECK (status IN ('PAID','FAILED')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_stock_txn_ingredient ON stock_transactions(ingredient_id);
CREATE INDEX idx_purchase_bill_vendor ON purchase_bills(vendor_id);
CREATE INDEX idx_products_flavor ON products(flavor_id);
