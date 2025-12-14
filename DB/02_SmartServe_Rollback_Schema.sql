-- ============================================================================
-- SmartServe Database Rollback Script
-- WARNING: This will DELETE ALL DATA in SmartServe tables!
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'SmartServe Database Rollback Script';
    RAISE NOTICE 'Started at: %', NOW();
    RAISE NOTICE '============================================================================';
    RAISE WARNING 'This script will DELETE ALL DATA in SmartServe tables!';
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- DROP INDEXES
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'Dropping indexes...';
    
    DROP INDEX IF EXISTS idx_order_items_product_id CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_order_items_product_id';
    
    DROP INDEX IF EXISTS idx_order_items_order_id CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_order_items_order_id';
    
    DROP INDEX IF EXISTS idx_products_category CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_products_category';
    
    DROP INDEX IF EXISTS idx_products_flavor CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_products_flavor';
    
    DROP INDEX IF EXISTS idx_purchase_bill_vendor CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_purchase_bill_vendor';
    
    DROP INDEX IF EXISTS idx_stock_txn_ingredient CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_stock_txn_ingredient';
    
    DROP INDEX IF EXISTS idx_orders_created_at CASCADE;
    RAISE NOTICE '✓ Dropped index: idx_orders_created_at';
    
    RAISE NOTICE '✓ All indexes dropped successfully';
    RAISE NOTICE '';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Error dropping indexes: %', SQLERRM;
        RAISE NOTICE 'Continuing with table drops...';
        RAISE NOTICE '';
END $$;

-- ============================================================================
-- DROP TABLES (in reverse dependency order)
-- ============================================================================

-- Drop payments table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: payments';
    DROP TABLE IF EXISTS payments CASCADE;
    RAISE NOTICE '✓ Table payments dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table payments: %', SQLERRM;
END $$;

-- Drop ingredient_aliases table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: ingredient_aliases';
    DROP TABLE IF EXISTS ingredient_aliases CASCADE;
    RAISE NOTICE '✓ Table ingredient_aliases dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table ingredient_aliases: %', SQLERRM;
END $$;

-- Drop purchase_items table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: purchase_items';
    DROP TABLE IF EXISTS purchase_items CASCADE;
    RAISE NOTICE '✓ Table purchase_items dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table purchase_items: %', SQLERRM;
END $$;

-- Drop purchase_bill_parsed_items table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: purchase_bill_parsed_items';
    DROP TABLE IF EXISTS purchase_bill_parsed_items CASCADE;
    RAISE NOTICE '✓ Table purchase_bill_parsed_items dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table purchase_bill_parsed_items: %', SQLERRM;
END $$;

-- Drop purchase_bills table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: purchase_bills';
    DROP TABLE IF EXISTS purchase_bills CASCADE;
    RAISE NOTICE '✓ Table purchase_bills dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table purchase_bills: %', SQLERRM;
END $$;

-- Drop vendors table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: vendors';
    DROP TABLE IF EXISTS vendors CASCADE;
    RAISE NOTICE '✓ Table vendors dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table vendors: %', SQLERRM;
END $$;

-- Drop stock_adjustments table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: stock_adjustments';
    DROP TABLE IF EXISTS stock_adjustments CASCADE;
    RAISE NOTICE '✓ Table stock_adjustments dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table stock_adjustments: %', SQLERRM;
END $$;

-- Drop stock_transactions table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: stock_transactions';
    DROP TABLE IF EXISTS stock_transactions CASCADE;
    RAISE NOTICE '✓ Table stock_transactions dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table stock_transactions: %', SQLERRM;
END $$;

-- Drop unit_conversions table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: unit_conversions';
    DROP TABLE IF EXISTS unit_conversions CASCADE;
    RAISE NOTICE '✓ Table unit_conversions dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table unit_conversions: %', SQLERRM;
END $$;

-- Drop product_recipes table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: product_recipes';
    DROP TABLE IF EXISTS product_recipes CASCADE;
    RAISE NOTICE '✓ Table product_recipes dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table product_recipes: %', SQLERRM;
END $$;

-- Drop stock table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: stock';
    DROP TABLE IF EXISTS stock CASCADE;
    RAISE NOTICE '✓ Table stock dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table stock: %', SQLERRM;
END $$;

-- Drop ingredients table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: ingredients';
    DROP TABLE IF EXISTS ingredients CASCADE;
    RAISE NOTICE '✓ Table ingredients dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table ingredients: %', SQLERRM;
END $$;

-- Drop kot table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: kot';
    DROP TABLE IF EXISTS kot CASCADE;
    RAISE NOTICE '✓ Table kot dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table kot: %', SQLERRM;
END $$;

-- Drop order_items table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: order_items';
    DROP TABLE IF EXISTS order_items CASCADE;
    RAISE NOTICE '✓ Table order_items dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table order_items: %', SQLERRM;
END $$;

-- Drop orders table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: orders';
    DROP TABLE IF EXISTS orders CASCADE;
    RAISE NOTICE '✓ Table orders dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table orders: %', SQLERRM;
END $$;

-- Drop products table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: products';
    DROP TABLE IF EXISTS products CASCADE;
    RAISE NOTICE '✓ Table products dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table products: %', SQLERRM;
END $$;

-- Drop brands table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: brands';
    DROP TABLE IF EXISTS brands CASCADE;
    RAISE NOTICE '✓ Table brands dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table brands: %', SQLERRM;
END $$;

-- Drop serving_types table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: serving_types';
    DROP TABLE IF EXISTS serving_types CASCADE;
    RAISE NOTICE '✓ Table serving_types dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table serving_types: %', SQLERRM;
END $$;

-- Drop flavors table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: flavors';
    DROP TABLE IF EXISTS flavors CASCADE;
    RAISE NOTICE '✓ Table flavors dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table flavors: %', SQLERRM;
END $$;

-- Drop categories table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: categories';
    DROP TABLE IF EXISTS categories CASCADE;
    RAISE NOTICE '✓ Table categories dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table categories: %', SQLERRM;
END $$;

-- Drop users table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: users';
    DROP TABLE IF EXISTS users CASCADE;
    RAISE NOTICE '✓ Table users dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table users: %', SQLERRM;
END $$;

-- Drop roles table
DO $$
BEGIN
    RAISE NOTICE 'Dropping table: roles';
    DROP TABLE IF EXISTS roles CASCADE;
    RAISE NOTICE '✓ Table roles dropped';
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Failed to drop table roles: %', SQLERRM;
END $$;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
    remaining_count INTEGER;
    remaining_tables TEXT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Verifying cleanup...';
    
    SELECT COUNT(*), string_agg(tablename, ', ')
    INTO remaining_count, remaining_tables
    FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename IN (
        'roles', 'users', 'categories', 'flavors', 'serving_types', 'brands',
        'products', 'orders', 'order_items', 'kot', 'ingredients', 'stock',
        'product_recipes', 'stock_transactions', 'stock_adjustments', 'vendors',
        'purchase_bills', 'purchase_bill_parsed_items', 'purchase_items',
        'ingredient_aliases', 'unit_conversions', 'payments'
    );
    
    IF remaining_count > 0 THEN
        RAISE WARNING '⚠ Still remaining: % tables - %', remaining_count, remaining_tables;
        RAISE NOTICE 'You may need to manually drop these tables or check for permission issues.';
    ELSE
        RAISE NOTICE '✓ SUCCESS! All 22 SmartServe tables have been dropped!';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '✗ Error during verification: %', SQLERRM;
END $$;

-- ============================================================================
-- COMPLETION
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'SmartServe Database Rollback Completed';
    RAISE NOTICE 'Completed at: %', NOW();
    RAISE NOTICE '============================================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '  - All indexes dropped';
    RAISE NOTICE '  - All tables dropped (see verification above)';
    RAISE NOTICE '';
    RAISE NOTICE 'To recreate the schema:';
    RAISE NOTICE '  Run: 01_SmartServe_Create_Schema.sql';
    RAISE NOTICE '';
END $$;
