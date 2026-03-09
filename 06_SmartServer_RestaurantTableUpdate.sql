-- 1️⃣ Add user_id column
ALTER TABLE restaurant_tables
ADD COLUMN IF NOT EXISTS user_id INT NULL;

-- Add FK constraint
ALTER TABLE restaurant_tables
ADD CONSTRAINT fk_restaurant_tables_user
FOREIGN KEY (user_id)
REFERENCES users(Id)
ON DELETE CASCADE;

------------------------------------------------------

-- 2️⃣ Add status column
ALTER TABLE restaurant_tables
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'AVAILABLE';

------------------------------------------------------

-- 3️⃣ Add updated_at column
ALTER TABLE restaurant_tables
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

------------------------------------------------------

-- 4️⃣ Drop old index
DROP INDEX IF EXISTS idx_tables_tenant;

------------------------------------------------------

-- 5️⃣ Create new composite index
CREATE INDEX IF NOT EXISTS idx_tables_tenant_user
ON restaurant_tables(tenant_id, user_id);

------------------------------------------------------

-- 6️⃣ Add unique constraint
ALTER TABLE restaurant_tables
ADD CONSTRAINT uq_restaurant_tables
UNIQUE (tenant_id, user_id, display_name);