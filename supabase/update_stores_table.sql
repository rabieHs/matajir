-- Update stores table to add promotion fields
ALTER TABLE stores ADD COLUMN IF NOT EXISTS is_promoted BOOLEAN DEFAULT FALSE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_starts_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_ends_at TIMESTAMP WITH TIME ZONE;

-- Create a function to automatically update the is_promoted field based on dates
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

-- Create a trigger to automatically update the is_promoted field
CREATE TRIGGER update_store_promotion_status_trigger
BEFORE INSERT OR UPDATE ON stores
FOR EACH ROW EXECUTE FUNCTION update_store_promotion_status();

-- Create a scheduled function to update promotion status daily
CREATE OR REPLACE FUNCTION update_all_store_promotions()
RETURNS void AS $$
BEGIN
  -- Update stores where promotion has ended
  UPDATE stores
  SET is_promoted = FALSE
  WHERE is_promoted = TRUE 
    AND (promotion_ends_at IS NULL OR promotion_ends_at < NOW());
  
  -- Update stores where promotion has started
  UPDATE stores
  SET is_promoted = TRUE
  WHERE is_promoted = FALSE 
    AND promotion_starts_at IS NOT NULL 
    AND promotion_ends_at IS NOT NULL
    AND NOW() BETWEEN promotion_starts_at AND promotion_ends_at;
END;
$$ LANGUAGE plpgsql;
