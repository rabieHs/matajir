-- Add photo_url column to categories table
ALTER TABLE categories ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Update existing main categories with Unsplash images
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1000&auto=format&fit=crop' WHERE id = '11111111-1111-1111-1111-111111111111'; -- Electronics
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?q=80&w=1000&auto=format&fit=crop' WHERE id = '22222222-2222-2222-2222-222222222222'; -- Fashion
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop' WHERE id = '33333333-3333-3333-3333-333333333333'; -- Home & Garden
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1470309864661-68328b2cd0a5?q=80&w=1000&auto=format&fit=crop' WHERE id = '44444444-4444-4444-4444-444444444444'; -- Health & Beauty
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?q=80&w=1000&auto=format&fit=crop' WHERE id = '55555555-5555-5555-5555-555555555555'; -- Sports & Outdoors

-- Update subcategories with Unsplash images (Electronics subcategories)
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1546054454-aa26e2b734c7?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '11111111-1111-1111-1111-111111111111' AND name->>'en' LIKE '%Phone%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '11111111-1111-1111-1111-111111111111' AND name->>'en' LIKE '%Computer%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1588508065123-287b28e013da?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '11111111-1111-1111-1111-111111111111' AND name->>'en' LIKE '%TV%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1585298723682-7115561c51b7?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '11111111-1111-1111-1111-111111111111' AND name->>'en' LIKE '%Camera%';

-- Update subcategories with Unsplash images (Fashion subcategories)
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '22222222-2222-2222-2222-222222222222' AND name->>'en' LIKE '%Men%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '22222222-2222-2222-2222-222222222222' AND name->>'en' LIKE '%Women%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '22222222-2222-2222-2222-222222222222' AND name->>'en' LIKE '%Kid%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1508296695146-257a814070b4?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '22222222-2222-2222-2222-222222222222' AND name->>'en' LIKE '%Jewelry%';

-- Update subcategories with Unsplash images (Home & Garden subcategories)
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '33333333-3333-3333-3333-333333333333' AND name->>'en' LIKE '%Furniture%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1556911220-bda9f7f7597e?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '33333333-3333-3333-3333-333333333333' AND name->>'en' LIKE '%Kitchen%';
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1557429287-b2e26467fc2b?q=80&w=1000&auto=format&fit=crop' WHERE parent_id = '33333333-3333-3333-3333-333333333333' AND name->>'en' LIKE '%Garden%';

-- Default image for any subcategory without a specific image
UPDATE categories SET photo_url = 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1000&auto=format&fit=crop'
WHERE photo_url IS NULL AND parent_id IS NOT NULL;
