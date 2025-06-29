-- Script to upload categories and subcategories to Supabase (Part 2)

-- Main Categories (Part 2)
INSERT INTO categories (id, name, photo_url, grid_size, gradient_start_color, gradient_end_color, is_active, created_at, updated_at)
VALUES
  ('c11', '{"en": "Supermarket", "ar": "السوبرماركت", "fr": "Supermarché"}', 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('c12', '{"en": "Books & Hobbies", "ar": "الكتب والهوايات", "fr": "Livres et loisirs"}', 'https://images.unsplash.com/photo-1526243741027-444d633d7365?q=80&w=1000&auto=format&fit=crop', 1, '#795548', '#607D8B', true, NOW(), NOW()),
  ('c13', '{"en": "Services", "ar": "الخدمات", "fr": "Services"}', 'https://images.unsplash.com/photo-1521791136064-7986c2920216?q=80&w=1000&auto=format&fit=crop', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('c14', '{"en": "Incense & Arabic Perfumes", "ar": "البخور والعطورات العربية", "fr": "Encens et parfums arabes"}', 'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW()),
  ('c15', '{"en": "Flowers", "ar": "الزهور", "fr": "Fleurs"}', 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=1000&auto=format&fit=crop', 1, '#3F51B5', '#2196F3', true, NOW(), NOW()),
  ('c16', '{"en": "Tools & Supplies", "ar": "العدد ومستلزماتها", "fr": "Outils et fournitures"}', 'https://images.unsplash.com/photo-1581166397057-235af2b3c6dd?q=80&w=1000&auto=format&fit=crop', 1, '#009688', '#4CAF50', true, NOW(), NOW()),
  ('c17', '{"en": "Dates & Accessories", "ar": "التمور وتوابعها", "fr": "Dattes et accessoires"}', 'https://images.unsplash.com/photo-1563252722-6434563a985d?q=80&w=1000&auto=format&fit=crop', 1, '#FF9800', '#FF5722', true, NOW(), NOW()),
  ('c18', '{"en": "Hijab", "ar": "المحجبات", "fr": "Hijab"}', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, '#795548', '#607D8B', true, NOW(), NOW()),
  ('c19', '{"en": "Tea & Accessories", "ar": "الشاي ومستلزماته", "fr": "Thé et accessoires"}', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, '#9C27B0', '#673AB7', true, NOW(), NOW()),
  ('c20', '{"en": "Coffee & Accessories", "ar": "القهوة ومستلزماتها", "fr": "Café et accessoires"}', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, '#F44336', '#E91E63', true, NOW(), NOW());

-- Subcategories for Part 2
INSERT INTO categories (id, name, parent_id, photo_url, grid_size, is_active, created_at, updated_at)
VALUES
  -- Supermarket subcategories (c11)
  ('sc1101', '{"en": "Fresh Products", "ar": "منتجات طازجة", "fr": "Produits frais"}', 'c11', 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1102', '{"en": "Canned Goods", "ar": "معلبات", "fr": "Conserves"}', 'c11', 'https://images.unsplash.com/photo-1584628804776-34dfe6d92a8c?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1103', '{"en": "Beverages", "ar": "مشروبات", "fr": "Boissons"}', 'c11', 'https://images.unsplash.com/photo-1581006852262-e4307cf6283a?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1104', '{"en": "Cleaning Products", "ar": "منظفات", "fr": "Produits de nettoyage"}', 'c11', 'https://images.unsplash.com/photo-1563453392212-326f5e854473?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1105', '{"en": "Organic Products", "ar": "منتجات عضوية", "fr": "Produits biologiques"}', 'c11', 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1106', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c11', 'https://images.unsplash.com/photo-1604719312566-8912e9c8a213?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Books & Hobbies subcategories (c12)
  ('sc1201', '{"en": "Books", "ar": "كتب", "fr": "Livres"}', 'c12', 'https://images.unsplash.com/photo-1526243741027-444d633d7365?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1202', '{"en": "Art Supplies", "ar": "أدوات فنية", "fr": "Fournitures d'art"}', 'c12', 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1203', '{"en": "Musical Instruments", "ar": "آلات موسيقية", "fr": "Instruments de musique"}', 'c12', 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1204', '{"en": "Board Games", "ar": "ألعاب ذهنية", "fr": "Jeux de société"}', 'c12', 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1205', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c12', 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Services subcategories (c13)
  ('sc1301', '{"en": "Gift Cards", "ar": "بطاقات هدايا", "fr": "Cartes-cadeaux"}', 'c13', 'https://images.unsplash.com/photo-1607344645866-009c320c5ab0?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1302', '{"en": "Subscriptions", "ar": "اشتراكات", "fr": "Abonnements"}', 'c13', 'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1303', '{"en": "Repair & Maintenance", "ar": "تصليح وصيانة", "fr": "Réparation et entretien"}', 'c13', 'https://images.unsplash.com/photo-1581092921461-39b9d080a747?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1304', '{"en": "Consultations", "ar": "استشارات", "fr": "Consultations"}', 'c13', 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1305', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c13', 'https://images.unsplash.com/photo-1521791136064-7986c2920216?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Incense & Arabic Perfumes subcategories (c14)
  ('sc1401', '{"en": "Incense", "ar": "بخور", "fr": "Encens"}', 'c14', 'https://images.unsplash.com/photo-1518911710364-17ec553bde5d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1402', '{"en": "Oud Oil", "ar": "دهن عود", "fr": "Huile d'oud"}', 'c14', 'https://images.unsplash.com/photo-1599413085258-8d97a3e55b7a?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1403', '{"en": "Mamool", "ar": "معمول", "fr": "Mamool"}', 'c14', 'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1404', '{"en": "Oriental Perfumes", "ar": "عطور شرقية", "fr": "Parfums orientaux"}', 'c14', 'https://images.unsplash.com/photo-1592945403407-9caf930b2fbe?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1405', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c14', 'https://images.unsplash.com/photo-1544311747-3f061e674a16?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Flowers subcategories (c15)
  ('sc1501', '{"en": "Natural Flowers", "ar": "زهور طبيعية", "fr": "Fleurs naturelles"}', 'c15', 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1502', '{"en": "Artificial Flowers", "ar": "زهور صناعية", "fr": "Fleurs artificielles"}', 'c15', 'https://images.unsplash.com/photo-1589123053646-4e8b5493f3c4?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1503', '{"en": "Arrangements", "ar": "تنسيقات", "fr": "Arrangements"}', 'c15', 'https://images.unsplash.com/photo-1561181286-d3fee7d55364?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1504', '{"en": "Arrangement Supplies", "ar": "مستلزمات تنسيق", "fr": "Fournitures d'arrangement"}', 'c15', 'https://images.unsplash.com/photo-1563241527-3004b7be0ffd?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1505', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c15', 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Tools & Supplies subcategories (c16)
  ('sc1601', '{"en": "Hand Tools", "ar": "عدد يدوية", "fr": "Outils à main"}', 'c16', 'https://images.unsplash.com/photo-1581166397057-235af2b3c6dd?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1602', '{"en": "Power Tools", "ar": "معدات كهربائية", "fr": "Outils électriques"}', 'c16', 'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1603', '{"en": "Maintenance Supplies", "ar": "مستلزمات صيانة", "fr": "Fournitures d'entretien"}', 'c16', 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1604', '{"en": "Safety Equipment", "ar": "معدات السلامة", "fr": "Équipement de sécurité"}', 'c16', 'https://images.unsplash.com/photo-1578167732217-69dd660de2d7?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1605', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c16', 'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Dates & Accessories subcategories (c17)
  ('sc1701', '{"en": "Date Varieties", "ar": "أنواع التمور", "fr": "Variétés de dattes"}', 'c17', 'https://images.unsplash.com/photo-1563252722-6434563a985d?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1702', '{"en": "Date Products", "ar": "منتجات التمر", "fr": "Produits à base de dattes"}', 'c17', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1703', '{"en": "Date Packaging", "ar": "تغليف وتقديم التمور", "fr": "Emballage de dattes"}', 'c17', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1704', '{"en": "Date Gifts", "ar": "هدايا التمور", "fr": "Cadeaux de dattes"}', 'c17', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1705', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c17', 'https://images.unsplash.com/photo-1593358577414-89b8b0c8be25?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Hijab subcategories (c18)
  ('sc1801', '{"en": "Hijab Clothing", "ar": "ملابس محجبات", "fr": "Vêtements hijab"}', 'c18', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1802', '{"en": "Head Coverings", "ar": "أغطية رأس", "fr": "Couvre-chefs"}', 'c18', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1803', '{"en": "Accessories", "ar": "إكسسوارات", "fr": "Accessoires"}', 'c18', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1804', '{"en": "Sports Hijab", "ar": "حجاب الرياضة", "fr": "Hijab de sport"}', 'c18', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1805', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c18', 'https://images.unsplash.com/photo-1611507929918-1d5762e6b408?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Tea & Accessories subcategories (c19)
  ('sc1901', '{"en": "Herbal Tea", "ar": "شاي أعشاب", "fr": "Tisane"}', 'c19', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1902', '{"en": "Traditional Tea", "ar": "شاي تقليدي", "fr": "Thé traditionnel"}', 'c19', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1903', '{"en": "Premium Tea", "ar": "شاي فاخر", "fr": "Thé premium"}', 'c19', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1904', '{"en": "Tea Preparation", "ar": "مستلزمات تحضير الشاي", "fr": "Préparation du thé"}', 'c19', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc1905', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c19', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  
  -- Coffee & Accessories subcategories (c20)
  ('sc2001', '{"en": "Arabic Coffee", "ar": "قهوة عربية", "fr": "Café arabe"}', 'c20', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc2002', '{"en": "Espresso Coffee", "ar": "قهوة إسبريسو", "fr": "Café expresso"}', 'c20', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc2003', '{"en": "French Press Coffee", "ar": "قهوة فرنسية", "fr": "Café presse française"}', 'c20', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc2004', '{"en": "Coffee Preparation", "ar": "مستلزمات تحضير القهوة", "fr": "Préparation du café"}', 'c20', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW()),
  ('sc2005', '{"en": "Other", "ar": "أخرى", "fr": "Autre"}', 'c20', 'https://images.unsplash.com/photo-1511537190424-bbbab87ac5eb?q=80&w=1000&auto=format&fit=crop', 1, true, NOW(), NOW());

-- ON CONFLICT DO NOTHING is added to prevent errors if the categories already exist
ON CONFLICT (id) DO UPDATE SET 
  name = EXCLUDED.name,
  photo_url = EXCLUDED.photo_url,
  grid_size = EXCLUDED.grid_size,
  gradient_start_color = EXCLUDED.gradient_start_color,
  gradient_end_color = EXCLUDED.gradient_end_color,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();
