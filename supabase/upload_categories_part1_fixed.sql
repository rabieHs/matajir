-- Script to upload categories and subcategories to Supabase (Part 1)

-- First, make sure the categories table exists and UUID extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY,
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
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  photo_url = EXCLUDED.photo_url,
  grid_size = EXCLUDED.grid_size,
  gradient_start_color = EXCLUDED.gradient_start_color,
  gradient_end_color = EXCLUDED.gradient_end_color,
  is_active = EXCLUDED.is_active,
  updated_at = NOW()
VALUES
  ('11111111-1111-1111-1111-111111111111', '{"en": "Clothing", "ar": "الملابس", "fr": "Vêtements"}', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 2, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', '{"en": "Footwear", "ar": "الأحذية", "fr": "Chaussures"}', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333333', '{"en": "Accessories", "ar": "الإكسسوارات", "fr": "Accessoires"}', 'https://images.unsplash.com/photo-1611085583191-a3b181a88401?q=80&w=1000&auto=format&fit=crop', 1, '#3F51B5', '#2196F3', true, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444444', '{"en": "Personal Care & Beauty", "ar": "العناية الشخصية والجمال", "fr": "Soins personnels et beauté"}', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=1000&auto=format&fit=crop', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555555', '{"en": "Electronics & Technology", "ar": "الأجهزة والتقنية", "fr": "Électronique et technologie"}', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=1000&auto=format&fit=crop', 1, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', '{"en": "Mother & Child", "ar": "الأم والطفل", "fr": "Mère et enfant"}', 'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?q=80&w=1000&auto=format&fit=crop', 2, '#795548', '#607D8B', true, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777777', '{"en": "Special Needs", "ar": "ذوي الاحتياجات الخاصة", "fr": "Besoins spéciaux"}', 'https://images.unsplash.com/photo-1626271763156-520913751759?q=80&w=1000&auto=format&fit=crop', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888888', '{"en": "Home & Kitchen", "ar": "المنزل والمطبخ", "fr": "Maison et cuisine"}', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=1000&auto=format&fit=crop', 3, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('99999999-9999-9999-9999-999999999999', '{"en": "Sports & Fitness", "ar": "الرياضة واللياقة", "fr": "Sports et fitness"}', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '{"en": "Pets", "ar": "الحيوانات الأليفة", "fr": "Animaux de compagnie"}', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000&auto=format&fit=crop', 1, '#3F51B5', '#2196F3', true, NOW(), NOW());

-- Subcategories for Part 1
INSERT INTO categories (id, name, parent_id, photo_url, grid_size, is_active, created_at, updated_at)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  photo_url = EXCLUDED.photo_url,
  grid_size = EXCLUDED.grid_size,
  gradient_start_color = EXCLUDED.gradient_start_color,
  gradient_end_color = EXCLUDED.gradient_end_color,
  is_active = EXCLUDED.is_active,
  updated_at = NOW()
VALUES
  -- Clothing subcategories (11111111-1111-1111-1111-111111111111)
  ('11111111-1111-1111-1111-111111111101', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111102', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111103', '{"en": "Children", "ar": "أطفال", "fr": "Enfants"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111104', '{"en": "Special Needs", "ar": "ذوي الاحتياجات الخاصة", "fr": "Besoins spéciaux"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1626271763156-520913751759?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111105', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Footwear subcategories (22222222-2222-2222-2222-222222222222)
  ('22222222-2222-2222-2222-222222222201', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222202', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222203', '{"en": "Children", "ar": "أطفال", "fr": "Enfants"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1596273312170-8fff4fd408de?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222204', '{"en": "Medical", "ar": "طبية", "fr": "Médical"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1585298723682-7115561c51b7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222205', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Accessories subcategories (33333333-3333-3333-3333-333333333333)
  ('33333333-3333-3333-3333-333333333301', '{"en": "Watches", "ar": "ساعات", "fr": "Montres"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333302', '{"en": "Glasses", "ar": "نظارات", "fr": "Lunettes"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1577803645773-f96470509666?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333303', '{"en": "Bags", "ar": "حقائب", "fr": "Sacs"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333304', '{"en": "Jewelry", "ar": "مجوهرات", "fr": "Bijoux"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333305', '{"en": "Headwear", "ar": "أغطية رأس", "fr": "Couvre-chefs"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1521369909029-2afed882baee?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333306', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Personal Care & Beauty subcategories (44444444-4444-4444-4444-444444444444)
  ('44444444-4444-4444-4444-444444444401', '{"en": "Skin Care", "ar": "العناية بالبشرة", "fr": "Soins de la peau"}', '44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444402', '{"en": "Hair Care", "ar": "العناية بالشعر", "fr": "Soins capillaires"}', '44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444403', '{"en": "Makeup", "ar": "مكياج", "fr": "Maquillage"}', '44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444404', '{"en": "Perfumes", "ar": "عطور", "fr": "Parfums"}', '44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1592945403407-9caf930b2fbe?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444405', '{"en": "Bath Products", "ar": "منتجات استحمام", "fr": "Produits de bain"}', '44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1570213489059-0aac6626cade?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444406', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Electronics & Technology subcategories (55555555-5555-5555-5555-555555555555)
  ('55555555-5555-5555-5555-555555555501', '{"en": "Phones", "ar": "هواتف", "fr": "Téléphones"}', '55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1546054454-aa26e2b734c7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555502', '{"en": "Laptops", "ar": "لابتوبات", "fr": "Ordinateurs portables"}', '55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555503', '{"en": "Tablets", "ar": "أجهزة لوحية", "fr": "Tablettes"}', '55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555504', '{"en": "Tech Accessories", "ar": "ملحقات تقنية", "fr": "Accessoires tech"}', '55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1625480860249-be231688a0e3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555505', '{"en": "Gaming", "ar": "ألعاب إلكترونية", "fr": "Jeux vidéo"}', '55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555506', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Mother & Child subcategories (66666666-6666-6666-6666-666666666666)
  ('66666666-6666-6666-6666-666666666601', '{"en": "Baby Essentials", "ar": "مستلزمات الرضع", "fr": "Essentiels pour bébé"}', '66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666602', '{"en": "Pregnancy", "ar": "الحوامل", "fr": "Grossesse"}', '66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1537365587684-f490dff69498?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666603', '{"en": "Strollers", "ar": "عربات أطفال", "fr": "Poussettes"}', '66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1591147834132-a7c465f2a317?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666604', '{"en": "Car Seats", "ar": "كرسي سيارة", "fr": "Sièges auto"}', '66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1591147834132-a7c465f2a317?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666605', '{"en": "Educational Toys", "ar": "ألعاب تعليمية", "fr": "Jouets éducatifs"}', '66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666606', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Special Needs subcategories (77777777-7777-7777-7777-777777777777)
  ('77777777-7777-7777-7777-777777777701', '{"en": "Medical Devices", "ar": "الأجهزة الطبية", "fr": "Dispositifs médicaux"}', '77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1584515933487-779824d29309?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777702', '{"en": "Specialized Clothing", "ar": "الملابس المخصصة", "fr": "Vêtements spécialisés"}', '77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1626271763156-520913751759?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777703', '{"en": "Assistive Tools", "ar": "الأدوات المساعدة", "fr": "Outils d''assistance"}', '77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1624913503273-5f9c4e980dba?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777704', '{"en": "Assistive Technology", "ar": "التقنيات المساعدة", "fr": "Technologies d''assistance"}', '77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1564466809058-bf4114d55352?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777705', '{"en": "Special Activities", "ar": "الألعاب والأنشطة الخاصة", "fr": "Activités spéciales"}', '77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1560807707-8cc77767d783?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777706', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1599778150146-9dae5d500b88?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Home & Kitchen subcategories (88888888-8888-8888-8888-888888888888)
  ('88888888-8888-8888-8888-888888888801', '{"en": "Furniture", "ar": "أثاث", "fr": "Meubles"}', '88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888802', '{"en": "Home Appliances", "ar": "أجهزة منزلية", "fr": "Appareils ménagers"}', '88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1556911220-bda9f7f7597e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888803', '{"en": "Kitchen Tools", "ar": "أدوات مطبخ", "fr": "Ustensiles de cuisine"}', '88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1590794056226-79ef3a8147e1?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888804', '{"en": "Bedding", "ar": "مفروشات", "fr": "Literie"}', '88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888805', '{"en": "Decor", "ar": "ديكور", "fr": "Décoration"}', '88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888806', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Sports & Fitness subcategories (99999999-9999-9999-9999-999999999999)
  ('99999999-9999-9999-9999-999999999901', '{"en": "Sportswear", "ar": "ملابس رياضية", "fr": "Vêtements de sport"}', '99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1483721310020-03333e577078?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('99999999-9999-9999-9999-999999999902', '{"en": "Sports Equipment", "ar": "معدات رياضية", "fr": "Équipement sportif"}', '99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('99999999-9999-9999-9999-999999999903', '{"en": "Fitness Equipment", "ar": "أجهزة لياقة", "fr": "Équipement de fitness"}', '99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('99999999-9999-9999-9999-999999999904', '{"en": "Supplements", "ar": "مكملات غذائية", "fr": "Compléments alimentaires"}', '99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1579722821273-0f6c1b1d2b10?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('99999999-9999-9999-9999-999999999905', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Pets subcategories (aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa)
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa01', '{"en": "Pet Food", "ar": "أطعمة", "fr": "Nourriture pour animaux"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa02', '{"en": "Pet Toys", "ar": "ألعاب", "fr": "Jouets pour animaux"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa03', '{"en": "Pet Care", "ar": "أدوات عناية", "fr": "Soins pour animaux"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa04', '{"en": "Cages", "ar": "أقفاص", "fr": "Cages"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1560743641-3914f2c45636?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa05', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW());
