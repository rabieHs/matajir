-- Script to upload categories and subcategories to Supabase (Part 2)

-- Main Categories (Part 2)
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
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '{"en": "Supermarket", "ar": "السوبرماركت", "fr": "Supermarché"}', 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '{"en": "Books & Hobbies", "ar": "الكتب والهوايات", "fr": "Livres et loisirs"}', 'https://images.unsplash.com/photo-1526243741027-444d633d7365?q=80&w=1000&auto=format&fit=crop', 1, '#795548', '#607D8B', true, NOW(), NOW()),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '{"en": "Services", "ar": "الخدمات", "fr": "Services"}', 'https://images.unsplash.com/photo-1521791136064-7986c2920216?q=80&w=1000&auto=format&fit=crop', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '{"en": "Incense & Arabic Perfumes", "ar": "البخور والعطورات العربية", "fr": "Encens et parfums arabes"}', 'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('ffffffff-ffff-ffff-ffff-ffffffffffff', '{"en": "Flowers", "ar": "الزهور", "fr": "Fleurs"}', 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=1000&auto=format&fit=crop', 1, '#3F51B5', '#2196F3', true, NOW(), NOW()),
  ('11111111-2222-3333-4444-555555555555', '{"en": "Tools & Supplies", "ar": "العدد ومستلزماتها", "fr": "Outils et fournitures"}', 'https://images.unsplash.com/photo-1581166397057-235af2b3c6dd?q=80&w=1000&auto=format&fit=crop', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('22222222-3333-4444-5555-666666666666', '{"en": "Dates & Accessories", "ar": "التمور وتوابعها", "fr": "Dattes et accessoires"}', 'https://images.unsplash.com/photo-1563252722-6434563a985d?q=80&w=1000&auto=format&fit=crop', 1, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('33333333-4444-5555-6666-777777777777', '{"en": "Hijab", "ar": "المحجبات", "fr": "Hijab"}', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, '#795548', '#607D8B', true, NOW(), NOW()),
  ('44444444-5555-6666-7777-888888888888', '{"en": "Tea & Accessories", "ar": "الشاي ومستلزماته", "fr": "Thé et accessoires"}', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('55555555-6666-7777-8888-999999999999', '{"en": "Coffee & Accessories", "ar": "القهوة ومستلزماتها", "fr": "Café et accessoires"}', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW());

-- Subcategories for Part 2
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
  -- Supermarket subcategories (bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb)
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', '{"en": "Fresh Products", "ar": "منتجات طازجة", "fr": "Produits frais"}', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', '{"en": "Canned Goods", "ar": "معلبات", "fr": "Conserves"}', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1584628804776-34dfe6d92a8c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', '{"en": "Beverages", "ar": "مشروبات", "fr": "Boissons"}', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1581006852262-e4307cf6283a?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', '{"en": "Cleaning Products", "ar": "منظفات", "fr": "Produits de nettoyage"}', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1563453392212-326f5e854473?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', '{"en": "Organic Products", "ar": "منتجات عضوية", "fr": "Produits biologiques"}', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1604719312566-8912e9c8a213?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Books & Hobbies subcategories (cccccccc-cccc-cccc-cccc-cccccccccccc)
  ('cccccccc-cccc-cccc-cccc-cccccccccc01', '{"en": "Books", "ar": "كتب", "fr": "Livres"}', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1526243741027-444d633d7365?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccc02', '{"en": "Art Supplies", "ar": "أدوات فنية", "fr": "Fournitures d''art"}', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccc03', '{"en": "Musical Instruments", "ar": "آلات موسيقية", "fr": "Instruments de musique"}', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccc04', '{"en": "Board Games", "ar": "ألعاب ذهنية", "fr": "Jeux de société"}', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccc05', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Services subcategories (dddddddd-dddd-dddd-dddd-dddddddddddd)
  ('dddddddd-dddd-dddd-dddd-dddddddddd01', '{"en": "Gift Cards", "ar": "بطاقات هدايا", "fr": "Cartes-cadeaux"}', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://images.unsplash.com/photo-1607344645866-009c320c5ab0?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('dddddddd-dddd-dddd-dddd-dddddddddd02', '{"en": "Subscriptions", "ar": "اشتراكات", "fr": "Abonnements"}', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('dddddddd-dddd-dddd-dddd-dddddddddd03', '{"en": "Repair & Maintenance", "ar": "تصليح وصيانة", "fr": "Réparation et entretien"}', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://images.unsplash.com/photo-1581092921461-39b9d080a747?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('dddddddd-dddd-dddd-dddd-dddddddddd04', '{"en": "Consultations", "ar": "استشارات", "fr": "Consultations"}', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('dddddddd-dddd-dddd-dddd-dddddddddd05', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://images.unsplash.com/photo-1521791136064-7986c2920216?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Incense & Arabic Perfumes subcategories (eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee)
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01', '{"en": "Incense", "ar": "بخور", "fr": "Encens"}', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://images.unsplash.com/photo-1518911710364-17ec553bde5d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee02', '{"en": "Oud Oil", "ar": "دهن عود", "fr": "Huile d''oud"}', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://images.unsplash.com/photo-1599413085258-8d97a3e55b7a?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee03', '{"en": "Mamool", "ar": "معمول", "fr": "Mamool"}', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee04', '{"en": "Oriental Perfumes", "ar": "عطور شرقية", "fr": "Parfums orientaux"}', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://images.unsplash.com/photo-1592945403407-9caf930b2fbe?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee05', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://images.unsplash.com/photo-1544311747-3f061e674a16?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Flowers subcategories (ffffffff-ffff-ffff-ffff-ffffffffffff)
  ('ffffffff-ffff-ffff-ffff-ffffffffff01', '{"en": "Natural Flowers", "ar": "زهور طبيعية", "fr": "Fleurs naturelles"}', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('ffffffff-ffff-ffff-ffff-ffffffffff02', '{"en": "Artificial Flowers", "ar": "زهور صناعية", "fr": "Fleurs artificielles"}', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'https://images.unsplash.com/photo-1589123053646-4e8b5493f3c4?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('ffffffff-ffff-ffff-ffff-ffffffffff03', '{"en": "Arrangements", "ar": "تنسيقات", "fr": "Arrangements"}', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'https://images.unsplash.com/photo-1561181286-d3fee7d55364?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('ffffffff-ffff-ffff-ffff-ffffffffff04', '{"en": "Arrangement Supplies", "ar": "مستلزمات تنسيق", "fr": "Fournitures d''arrangement"}', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'https://images.unsplash.com/photo-1563241527-3004b7be0ffd?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('ffffffff-ffff-ffff-ffff-ffffffffff05', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Tools & Supplies subcategories (11111111-2222-3333-4444-555555555555)
  ('11111111-2222-3333-4444-555555555501', '{"en": "Hand Tools", "ar": "عدد يدوية", "fr": "Outils à main"}', '11111111-2222-3333-4444-555555555555', 'https://images.unsplash.com/photo-1581166397057-235af2b3c6dd?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-2222-3333-4444-555555555502', '{"en": "Power Tools", "ar": "معدات كهربائية", "fr": "Outils électriques"}', '11111111-2222-3333-4444-555555555555', 'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-2222-3333-4444-555555555503', '{"en": "Maintenance Supplies", "ar": "مستلزمات صيانة", "fr": "Fournitures d''entretien"}', '11111111-2222-3333-4444-555555555555', 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-2222-3333-4444-555555555504', '{"en": "Safety Equipment", "ar": "معدات السلامة", "fr": "Équipement de sécurité"}', '11111111-2222-3333-4444-555555555555', 'https://images.unsplash.com/photo-1578167732217-69dd660de2d7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('11111111-2222-3333-4444-555555555505', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '11111111-2222-3333-4444-555555555555', 'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Dates & Accessories subcategories (22222222-3333-4444-5555-666666666666)
  ('22222222-3333-4444-5555-666666666601', '{"en": "Date Varieties", "ar": "أنواع التمور", "fr": "Variétés de dattes"}', '22222222-3333-4444-5555-666666666666', 'https://images.unsplash.com/photo-1563252722-6434563a985d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-3333-4444-5555-666666666602', '{"en": "Date Products", "ar": "منتجات التمر", "fr": "Produits à base de dattes"}', '22222222-3333-4444-5555-666666666666', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-3333-4444-5555-666666666603', '{"en": "Date Packaging", "ar": "تغليف وتقديم التمور", "fr": "Emballage de dattes"}', '22222222-3333-4444-5555-666666666666', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-3333-4444-5555-666666666604', '{"en": "Date Gifts", "ar": "هدايا التمور", "fr": "Cadeaux de dattes"}', '22222222-3333-4444-5555-666666666666', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('22222222-3333-4444-5555-666666666605', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '22222222-3333-4444-5555-666666666666', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Hijab subcategories (33333333-4444-5555-6666-777777777777)
  ('33333333-4444-5555-6666-777777777701', '{"en": "Hijab Clothing", "ar": "ملابس محجبات", "fr": "Vêtements hijab"}', '33333333-4444-5555-6666-777777777777', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-4444-5555-6666-777777777702', '{"en": "Head Coverings", "ar": "أغطية رأس", "fr": "Couvre-chefs"}', '33333333-4444-5555-6666-777777777777', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-4444-5555-6666-777777777703', '{"en": "Accessories", "ar": "إكسسوارات", "fr": "Accessoires"}', '33333333-4444-5555-6666-777777777777', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-4444-5555-6666-777777777704', '{"en": "Sports Hijab", "ar": "حجاب الرياضة", "fr": "Hijab de sport"}', '33333333-4444-5555-6666-777777777777', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('33333333-4444-5555-6666-777777777705', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '33333333-4444-5555-6666-777777777777', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Tea & Accessories subcategories (44444444-5555-6666-7777-888888888888)
  ('44444444-5555-6666-7777-888888888801', '{"en": "Herbal Tea", "ar": "شاي أعشاب", "fr": "Tisane"}', '44444444-5555-6666-7777-888888888888', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-5555-6666-7777-888888888802', '{"en": "Traditional Tea", "ar": "شاي تقليدي", "fr": "Thé traditionnel"}', '44444444-5555-6666-7777-888888888888', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-5555-6666-7777-888888888803', '{"en": "Premium Tea", "ar": "شاي فاخر", "fr": "Thé premium"}', '44444444-5555-6666-7777-888888888888', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-5555-6666-7777-888888888804', '{"en": "Tea Preparation", "ar": "مستلزمات تحضير الشاي", "fr": "Préparation du thé"}', '44444444-5555-6666-7777-888888888888', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('44444444-5555-6666-7777-888888888805', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '44444444-5555-6666-7777-888888888888', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),

  -- Coffee & Accessories subcategories (55555555-6666-7777-8888-999999999999)
  ('55555555-6666-7777-8888-999999999901', '{"en": "Arabic Coffee", "ar": "قهوة عربية", "fr": "Café arabe"}', '55555555-6666-7777-8888-999999999999', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-6666-7777-8888-999999999902', '{"en": "Espresso Coffee", "ar": "قهوة إسبريسو", "fr": "Café expresso"}', '55555555-6666-7777-8888-999999999999', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-6666-7777-8888-999999999903', '{"en": "French Press Coffee", "ar": "قهوة فرنسية", "fr": "Café presse française"}', '55555555-6666-7777-8888-999999999999', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-6666-7777-8888-999999999904', '{"en": "Coffee Preparation", "ar": "مستلزمات تحضير القهوة", "fr": "Préparation du café"}', '55555555-6666-7777-8888-999999999999', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('55555555-6666-7777-8888-999999999905', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', '55555555-6666-7777-8888-999999999999', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW());
