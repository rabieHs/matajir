-- Script to upload categories and subcategories to Supabase (Part 1)

-- First, make sure the categories table exists
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name JSONB NOT NULL,
  parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  photo_url TEXT,
  grid_size INTEGER DEFAULT 1,
  gradient_start_color TEXT,
  gradient_end_color TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Main Categories (Part 1)
INSERT INTO categories (id, name, photo_url, grid_size, gradient_start_color, gradient_end_color, is_active, created_at, updated_at)
VALUES
  ('c01', '{"en": "Clothing", "ar": "الملابس", "fr": "Vêtements"}', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 2, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('c02', '{"en": "Footwear", "ar": "الأحذية", "fr": "Chaussures"}', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('c03', '{"en": "Accessories", "ar": "الإكسسوارات", "fr": "Accessoires"}', 'https://images.unsplash.com/photo-1611085583191-a3b181a88401?q=80&w=1000&auto=format&fit=crop', 1, '#3F51B5', '#2196F3', true, NOW(), NOW()),
  ('c04', '{"en": "Personal Care & Beauty", "ar": "العناية الشخصية والجمال", "fr": "Soins personnels et beauté"}', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=1000&auto=format&fit=crop', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('c05', '{"en": "Electronics & Technology", "ar": "الأجهزة والتقنية", "fr": "Électronique et technologie"}', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=1000&auto=format&fit=crop', 1, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('c06', '{"en": "Mother & Child", "ar": "الأم والطفل", "fr": "Mère et enfant"}', 'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?q=80&w=1000&auto=format&fit=crop', 2, '#795548', '#607D8B', true, NOW(), NOW()),
  ('c07', '{"en": "Special Needs", "ar": "ذوي الاحتياجات الخاصة", "fr": "Besoins spéciaux"}', 'https://images.unsplash.com/photo-1626271763156-520913751759?q=80&w=1000&auto=format&fit=crop', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('c08', '{"en": "Home & Kitchen", "ar": "المنزل والمطبخ", "fr": "Maison et cuisine"}', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=1000&auto=format&fit=crop', 3, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('c09', '{"en": "Sports & Fitness", "ar": "الرياضة واللياقة", "fr": "Sports et fitness"}', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('c10', '{"en": "Pets", "ar": "الحيوانات الأليفة", "fr": "Animaux de compagnie"}', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000&auto=format&fit=crop', 1, '#3F51B5', '#2196F3', true, NOW(), NOW());

-- Subcategories for Part 1
INSERT INTO categories (id, name, parent_id, photo_url, grid_size, is_active, created_at, updated_at)
VALUES
  -- Clothing subcategories (c01)
  ('sc0101', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', 'c01', 'https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0102', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', 'c01', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0103', '{"en": "Children", "ar": "أطفال", "fr": "Enfants"}', 'c01', 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0104', '{"en": "Special Needs", "ar": "ذوي الاحتياجات الخاصة", "fr": "Besoins spéciaux"}', 'c01', 'https://images.unsplash.com/photo-1626271763156-520913751759?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0105', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c01', 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Footwear subcategories (c02)
  ('sc0201', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', 'c02', 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0202', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', 'c02', 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0203', '{"en": "Children", "ar": "أطفال", "fr": "Enfants"}', 'c02', 'https://images.unsplash.com/photo-1596273312170-8fff4fd408de?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0204', '{"en": "Medical", "ar": "طبية", "fr": "Médical"}', 'c02', 'https://images.unsplash.com/photo-1585298723682-7115561c51b7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0205', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c02', 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Accessories subcategories (c03)
  ('sc0301', '{"en": "Watches", "ar": "ساعات", "fr": "Montres"}', 'c03', 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0302', '{"en": "Glasses", "ar": "نظارات", "fr": "Lunettes"}', 'c03', 'https://images.unsplash.com/photo-1577803645773-f96470509666?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0303', '{"en": "Bags", "ar": "حقائب", "fr": "Sacs"}', 'c03', 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0304', '{"en": "Jewelry", "ar": "مجوهرات", "fr": "Bijoux"}', 'c03', 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0305', '{"en": "Headwear", "ar": "أغطية رأس", "fr": "Couvre-chefs"}', 'c03', 'https://images.unsplash.com/photo-1521369909029-2afed882baee?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0306', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c03', 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Personal Care & Beauty subcategories (c04)
  ('sc0401', '{"en": "Skin Care", "ar": "العناية بالبشرة", "fr": "Soins de la peau"}', 'c04', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0402', '{"en": "Hair Care", "ar": "العناية بالشعر", "fr": "Soins capillaires"}', 'c04', 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0403', '{"en": "Makeup", "ar": "مكياج", "fr": "Maquillage"}', 'c04', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0404', '{"en": "Perfumes", "ar": "عطور", "fr": "Parfums"}', 'c04', 'https://images.unsplash.com/photo-1592945403407-9caf930b2fbe?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0405', '{"en": "Bath Products", "ar": "منتجات استحمام", "fr": "Produits de bain"}', 'c04', 'https://images.unsplash.com/photo-1570213489059-0aac6626cade?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0406', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c04', 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Electronics & Technology subcategories (c05)
  ('sc0501', '{"en": "Phones", "ar": "هواتف", "fr": "Téléphones"}', 'c05', 'https://images.unsplash.com/photo-1546054454-aa26e2b734c7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0502', '{"en": "Laptops", "ar": "لابتوبات", "fr": "Ordinateurs portables"}', 'c05', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0503', '{"en": "Tablets", "ar": "أجهزة لوحية", "fr": "Tablettes"}', 'c05', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0504', '{"en": "Tech Accessories", "ar": "ملحقات تقنية", "fr": "Accessoires tech"}', 'c05', 'https://images.unsplash.com/photo-1625480860249-be231688a0e3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0505', '{"en": "Gaming", "ar": "ألعاب إلكترونية", "fr": "Jeux vidéo"}', 'c05', 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0506', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c05', 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Mother & Child subcategories (c06)
  ('sc0601', '{"en": "Baby Essentials", "ar": "مستلزمات الرضع", "fr": "Essentiels pour bébé"}', 'c06', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0602', '{"en": "Pregnancy", "ar": "الحوامل", "fr": "Grossesse"}', 'c06', 'https://images.unsplash.com/photo-1537365587684-f490dff69498?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0603', '{"en": "Strollers", "ar": "عربات أطفال", "fr": "Poussettes"}', 'c06', 'https://images.unsplash.com/photo-1591147834132-a7c465f2a317?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0604', '{"en": "Car Seats", "ar": "كرسي سيارة", "fr": "Sièges auto"}', 'c06', 'https://images.unsplash.com/photo-1591147834132-a7c465f2a317?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0605', '{"en": "Educational Toys", "ar": "ألعاب تعليمية", "fr": "Jouets éducatifs"}', 'c06', 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0606', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c06', 'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Special Needs subcategories (c07)
  ('sc0701', '{"en": "Medical Devices", "ar": "الأجهزة الطبية", "fr": "Dispositifs médicaux"}', 'c07', 'https://images.unsplash.com/photo-1584515933487-779824d29309?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0702', '{"en": "Specialized Clothing", "ar": "الملابس المخصصة", "fr": "Vêtements spécialisés"}', 'c07', 'https://images.unsplash.com/photo-1626271763156-520913751759?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0703', '{"en": "Assistive Tools", "ar": "الأدوات المساعدة", "fr": "Outils d''assistance"}', 'c07', 'https://images.unsplash.com/photo-1624913503273-5f9c4e980dba?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0704', '{"en": "Assistive Technology", "ar": "التقنيات المساعدة", "fr": "Technologies d''assistance"}', 'c07', 'https://images.unsplash.com/photo-1564466809058-bf4114d55352?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0705', '{"en": "Special Activities", "ar": "الألعاب والأنشطة الخاصة", "fr": "Activités spéciales"}', 'c07', 'https://images.unsplash.com/photo-1560807707-8cc77767d783?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0706', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c07', 'https://images.unsplash.com/photo-1599778150146-9dae5d500b88?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Home & Kitchen subcategories (c08)
  ('sc0801', '{"en": "Furniture", "ar": "أثاث", "fr": "Meubles"}', 'c08', 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0802', '{"en": "Home Appliances", "ar": "أجهزة منزلية", "fr": "Appareils ménagers"}', 'c08', 'https://images.unsplash.com/photo-1556911220-bda9f7f7597e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0803', '{"en": "Kitchen Tools", "ar": "أدوات مطبخ", "fr": "Ustensiles de cuisine"}', 'c08', 'https://images.unsplash.com/photo-1590794056226-79ef3a8147e1?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0804', '{"en": "Bedding", "ar": "مفروشات", "fr": "Literie"}', 'c08', 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0805', '{"en": "Decor", "ar": "ديكور", "fr": "Décoration"}', 'c08', 'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0806', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c08', 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Sports & Fitness subcategories (c09)
  ('sc0901', '{"en": "Sportswear", "ar": "ملابس رياضية", "fr": "Vêtements de sport"}', 'c09', 'https://images.unsplash.com/photo-1483721310020-03333e577078?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0902', '{"en": "Sports Equipment", "ar": "معدات رياضية", "fr": "Équipement sportif"}', 'c09', 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0903', '{"en": "Fitness Equipment", "ar": "أجهزة لياقة", "fr": "Équipement de fitness"}', 'c09', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0904', '{"en": "Supplements", "ar": "مكملات غذائية", "fr": "Compléments alimentaires"}', 'c09', 'https://images.unsplash.com/photo-1579722821273-0f6c1b1d2b10?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc0905', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c09', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Pets subcategories (c10)
  ('sc1001', '{"en": "Pet Food", "ar": "أطعمة", "fr": "Nourriture pour animaux"}', 'c10', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1002', '{"en": "Pet Toys", "ar": "ألعاب", "fr": "Jouets pour animaux"}', 'c10', 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1003', '{"en": "Pet Care", "ar": "أدوات عناية", "fr": "Soins pour animaux"}', 'c10', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1004', '{"en": "Cages", "ar": "أقفاص", "fr": "Cages"}', 'c10', 'https://images.unsplash.com/photo-1560743641-3914f2c45636?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1005', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c10', 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW());

-- ON CONFLICT DO NOTHING is added to prevent errors if the categories already exist
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  photo_url = EXCLUDED.photo_url,
  grid_size = EXCLUDED.grid_size,
  gradient_start_color = EXCLUDED.gradient_start_color,
  gradient_end_color = EXCLUDED.gradient_end_color,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();
