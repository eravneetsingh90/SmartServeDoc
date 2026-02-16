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

INSERT INTO tenants 
(
    name,
    subdomain,
    order_counter,
    is_active
)
VALUES
(
    'Scoop Ice Cream Cafe',
    'scoopjandpur',
    1,
    TRUE
);

--admin 1234, user 1111
INSERT INTO users
(
    tenant_id,
    name,
    role_id,
    pin_hash,
    is_active
)
SELECT
    t.id,
    'admin',
    r.id,
    'A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=',
    TRUE
FROM tenants t
JOIN roles r ON LOWER(r.role_name) = 'owner'
WHERE t.subdomain = 'scoopjandpur';

INSERT INTO users
(
    tenant_id,
    name,
    role_id,
    pin_hash,
    is_active
)
SELECT
    t.id,
    'user',
    r.id,
    'A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=',
    TRUE
FROM tenants t
JOIN roles r ON LOWER(r.role_name) = 'kitchen'
WHERE t.subdomain = 'scoopjandpur';



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
SELECT 'Vanilla', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Strawberry', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Mix Fruit', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Cherry Berry', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Butter Scotch', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Alphonso Mango', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chocolate', id FROM categories WHERE name='Ice Cream Scoops'
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT 'Black Currant', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Swiss Cake', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Bubble Gum', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chocolate Chips', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Cookie Cream', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Kaju Draksh', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Pineapple', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Coffee', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Almond Carnival', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Blue Berry', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Malai Rabri', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Kesar Pista', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Rajbhog', id FROM categories WHERE name='Ice Cream Scoops'
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT 'American Nuts', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chocolate Brownie', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Fruit Blast', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Lajwab Gulkand', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Fruit Cocktail', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Paan', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Chappan Bhog', id FROM categories WHERE name='Ice Cream Scoops'
UNION ALL
SELECT 'Fruit Punch', id FROM categories WHERE name='Ice Cream Scoops'
ON CONFLICT DO NOTHING;


INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.id, v.variant_name, v.price
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

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.id, v.variant_name, v.price
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


INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.id, v.variant_name, v.price
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
    SELECT id FROM products WHERE name = 'Vanilla'
);


INSERT INTO products (name, category_id)
SELECT 'Scoop Cake', Id
FROM categories
WHERE name = 'Ice Cream Cake'
ON CONFLICT DO NOTHING;

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, v.variant_name, v.price
FROM products p
JOIN (VALUES
    ('Oreo Ice Cream Cake', 150),
    ('Chocolate Ice Cream Cake', 150),
    ('Strawberry Ice Cream Cake', 150),
    ('Mix Fruit Ice Cream Cake', 150)
) v(variant_name, price)
ON TRUE
WHERE p.name = 'Scoop Cake'
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT 'Waffle Sundae', Id
FROM categories
WHERE name = 'Waffle'
ON CONFLICT DO NOTHING;

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, v.variant_name, v.price
FROM products p
JOIN (VALUES
    ('Milk Chocolate Waffle Sundae', 70),
    ('Dark Chocolate Waffle Sundae', 80),
    ('Oreo Waffle Sundae', 80),
    ('Kit-Kat Waffle Sundae', 90),
    ('Red Velvet Waffle Sundae', 90),
    ('Nutella Waffle Sundae', 100),
    ('Strawberry Waffle Sundae', 100),
    ('Blueberry Waffle Sundae', 100),
    ('Kit-Kat Nutella Mix Waffle Sundae', 120)
) v(variant_name, price)
ON TRUE
WHERE p.name = 'Waffle Sundae'
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT v.name, c.Id
FROM categories c
JOIN (VALUES
    ('Oreo Tawa Ice Cream'),
    ('5 Star Tawa Ice Cream'),
    ('Kit-kat Tawa Ice Cream'),
    ('Chocolate Tawa Ice Cream'),
    ('Snickers Tawa Ice Cream'),
    ('Paan Tawa Ice Cream'),
    ('Mango Tawa Ice Cream'),
    ('Rabri Tawa Ice Cream'),
    ('Strawberry Tawa Ice Cream'),
    ('Nutella Tawa Ice Cream'),
    ('Mix Fruit Tawa Ice Cream')
) v(name) ON TRUE
WHERE c.name = 'Tawa Ice Cream'
ON CONFLICT DO NOTHING;

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, 'Regular', v.price
FROM products p
JOIN (VALUES
    ('Oreo Tawa Ice Cream', 100),
    ('5 Star Tawa Ice Cream', 100),
    ('Kit-kat Tawa Ice Cream', 120),
    ('Chocolate Tawa Ice Cream', 120),
    ('Snickers Tawa Ice Cream', 120),
    ('Paan Tawa Ice Cream', 120),
    ('Mango Tawa Ice Cream', 120),
    ('Rabri Tawa Ice Cream', 120),
    ('Strawberry Tawa Ice Cream', 120),
    ('Nutella Tawa Ice Cream', 140),
    ('Mix Fruit Tawa Ice Cream', 140)
) v(product_name, price)
    ON p.name = v.product_name
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT v.name, c.Id
FROM categories c
JOIN (VALUES
    ('Hot Brownie Fudge'),
    ('Oreo Overloaded'),
    ('Sprinkleberry'),
    ('Delicious Dirt'),
    ('Mud Pie Mojo'),
    ('Strawberry Sundae'),
    ('Brownie Cake Remix'),
    ('Coffee Lovers Only'),
    ('Chocolate Devotion'),
    ('Cookie Overloaded'),
    ('Nutella Mix Sundae'),
    ('Berry Berry Good'),
    ('Fruit Punch Sundae')
) v(name) ON TRUE
WHERE c.name = 'Sundae Ice Cream'
ON CONFLICT DO NOTHING;


INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, v.variant_name, v.price
FROM products p
JOIN (VALUES
    ('Hot Brownie Fudge', 'Small', 79),
    ('Hot Brownie Fudge', 'Large', 140),

    ('Oreo Overloaded', 'Small', 100),
    ('Oreo Overloaded', 'Large', 140),

    ('Sprinkleberry', 'Small', 100),
    ('Sprinkleberry', 'Large', 140),

    ('Delicious Dirt', 'Small', 100),
    ('Delicious Dirt', 'Large', 140),

    ('Mud Pie Mojo', 'Small', 120),
    ('Mud Pie Mojo', 'Large', 150),

    ('Strawberry Sundae', 'Small', 120),
    ('Strawberry Sundae', 'Large', 150),

    ('Brownie Cake Remix', 'Small', 120),
    ('Brownie Cake Remix', 'Large', 150),

    ('Coffee Lovers Only', 'Small', 120),
    ('Coffee Lovers Only', 'Large', 150),

    ('Chocolate Devotion', 'Small', 120),
    ('Chocolate Devotion', 'Large', 150),

    ('Cookie Overloaded', 'Small', 120),
    ('Cookie Overloaded', 'Large', 150),

    ('Nutella Mix Sundae', 'Small', 120),
    ('Nutella Mix Sundae', 'Large', 150),

    ('Berry Berry Good', 'Small', 120),
    ('Berry Berry Good', 'Large', 150),

    ('Fruit Punch Sundae', 'Small', 120),
    ('Fruit Punch Sundae', 'Large', 160)
) v(product_name, variant_name, price)
    ON p.name = v.product_name
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT v.name, c.Id
FROM categories c
JOIN (VALUES
    ('Milk Chocolate Waffle'),
    ('Dark Chocolate Waffle'),
    ('White Chocolate Waffle'),
    ('Triple Chocolate Waffle'),
    ('Oreo Waffle'),
    ('Kit-Kat Waffle'),
    ('Nutella Waffle'),
    ('Kit-Kat Nutella Mix Waffle'),
    ('Strawberry Waffle'),
    ('Blueberry Waffle'),
    ('Red Velvet Waffle')
) v(name) ON TRUE
WHERE c.name = 'Waffle'
ON CONFLICT DO NOTHING;
INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, 'Belgian Waffle', v.price
FROM products p
JOIN (VALUES
    ('Milk Chocolate Waffle', 120),
    ('Dark Chocolate Waffle', 120),
    ('White Chocolate Waffle', 120),
    ('Triple Chocolate Waffle', 140),
    ('Oreo Waffle', 140),
    ('Kit-Kat Waffle', 140),
    ('Nutella Waffle', 150),
    ('Kit-Kat Nutella Mix Waffle', 160),
    ('Strawberry Waffle', 140),
    ('Blueberry Waffle', 140),
    ('Red Velvet Waffle', 140)
) v(product_name, price)
    ON p.name = v.product_name
ON CONFLICT DO NOTHING;

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, 'Waffle Sundae', v.price
FROM products p
JOIN (VALUES
    ('Milk Chocolate Waffle', 70),
    ('Dark Chocolate Waffle', 80),
    ('Oreo Waffle', 80),
    ('Kit-Kat Waffle', 90),
    ('Red Velvet Waffle', 90),
    ('Nutella Waffle', 100),
    ('Strawberry Waffle', 100),
    ('Blueberry Waffle', 100),
    ('Kit-Kat Nutella Mix Waffle', 120)
) v(product_name, price)
    ON p.name = v.product_name
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category_id)
SELECT v.name, c.Id
FROM categories c
JOIN (VALUES
    ('Aloo Tikki Burger'),
    ('Hot N Spicy Veg Burger'),
    ('Veg Tandoori Burger'),
    ('Veg Makhani Burst Burger'),
    ('Cheese Burst Veg Burger')
) v(name) ON TRUE
WHERE c.name = 'Burger'
ON CONFLICT DO NOTHING;

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, v.variant_name, v.price
FROM products p
JOIN (VALUES
    ('Aloo Tikki Burger', 'Burger', 50),
    ('Aloo Tikki Burger', 'Meal', 100),

    ('Hot N Spicy Veg Burger', 'Burger', 70),
    ('Hot N Spicy Veg Burger', 'Meal', 150),

    ('Veg Tandoori Burger', 'Burger', 80),
    ('Veg Tandoori Burger', 'Meal', 160),

    ('Veg Makhani Burst Burger', 'Burger', 90),
    ('Veg Makhani Burst Burger', 'Meal', 170),

    ('Cheese Burst Veg Burger', 'Burger', 100),
    ('Cheese Burst Veg Burger', 'Meal', 180)
) v(product_name, variant_name, price)
    ON p.name = v.product_name
ON CONFLICT DO NOTHING;


INSERT INTO products (name, category_id, food_type)
SELECT v.name, c.Id, 'NON_VEG'
FROM categories c
JOIN (VALUES
    ('Crispy Chicken Burger'),
    ('Hot N Spicy Chicken Burger'),
    ('Chicken Tandoori Burger'),
    ('Chicken Makhani Burst Burger'),
    ('Cheese Burst Chicken Burger')
) v(name) ON TRUE
WHERE c.name = 'Burger'
ON CONFLICT DO NOTHING;

INSERT INTO product_variants (product_id, variant_name, price)
SELECT p.Id, v.variant_name, v.price
FROM products p
JOIN (VALUES
    ('Crispy Chicken Burger', 'Burger', 70),
    ('Crispy Chicken Burger', 'Meal', 150),

    ('Hot N Spicy Chicken Burger', 'Burger', 90),
    ('Hot N Spicy Chicken Burger', 'Meal', 170),

    ('Chicken Tandoori Burger', 'Burger', 100),
    ('Chicken Tandoori Burger', 'Meal', 180),

    ('Chicken Makhani Burst Burger', 'Burger', 110),
    ('Chicken Makhani Burst Burger', 'Meal', 190),

    ('Cheese Burst Chicken Burger', 'Burger', 120),
    ('Cheese Burst Chicken Burger', 'Meal', 200)
) v(product_name, variant_name, price)
    ON p.name = v.product_name
ON CONFLICT DO NOTHING;


