-- Matajir Sample Data Script
-- This script populates the database with sample data for testing

-- Insert sample categories (top-level)
INSERT INTO categories (id, name, photo_url, is_active, display_order) VALUES
('11111111-1111-1111-1111-111111111111', '{"en": "Fashion", "ar": "أزياء", "fr": "Mode"}', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=300', TRUE, 1),
('22222222-2222-2222-2222-222222222222', '{"en": "Electronics", "ar": "إلكترونيات", "fr": "Électronique"}', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=300', TRUE, 2),
('33333333-3333-3333-3333-333333333333', '{"en": "Home", "ar": "منزل", "fr": "Maison"}', 'https://images.unsplash.com/photo-1484154218962-a197022b5858?q=80&w=300', TRUE, 3),
('44444444-4444-4444-4444-444444444444', '{"en": "Beauty", "ar": "جمال", "fr": "Beauté"}', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=300', TRUE, 4),
('55555555-5555-5555-5555-555555555555', '{"en": "Food", "ar": "طعام", "fr": "Alimentation"}', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=300', TRUE, 5),
('66666666-6666-6666-6666-666666666666', '{"en": "Sports", "ar": "رياضة", "fr": "Sports"}', 'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=300', TRUE, 6);

-- Insert sample subcategories
INSERT INTO categories (id, name, parent_id, photo_url, is_active, display_order) VALUES
-- Fashion subcategories
('11111111-1111-1111-1111-111111111101', '{"en": "Men", "ar": "رجال", "fr": "Hommes"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=300', TRUE, 1),
('11111111-1111-1111-1111-111111111102', '{"en": "Women", "ar": "نساء", "fr": "Femmes"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=300', TRUE, 2),
('11111111-1111-1111-1111-111111111103', '{"en": "Kids", "ar": "أطفال", "fr": "Enfants"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?q=80&w=300', TRUE, 3),
('11111111-1111-1111-1111-111111111104', '{"en": "Accessories", "ar": "إكسسوارات", "fr": "Accessoires"}', '11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1611085583191-a3b181a88401?q=80&w=300', TRUE, 4),

-- Electronics subcategories
('22222222-2222-2222-2222-222222222201', '{"en": "Smartphones", "ar": "هواتف ذكية", "fr": "Smartphones"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?q=80&w=300', TRUE, 1),
('22222222-2222-2222-2222-222222222202', '{"en": "Laptops", "ar": "أجهزة الكمبيوتر المحمولة", "fr": "Ordinateurs portables"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=300', TRUE, 2),
('22222222-2222-2222-2222-222222222203', '{"en": "Audio", "ar": "صوت", "fr": "Audio"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=300', TRUE, 3),
('22222222-2222-2222-2222-222222222204', '{"en": "Cameras", "ar": "كاميرات", "fr": "Caméras"}', '22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=300', TRUE, 4),

-- Home subcategories
('33333333-3333-3333-3333-333333333301', '{"en": "Furniture", "ar": "أثاث", "fr": "Meubles"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=300', TRUE, 1),
('33333333-3333-3333-3333-333333333302', '{"en": "Decor", "ar": "ديكور", "fr": "Décoration"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=300', TRUE, 2),
('33333333-3333-3333-3333-333333333303', '{"en": "Kitchen", "ar": "مطبخ", "fr": "Cuisine"}', '33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1556911220-bda9f7f6b548?q=80&w=300', TRUE, 3);

-- Insert sample user profiles
INSERT INTO profiles (id, email, name, phone_number, is_store_owner, is_verified) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user1@example.com', 'John Doe', '+1234567890', TRUE, TRUE),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'user2@example.com', 'Jane Smith', '+0987654321', FALSE, TRUE);

-- Insert sample stores
INSERT INTO stores (id, owner_id, name, second_name, description, logo_url, country, city, keywords, phone_number, email, website, social_links, is_verified, is_active) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Fashion Trends', 'أزياء ترندز', 'The latest fashion trends for all seasons', 'https://picsum.photos/200', 'TN', 'Tunis', 'fashion clothing apparel style dress shoes', '+216 12 345 678', 'fashion@example.com', 'https://fashion.example.com', '{"instagram": "https://instagram.com/fashiontrends", "facebook": "https://facebook.com/fashiontrends"}', TRUE, TRUE),

('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Tech World', 'تك وورلد', 'Your one-stop shop for all electronics', 'https://picsum.photos/201', 'TN', 'Sfax', 'electronics gadgets tech computers phones', '+216 98 765 432', 'tech@example.com', 'https://tech.example.com', '{"instagram": "https://instagram.com/techworld", "twitter": "https://twitter.com/techworld"}', TRUE, TRUE),

('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Home Essentials', 'هوم إسنشالز', 'Everything you need for your home', 'https://picsum.photos/202', 'TN', 'Sousse', 'home furniture decor kitchen appliances', '+216 55 555 555', 'home@example.com', 'https://home.example.com', '{"instagram": "https://instagram.com/homeessentials"}', TRUE, TRUE);

-- Insert sample store banners
INSERT INTO store_banners (store_id, image_url, display_order) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://picsum.photos/800/400?random=1', 1),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://picsum.photos/800/400?random=2', 2),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://picsum.photos/800/400?random=3', 1),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'https://picsum.photos/800/400?random=4', 2),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'https://picsum.photos/800/400?random=5', 1);

-- Insert store-category relationships
INSERT INTO store_categories (store_id, category_id) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111'), -- Fashion Trends in Fashion
('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111102'), -- Fashion Trends in Women
('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222'), -- Tech World in Electronics
('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222201'), -- Tech World in Smartphones
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '33333333-3333-3333-3333-333333333333'), -- Home Essentials in Home
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '33333333-3333-3333-3333-333333333301'); -- Home Essentials in Furniture

-- Insert sample favorites
INSERT INTO favorites (user_id, store_id) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee');

-- Insert sample advertisements
INSERT INTO advertisements (id, user_id, name, image_url, click_url, location, starts_at, ends_at, is_active) VALUES
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Summer Sale', 'https://picsum.photos/800/400?random=10', 'https://example.com/summer-sale', 'home', NOW(), NOW() + INTERVAL '30 days', TRUE),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'New Electronics', 'https://picsum.photos/800/400?random=11', 'https://example.com/new-electronics', 'category', NOW(), NOW() + INTERVAL '30 days', TRUE);

-- Insert advertisement-category relationships
INSERT INTO advertisement_categories (advertisement_id, category_id) VALUES
('gggggggg-gggg-gggg-gggg-gggggggggggg', '22222222-2222-2222-2222-222222222222'); -- New Electronics ad in Electronics category
