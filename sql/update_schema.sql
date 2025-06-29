-- Update the stores table to replace address with keywords
ALTER TABLE stores DROP COLUMN IF EXISTS address;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS keywords TEXT;

-- Update existing stores with sample keywords
UPDATE stores SET keywords = 'fashion clothing apparel style dress shoes' WHERE id = '1';
UPDATE stores SET keywords = 'electronics gadgets tech computers phones' WHERE id = '2';
UPDATE stores SET keywords = 'home furniture decor kitchen appliances' WHERE id = '3';

-- Add an index on the keywords column for faster search
CREATE INDEX IF NOT EXISTS idx_stores_keywords ON stores USING gin (to_tsvector('english', keywords));
