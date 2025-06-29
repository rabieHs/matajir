-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name JSONB NOT NULL DEFAULT '{"en": "Unknown"}',
  parent_id UUID REFERENCES categories(id),
  image_url TEXT,
  grid_size INTEGER DEFAULT 1,
  gradient_start_color TEXT,
  gradient_end_color TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create store_categories junction table
CREATE TABLE IF NOT EXISTS store_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(store_id, category_id)
);

-- Sample categories data
INSERT INTO categories (id, name, parent_id, image_url, grid_size, gradient_start_color, gradient_end_color, is_active)
VALUES 
  -- Main categories
  ('11111111-1111-1111-1111-111111111111', '{"en": "Clothing", "ar": "ملابس", "fr": "Vêtements"}', NULL, 'https://images.unsplash.com/photo-1483985988355-763728e1935b', 2, '#9C27B0', '#673AB7', TRUE),
  ('22222222-2222-2222-2222-222222222222', '{"en": "Footwear", "ar": "أحذية", "fr": "Chaussures"}', NULL, 'https://images.unsplash.com/photo-1549298916-b41d501d3772', 1, '#F44336', '#E91E63', TRUE),
  ('33333333-3333-3333-3333-333333333333', '{"en": "Accessories", "ar": "إكسسوارات", "fr": "Accessoires"}', NULL, 'https://images.unsplash.com/photo-1611085583191-a3b181a88401', 1, '#3F51B5', '#2196F3', TRUE),
  ('44444444-4444-4444-4444-444444444444', '{"en": "Electronics", "ar": "إلكترونيات", "fr": "Électronique"}', NULL, 'https://images.unsplash.com/photo-1498049794561-7780e7231661', 1, '#FF9800', '#FF5722', TRUE),
  ('55555555-5555-5555-5555-555555555555', '{"en": "Home & Kitchen", "ar": "المنزل والمطبخ", "fr": "Maison et Cuisine"}', NULL, 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7', 3, '#795548', '#607D8B', TRUE),
  
  -- Subcategories for Clothing
  ('11111111-1111-1111-1111-aaaaaaaaaaaa', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', '11111111-1111-1111-1111-111111111111', NULL, 1, NULL, NULL, TRUE),
  ('11111111-1111-1111-1111-bbbbbbbbbbbb', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', '11111111-1111-1111-1111-111111111111', NULL, 1, NULL, NULL, TRUE),
  ('11111111-1111-1111-1111-cccccccccccc', '{"en": "Children", "ar": "أطفال", "fr": "Enfants"}', '11111111-1111-1111-1111-111111111111', NULL, 1, NULL, NULL, TRUE),
  
  -- Subcategories for Footwear
  ('22222222-2222-2222-2222-aaaaaaaaaaaa', '{"en": "Men's Shoes", "ar": "أحذية رجالية", "fr": "Chaussures pour hommes"}', '22222222-2222-2222-2222-222222222222', NULL, 1, NULL, NULL, TRUE),
  ('22222222-2222-2222-2222-bbbbbbbbbbbb', '{"en": "Women's Shoes", "ar": "أحذية نسائية", "fr": "Chaussures pour femmes"}', '22222222-2222-2222-2222-222222222222', NULL, 1, NULL, NULL, TRUE),
  ('22222222-2222-2222-2222-cccccccccccc', '{"en": "Sports Shoes", "ar": "أحذية رياضية", "fr": "Chaussures de sport"}', '22222222-2222-2222-2222-222222222222', NULL, 1, NULL, NULL, TRUE),
  
  -- Subcategories for Accessories
  ('33333333-3333-3333-3333-aaaaaaaaaaaa', '{"en": "Watches", "ar": "ساعات", "fr": "Montres"}', '33333333-3333-3333-3333-333333333333', NULL, 1, NULL, NULL, TRUE),
  ('33333333-3333-3333-3333-bbbbbbbbbbbb', '{"en": "Jewelry", "ar": "مجوهرات", "fr": "Bijoux"}', '33333333-3333-3333-3333-333333333333', NULL, 1, NULL, NULL, TRUE),
  ('33333333-3333-3333-3333-cccccccccccc', '{"en": "Bags", "ar": "حقائب", "fr": "Sacs"}', '33333333-3333-3333-3333-333333333333', NULL, 1, NULL, NULL, TRUE),
  
  -- Subcategories for Electronics
  ('44444444-4444-4444-4444-aaaaaaaaaaaa', '{"en": "Smartphones", "ar": "هواتف ذكية", "fr": "Smartphones"}', '44444444-4444-4444-4444-444444444444', NULL, 1, NULL, NULL, TRUE),
  ('44444444-4444-4444-4444-bbbbbbbbbbbb', '{"en": "Laptops", "ar": "أجهزة الكمبيوتر المحمولة", "fr": "Ordinateurs portables"}', '44444444-4444-4444-4444-444444444444', NULL, 1, NULL, NULL, TRUE),
  ('44444444-4444-4444-4444-cccccccccccc', '{"en": "Audio", "ar": "صوتيات", "fr": "Audio"}', '44444444-4444-4444-4444-444444444444', NULL, 1, NULL, NULL, TRUE),
  
  -- Subcategories for Home & Kitchen
  ('55555555-5555-5555-5555-aaaaaaaaaaaa', '{"en": "Furniture", "ar": "أثاث", "fr": "Meubles"}', '55555555-5555-5555-5555-555555555555', NULL, 1, NULL, NULL, TRUE),
  ('55555555-5555-5555-5555-bbbbbbbbbbbb', '{"en": "Kitchen Appliances", "ar": "أجهزة المطبخ", "fr": "Appareils de cuisine"}', '55555555-5555-5555-5555-555555555555', NULL, 1, NULL, NULL, TRUE),
  ('55555555-5555-5555-5555-cccccccccccc', '{"en": "Home Decor", "ar": "ديكور المنزل", "fr": "Décoration de lintérieur"}', '55555555-5555-5555-5555-555555555555', NULL, 1, NULL, NULL, TRUE);
