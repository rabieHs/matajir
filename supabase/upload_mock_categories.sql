-- Script to upload all mock categories and subcategories to Supabase

-- Main Categories
INSERT INTO categories (id, name, photo_url, grid_size, gradient_start_color, gradient_end_color, is_active, created_at, updated_at)
VALUES
  ('1', '{"en": "Clothing", "ar": "ملابس", "fr": "Vêtements"}', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', 2, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('2', '{"en": "Footwear", "ar": "أحذية", "fr": "Chaussures"}', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1112&q=80', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('3', '{"en": "Accessories", "ar": "إكسسوارات", "fr": "Accessoires"}', 'https://images.unsplash.com/photo-1611085583191-a3b181a88401?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80', 1, '#3F51B5', '#2196F3', true, NOW(), NOW()),
  ('4', '{"en": "Personal Care & Beauty", "ar": "العناية الشخصية والجمال", "fr": "Soins personnels et beauté"}', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=880&q=80', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('5', '{"en": "Electronics & Technology", "ar": "الإلكترونيات والتكنولوجيا", "fr": "Électronique et technologie"}', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', 1, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('6', '{"en": "Mother & Child", "ar": "الأم والطفل", "fr": "Mère et enfant"}', 'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1498&q=80', 2, '#795548', '#607D8B', true, NOW(), NOW()),
  ('7', '{"en": "Special Needs", "ar": "احتياجات خاصة", "fr": "Besoins spéciaux"}', 'https://images.unsplash.com/photo-1626271763156-520913751759?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('8', '{"en": "Home & Kitchen", "ar": "المنزل والمطبخ", "fr": "Maison et cuisine"}', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=958&q=80', 3, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('9', '{"en": "Sports & Fitness", "ar": "الرياضة واللياقة البدنية", "fr": "Sports et fitness"}', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('10', '{"en": "Pets", "ar": "الحيوانات الأليفة", "fr": "Animaux de compagnie"}', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1064&q=80', 1, '#3F51B5', '#2196F3', true, NOW(), NOW()),
  ('11', '{"en": "Supermarket", "ar": "سوبر ماركت", "fr": "Supermarché"}', 'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('12', '{"en": "Books & Hobbies", "ar": "الكتب والهوايات", "fr": "Livres et loisirs"}', 'https://images.unsplash.com/photo-1526243741027-444d633d7365?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1171&q=80', 1, '#795548', '#607D8B', true, NOW(), NOW()),
  ('13', '{"en": "Services", "ar": "خدمات", "fr": "Services"}', 'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1169&q=80', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('14', '{"en": "Incense & Arabic Perfumes", "ar": "البخور والعطور العربية", "fr": "Encens et parfums arabes"}', 'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80', 1, '#F44336', '#E91E63', true, NOW(), NOW());

-- Subcategories
INSERT INTO categories (id, name, parent_id, photo_url, grid_size, is_active, created_at, updated_at)
VALUES
  -- Clothing subcategories
  ('101', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', '1', 'https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('102', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', '1', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('103', '{"en": "Children", "ar": "أطفال", "fr": "Enfants"}', '1', 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Footwear subcategories
  ('201', '{"en": "Men\'s Shoes", "ar": "أحذية رجالية", "fr": "Chaussures pour hommes"}', '2', 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('202', '{"en": "Women\'s Shoes", "ar": "أحذية نسائية", "fr": "Chaussures pour femmes"}', '2', 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Accessories subcategories
  ('301', '{"en": "Watches", "ar": "ساعات", "fr": "Montres"}', '3', 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('302', '{"en": "Jewelry", "ar": "مجوهرات", "fr": "Bijoux"}', '3', 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Electronics & Technology subcategories
  ('501', '{"en": "Smartphones", "ar": "الهواتف الذكية", "fr": "Smartphones"}', '5', 'https://images.unsplash.com/photo-1546054454-aa26e2b734c7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('502', '{"en": "Computers & Laptops", "ar": "أجهزة الكمبيوتر والكمبيوتر المحمول", "fr": "Ordinateurs et portables"}', '5', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('503', '{"en": "TVs & Home Entertainment", "ar": "التلفزيونات والترفيه المنزلي", "fr": "Téléviseurs et divertissement à domicile"}', '5', 'https://images.unsplash.com/photo-1588508065123-287b28e013da?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Home & Kitchen subcategories
  ('801', '{"en": "Furniture", "ar": "أثاث", "fr": "Meubles"}', '8', 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('802', '{"en": "Kitchen Appliances", "ar": "أجهزة المطبخ", "fr": "Appareils de cuisine"}', '8', 'https://images.unsplash.com/photo-1556911220-bda9f7f7597e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('803', '{"en": "Home Decor", "ar": "ديكور المنزل", "fr": "Décoration intérieure"}', '8', 'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Sports & Fitness subcategories
  ('901', '{"en": "Sportswear", "ar": "ملابس رياضية", "fr": "Vêtements de sport"}', '9', 'https://images.unsplash.com/photo-1483721310020-03333e577078?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('902', '{"en": "Fitness Equipment", "ar": "معدات اللياقة البدنية", "fr": "Équipement de fitness"}', '9', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW());

-- ON CONFLICT DO NOTHING is added to prevent errors if the categories already exist
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  photo_url = EXCLUDED.photo_url,
  grid_size = EXCLUDED.grid_size,
  gradient_start_color = EXCLUDED.gradient_start_color,
  gradient_end_color = EXCLUDED.gradient_end_color,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();
