-- Add store reviews and ratings functionality
-- This script adds the necessary tables and fields for store reviews and ratings

-- Add rating fields to stores table
ALTER TABLE stores ADD COLUMN IF NOT EXISTS average_rating DECIMAL(3,2) DEFAULT 0.00;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS total_reviews INTEGER DEFAULT 0;

-- Create store_reviews table
CREATE TABLE IF NOT EXISTS store_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(store_id, user_id) -- One review per user per store
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_store_reviews_store_id ON store_reviews(store_id);
CREATE INDEX IF NOT EXISTS idx_store_reviews_user_id ON store_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_store_reviews_rating ON store_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_store_reviews_created_at ON store_reviews(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_stores_average_rating ON stores(average_rating DESC);

-- Create function to update store rating when reviews are added/updated/deleted
CREATE OR REPLACE FUNCTION update_store_rating()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the store's average rating and total reviews count
    UPDATE stores 
    SET 
        average_rating = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2)
            FROM store_reviews 
            WHERE store_id = COALESCE(NEW.store_id, OLD.store_id) 
            AND is_active = TRUE
        ), 0.00),
        total_reviews = COALESCE((
            SELECT COUNT(*)
            FROM store_reviews 
            WHERE store_id = COALESCE(NEW.store_id, OLD.store_id) 
            AND is_active = TRUE
        ), 0),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.store_id, OLD.store_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update store ratings
DROP TRIGGER IF EXISTS trigger_update_store_rating_on_insert ON store_reviews;
CREATE TRIGGER trigger_update_store_rating_on_insert
    AFTER INSERT ON store_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_store_rating();

DROP TRIGGER IF EXISTS trigger_update_store_rating_on_update ON store_reviews;
CREATE TRIGGER trigger_update_store_rating_on_update
    AFTER UPDATE ON store_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_store_rating();

DROP TRIGGER IF EXISTS trigger_update_store_rating_on_delete ON store_reviews;
CREATE TRIGGER trigger_update_store_rating_on_delete
    AFTER DELETE ON store_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_store_rating();

-- Enable RLS on store_reviews table
ALTER TABLE store_reviews ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for store_reviews
CREATE POLICY "Anyone can view active reviews"
  ON store_reviews FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Users can manage their own reviews"
  ON store_reviews FOR ALL
  USING (auth.uid() = user_id);

-- Create policy for store owners to view all reviews of their stores
CREATE POLICY "Store owners can view reviews of their stores"
  ON store_reviews FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM stores 
      WHERE stores.id = store_reviews.store_id 
      AND stores.owner_id = auth.uid()
    )
  );

-- Insert some sample reviews for testing (optional)
-- You can remove this section if you don't want sample data
/*
INSERT INTO store_reviews (store_id, user_id, rating, review_text) 
SELECT 
    s.id as store_id,
    p.id as user_id,
    (RANDOM() * 4 + 1)::INTEGER as rating,
    CASE 
        WHEN RANDOM() > 0.5 THEN 'Great store with excellent service!'
        ELSE 'Good products and friendly staff.'
    END as review_text
FROM stores s
CROSS JOIN profiles p
WHERE s.is_active = TRUE 
AND p.id != s.owner_id -- Don't let store owners review their own stores
LIMIT 20;
*/
