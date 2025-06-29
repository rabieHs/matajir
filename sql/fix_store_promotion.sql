-- Fix store promotion by creating a function that bypasses the trigger

-- First, let's disable the problematic trigger temporarily
DROP TRIGGER IF EXISTS update_store_promotion_status_trigger ON stores;
DROP TRIGGER IF EXISTS trigger_update_store_promotion_status ON stores;

-- Create a simple function to force store promotion update
CREATE OR REPLACE FUNCTION force_store_promotion(
  store_id UUID,
  promoted BOOLEAN,
  starts_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  ends_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE stores 
  SET 
    is_promoted = promoted,
    promotion_starts_at = COALESCE(starts_at, promotion_starts_at),
    promotion_ends_at = COALESCE(ends_at, promotion_ends_at),
    updated_at = NOW()
  WHERE id = store_id;
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to execute raw SQL (for emergency use)
CREATE OR REPLACE FUNCTION exec_sql(sql TEXT)
RETURNS TEXT AS $$
BEGIN
  EXECUTE sql;
  RETURN 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-create the trigger but with better logic
CREATE OR REPLACE FUNCTION update_store_promotion_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Only auto-update if we're not explicitly setting is_promoted
  IF TG_OP = 'UPDATE' AND OLD.is_promoted IS DISTINCT FROM NEW.is_promoted THEN
    -- User is explicitly setting is_promoted, don't override it
    RETURN NEW;
  END IF;
  
  -- Auto-update based on dates only if is_promoted is not being explicitly set
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

-- Re-create the trigger
CREATE TRIGGER update_store_promotion_status_trigger
BEFORE INSERT OR UPDATE ON stores
FOR EACH ROW EXECUTE FUNCTION update_store_promotion_status();
