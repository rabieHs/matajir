-- Update advertisements table to match the current structure and add missing fields
-- Based on the current table structure shown in the image

-- Add missing fields to advertisements table
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS ad_type TEXT NOT NULL DEFAULT 'home_spotlight';
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS subcategory_id UUID REFERENCES categories(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS store_id UUID REFERENCES stores(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS payment_id UUID REFERENCES payments(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS is_paid BOOLEAN DEFAULT FALSE;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS payment_status TEXT;

-- Update stores table to add promotion fields if they don't exist
ALTER TABLE stores ADD COLUMN IF NOT EXISTS is_promoted BOOLEAN DEFAULT FALSE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_starts_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_ends_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS subcategory_ids TEXT; -- JSON array as text for subcategory IDs

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_advertisements_country ON advertisements(country);
CREATE INDEX IF NOT EXISTS idx_advertisements_ad_type ON advertisements(ad_type);
CREATE INDEX IF NOT EXISTS idx_advertisements_category_id ON advertisements(category_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_subcategory_id ON advertisements(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_store_id ON advertisements(store_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_is_paid ON advertisements(is_paid);
CREATE INDEX IF NOT EXISTS idx_advertisements_payment_status ON advertisements(payment_status);
CREATE INDEX IF NOT EXISTS idx_advertisements_dates ON advertisements(starts_at, ends_at);

CREATE INDEX IF NOT EXISTS idx_stores_is_promoted ON stores(is_promoted);
CREATE INDEX IF NOT EXISTS idx_stores_promotion_dates ON stores(promotion_starts_at, promotion_ends_at);
CREATE INDEX IF NOT EXISTS idx_stores_country ON stores(country);
CREATE INDEX IF NOT EXISTS idx_stores_category_id ON stores(category_id);

-- Update RLS policies for advertisements to include country and category filtering
DROP POLICY IF EXISTS "Anyone can view active advertisements" ON advertisements;
CREATE POLICY "Anyone can view active advertisements"
  ON advertisements FOR SELECT
  USING (
    is_active = TRUE 
    AND is_paid = TRUE 
    AND NOW() BETWEEN starts_at AND ends_at
  );

-- Update RLS policies for stores to include promoted stores
DROP POLICY IF EXISTS "Anyone can view active stores" ON stores;
CREATE POLICY "Anyone can view active stores"
  ON stores FOR SELECT
  USING (is_active = TRUE);

-- Create function to automatically update store promotion status
CREATE OR REPLACE FUNCTION update_store_promotion_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the promotion period is active
  IF NEW.promotion_starts_at IS NOT NULL AND NEW.promotion_ends_at IS NOT NULL THEN
    IF NOW() BETWEEN NEW.promotion_starts_at AND NEW.promotion_ends_at THEN
      NEW.is_promoted := TRUE;
    ELSE
      NEW.is_promoted := FALSE;
    END IF;
  ELSE
    NEW.is_promoted := FALSE;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update store promotion status
DROP TRIGGER IF EXISTS trigger_update_store_promotion_status ON stores;
CREATE TRIGGER trigger_update_store_promotion_status
  BEFORE INSERT OR UPDATE ON stores
  FOR EACH ROW
  EXECUTE FUNCTION update_store_promotion_status();

-- Create function to automatically deactivate expired advertisements
CREATE OR REPLACE FUNCTION update_advertisement_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the advertisement period has ended
  IF NEW.ends_at < NOW() THEN
    NEW.is_active := FALSE;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically deactivate expired advertisements
DROP TRIGGER IF EXISTS trigger_update_advertisement_status ON advertisements;
CREATE TRIGGER trigger_update_advertisement_status
  BEFORE INSERT OR UPDATE ON advertisements
  FOR EACH ROW
  EXECUTE FUNCTION update_advertisement_status();
