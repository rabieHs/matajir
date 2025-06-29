-- Create advertisements table if it doesn't exist
CREATE TABLE IF NOT EXISTS advertisements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  image_url TEXT NOT NULL,
  click_url TEXT NOT NULL,
  starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
  ends_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  ad_type TEXT NOT NULL, -- 'home_spotlight', 'category_match', 'top_store_boost'
  category_id UUID REFERENCES categories(id) NULL,
  subcategory_id UUID REFERENCES subcategories(id) NULL,
  store_id UUID REFERENCES stores(id) NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create policies for advertisements
CREATE POLICY "Anyone can view active advertisements"
  ON advertisements FOR SELECT
  USING (is_active = TRUE AND NOW() BETWEEN starts_at AND ends_at);

CREATE POLICY "Users can manage their own advertisements"
  ON advertisements FOR ALL
  USING (auth.uid() = user_id);

-- Insert sample advertisements
INSERT INTO advertisements (user_id, name, image_url, click_url, starts_at, ends_at, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000000', 'Summer Sale', 'https://images.unsplash.com/photo-1607083206968-13611e3d76db?q=80&w=1000&auto=format&fit=crop', 'https://example.com/summer-sale', NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', true),
  ('00000000-0000-0000-0000-000000000000', 'New Collection', 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?q=80&w=1000&auto=format&fit=crop', 'https://example.com/new-collection', NOW() - INTERVAL '2 days', NOW() + INTERVAL '30 days', true),
  ('00000000-0000-0000-0000-000000000000', 'Special Offer', 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000&auto=format&fit=crop', 'https://example.com/special-offer', NOW() - INTERVAL '3 days', NOW() + INTERVAL '30 days', true);

-- Note: Replace '00000000-0000-0000-0000-000000000000' with a valid user ID from your auth.users table
-- You can use the following query to find a valid user ID:
-- SELECT id FROM auth.users LIMIT 1;
