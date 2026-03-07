
INSERT INTO Roles (role_name)
VALUES
('SuperAdmin'),
('Admin'),
('Manager'),
('Cashier');


INSERT INTO tenants
(name, subdomain, plan, timezone, currency, order_counter, is_active)
VALUES
(
    'Scoop Ice Cream Cafe',
    'scoop',
    'premium',
    'Asia/Kolkata',
    'INR',
    1,
    TRUE
);



INSERT INTO users
(tenant_id, name, username, email, role_id, pin_hash, password_hash, last_login_at, is_active)
VALUES
-- Scoop Ice Cream Cafe (Tenant 1)
(1, 'Scoop Admin', 'admin', 'scoopicecreamcafe@gmail.com', 2, 'A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=','A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=', NOW(), TRUE),
(1, 'Scoop Cashier', 'user', null, 4, null,'A6xnQhbz4Vx2HuGl4lXwZ5U2I8iziLRFnhP5eNfIRvQ=', NOW(), TRUE);