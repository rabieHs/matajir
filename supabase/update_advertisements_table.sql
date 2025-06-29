-- Update advertisements table to add location field
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS location TEXT DEFAULT 'home';

-- Create a new table for ad-category associations
CREATE TABLE IF NOT EXISTS advertisement_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  advertisement_id UUID REFERENCES advertisements(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(advertisement_id, category_id)
);

-- Create policies for advertisement_categories
CREATE POLICY "Anyone can view advertisement categories"
  ON advertisement_categories FOR SELECT
  USING (true);

CREATE POLICY "Users can manage their own advertisement categories"
  ON advertisement_categories FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM advertisements a
      WHERE a.id = advertisement_id AND a.user_id = auth.uid()
    )
  );

-- Delete existing advertisements (if any)
DELETE FROM advertisements;

-- Insert home page advertisements
INSERT INTO advertisements (id, user_id, name, image_url, click_url, starts_at, ends_at, is_active, location)
VALUES
  ('ad111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'Summer Sale', 'https://images.unsplash.com/photo-1607083206968-13611e3d76db?q=80&w=1000&auto=format&fit=crop', 'https://example.com/summer-sale', NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', true, 'home'),
  ('ad222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'New Collection', 'https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?q=80&w=1000&auto=format&fit=crop', 'https://example.com/new-collection', NOW() - INTERVAL '2 days', NOW() + INTERVAL '30 days', true, 'home'),
  ('ad333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'Special Offer', 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000&auto=format&fit=crop', 'https://example.com/special-offer', NOW() - INTERVAL '3 days', NOW() + INTERVAL '30 days', true, 'home');

-- Insert category-specific advertisements
-- Clothing category
INSERT INTO advertisements (id, user_id, name, image_url, click_url, starts_at, ends_at, is_active, location)
VALUES
  ('ad444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'Fashion Week', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 'https://example.com/fashion-week', NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', true, 'category');

-- Electronics category
INSERT INTO advertisements (id, user_id, name, image_url, click_url, starts_at, ends_at, is_active, location)
VALUES
  ('ad555555-5555-5555-5555-555555555555', '00000000-0000-0000-0000-000000000000', 'Tech Sale', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=1000&auto=format&fit=crop', 'https://example.com/tech-sale', NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', true, 'category');

-- Home & Kitchen category
INSERT INTO advertisements (id, user_id, name, image_url, click_url, starts_at, ends_at, is_active, location)
VALUES
  ('ad666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-000000000000', 'Home Decor', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=1000&auto=format&fit=crop', 'https://example.com/home-decor', NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', true, 'category');

-- Now let's create a function to associate ads with categories
CREATE OR REPLACE FUNCTION associate_ad_with_category(ad_id UUID, cat_id UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO advertisement_categories (advertisement_id, category_id)
  VALUES (ad_id, cat_id);
END;
$$ LANGUAGE plpgsql;

-- Associate ads with categories
-- Note: These UUIDs match the ones we defined in upload_categories_part1_fixed.sql

-- For Clothing category
SELECT associate_ad_with_category(
  'ad444444-4444-4444-4444-444444444444',
  '11111111-1111-1111-1111-111111111111'
);

-- For Electronics category
SELECT associate_ad_with_category(
  'ad555555-5555-5555-5555-555555555555',
  '55555555-5555-5555-5555-555555555555'
);

-- For Home & Kitchen category
SELECT associate_ad_with_category(
  'ad666666-6666-6666-6666-666666666666',
  '88888888-8888-8888-8888-888888888888'
);

-- For subcategories
-- Men's clothing subcategory
SELECT associate_ad_with_category(
  'ad444444-4444-4444-4444-444444444444',
  '11111111-1111-1111-1111-111111111101'
);

-- Women's clothing subcategory
SELECT associate_ad_with_category(
  'ad444444-4444-4444-4444-444444444444',
  '11111111-1111-1111-1111-111111111102'
);
