-- Update advertisements table to add payment and ad type fields
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS ad_type TEXT DEFAULT 'home_spotlight';
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS is_paid BOOLEAN DEFAULT FALSE;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS payment_status TEXT;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS payment_id UUID;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS country TEXT;

-- Update existing advertisements to have ad_type values
UPDATE advertisements SET ad_type = 'home_spotlight' WHERE location = 'home';
UPDATE advertisements SET ad_type = 'category_match' WHERE location = 'category';
UPDATE advertisements SET ad_type = 'top_store_boost' WHERE location = 'store';

-- Set all existing advertisements as paid
UPDATE advertisements SET is_paid = TRUE WHERE is_active = TRUE;

-- Create index on ad_type for faster lookups
CREATE INDEX IF NOT EXISTS idx_advertisements_ad_type ON advertisements(ad_type);

-- Create index on is_paid for faster lookups
CREATE INDEX IF NOT EXISTS idx_advertisements_is_paid ON advertisements(is_paid);

-- Create index on country for faster lookups
CREATE INDEX IF NOT EXISTS idx_advertisements_country ON advertisements(country);

-- Update stores table to add promotion fields if they don't exist
ALTER TABLE stores ADD COLUMN IF NOT EXISTS is_promoted BOOLEAN DEFAULT FALSE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_starts_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_ends_at TIMESTAMP WITH TIME ZONE;

-- Create index on is_promoted for faster lookups
CREATE INDEX IF NOT EXISTS idx_stores_is_promoted ON stores(is_promoted);

-- Create payments table if it doesn't exist
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  payment_intent_id TEXT NOT NULL,
  amount TEXT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  status TEXT NOT NULL,
  description TEXT,
  advertisement_id UUID REFERENCES advertisements(id) ON DELETE SET NULL,
  store_id UUID REFERENCES stores(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create trigger to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS on payments table
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create policies for payments
CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create index on payment_intent_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_payments_payment_intent_id ON payments(payment_intent_id);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
