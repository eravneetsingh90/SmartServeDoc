DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' Inserting seed data into roles table';
    RAISE NOTICE '============================================================';

    INSERT INTO roles (role_name)
    VALUES
        ('OWNER'),
        ('MANAGER'),
        ('CASHIER'),
        ('KITCHEN')
    ON CONFLICT (role_name) DO NOTHING;

    RAISE NOTICE '✓ Roles inserted (existing roles skipped)';
    RAISE NOTICE '============================================================';
END $$;


--admin 1234, user 1111
INSERT INTO users (name, role_id, is_active, pin_hash)
VALUES
('admin', 1, true,'A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ='),
('user', 2, true, 'A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=');


INSERT INTO table_status (status_code, status_name, color_hex)
VALUES
('BLANK', 'Blank Table', '#E0E0E0'),
('RUNNING', 'Running Table', '#64B5F6'),
('PRINTED', 'Printed Table', '#81C784'),
('PAID', 'Paid Table', '#FFD54F'),
('RUNNING_KOT', 'Running KOT', '#FFB74D');


INSERT INTO restaurant_tables (display_name, is_active)
VALUES
('Table 1', true),
('Table 2', true),
('Table 3', true),
('Table 4', true),
('Table 5', true);


INSERT INTO categories (name) VALUES
('Ice Cream Scoops'),
('Ice Cream Cake'),
('Sundae Ice Cream'),
('Tawa Ice Cream'),
('Waffle'),
('Burger'),
('Wrap'),
('Sandwich'),
('Fries'),
('Beverages')
ON CONFLICT (name) DO NOTHING;


INSERT INTO brands (name) VALUES
('Havmor'),
('Amul'),
('Lotus'),
('HoCo')
ON CONFLICT (name) DO NOTHING;

INSERT INTO products (name, category_id)
SELECT 'Vanilla', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Strawberry', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Mix Fruit', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Cherry Berry', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Butter Scotch', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Alphonso Mango', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chocolate', category_id FROM categories WHERE name='Ice Cream Scoops'
ON CONFLICT DO NOTHING;
INSERT INTO products (name, category_id)
SELECT 'Black Currant', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Swiss Cake', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Bubble Gum', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chocolate Chips', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Cookie Cream', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Kaju Draksh', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Pineapple', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Coffee', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Almond Carnival', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Blue Berry', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Malai Rabri', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Kesar Pista', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Rajbhog', category_id FROM categories WHERE name='Ice Cream Scoops'
ON CONFLICT DO NOTHING;
INSERT INTO products (name, category_id)
SELECT 'American Nuts', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chocolate Brownie', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Fruit Blast', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Lajwab Gulkand', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Fruit Cocktail', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Paan', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chappan Bhog', category_id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Fruit Punch', category_id FROM categories WHERE name='Ice Cream Scoops'
ON CONFLICT DO NOTHING;



INSERT INTO product_variants (product_id, variant_name, price, tracks_stock)
SELECT p.product_id, v.variant_name, v.price, FALSE
FROM products p
JOIN (VALUES
    ('Single Scoop', 50),
    ('Double Scoop', 80),
    ('Tub', 220)
) v(variant_name, price)
ON TRUE
WHERE p.name IN (
    'Vanilla',
    'Strawberry',
    'Mix Fruit',
    'Cherry Berry',
    'Butter Scotch',
    'Alphonso Mango',
    'Chocolate'
)
ON CONFLICT DO NOTHING;


INSERT INTO product_variants (product_id, variant_name, price, tracks_stock)
SELECT p.product_id, v.variant_name, v.price, FALSE
FROM products p
JOIN (VALUES
    ('Single Scoop', 60),
    ('Double Scoop', 100),
    ('Tub', 280)
) v(variant_name, price)
ON TRUE
WHERE p.name IN (
    'Black Currant',
    'Swiss Cake',
    'Bubble Gum',
    'Chocolate Chips',
    'Cookie Cream',
    'Kaju Draksh',
    'Pineapple',
    'Coffee',
    'Almond Carnival',
    'Blue Berry',
    'Malai Rabri',
    'Kesar Pista',
    'Rajbhog'
)
ON CONFLICT DO NOTHING;


INSERT INTO product_variants (product_id, variant_name, price, tracks_stock)
SELECT p.product_id, v.variant_name, v.price, FALSE
FROM products p
JOIN (VALUES
    ('Single Scoop', 70),
    ('Double Scoop', 120),
    ('Tub', 320)
) v(variant_name, price)
ON TRUE
WHERE p.name IN (
    'American Nuts',
    'Chocolate Brownie',
    'Fruit Blast',
    'Lajwab Gulkand',
    'Fruit Cocktail',
    'Paan',
    'Chappan Bhog',
    'Fruit Punch'
)
ON CONFLICT DO NOTHING;


UPDATE product_variants
SET price = CASE variant_name
    WHEN 'Single Scoop' THEN 40
    WHEN 'Double Scoop' THEN 70
    WHEN 'Tub' THEN 200
END
WHERE product_id = (
    SELECT product_id FROM products WHERE name = 'Vanilla'
);
