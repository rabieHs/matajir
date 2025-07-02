-- Add static promotional advertisements
-- These ads will be shown when there are no active paid advertisements

-- Create static_advertisements table for promotional content
CREATE TABLE IF NOT EXISTS static_advertisements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name JSONB NOT NULL, -- Multilingual name: {"en": "Ad Name", "ar": "اسم الإعلان", "fr": "Nom de l'annonce"}
    description JSONB, -- Multilingual description
    image_url TEXT NOT NULL,
    click_url TEXT NOT NULL,
    ad_type TEXT NOT NULL, -- 'home_spotlight', 'category_match', 'store_boost'
    category_id UUID REFERENCES categories(id),
    subcategory_id UUID REFERENCES categories(id),
    country TEXT, -- If null, shows in all countries
    priority INTEGER DEFAULT 0, -- Higher priority shows first
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_static_ads_ad_type ON static_advertisements(ad_type);
CREATE INDEX IF NOT EXISTS idx_static_ads_country ON static_advertisements(country);
CREATE INDEX IF NOT EXISTS idx_static_ads_category ON static_advertisements(category_id);
CREATE INDEX IF NOT EXISTS idx_static_ads_priority ON static_advertisements(priority DESC);
CREATE INDEX IF NOT EXISTS idx_static_ads_active ON static_advertisements(is_active);

-- Enable RLS
ALTER TABLE static_advertisements ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY "Anyone can view active static advertisements"
  ON static_advertisements FOR SELECT
  USING (is_active = TRUE);

-- Insert sample static promotional ads
INSERT INTO static_advertisements (name, description, image_url, click_url, ad_type, priority) VALUES
(
    '{"en": "Advertise Your Business", "ar": "أعلن عن عملك", "fr": "Annoncez votre entreprise"}',
    '{"en": "Reach thousands of customers with our advertising platform", "ar": "اصل إلى آلاف العملاء من خلال منصتنا الإعلانية", "fr": "Atteignez des milliers de clients avec notre plateforme publicitaire"}',
    'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    '/advertise',
    'home_spotlight',
    10
),
(
    '{"en": "Create Your Store Today", "ar": "أنشئ متجرك اليوم", "fr": "Créez votre magasin aujourd''hui"}',
    '{"en": "Join thousands of successful businesses on our platform", "ar": "انضم إلى آلاف الشركات الناجحة على منصتنا", "fr": "Rejoignez des milliers d''entreprises prospères sur notre plateforme"}',
    'https://images.unsplash.com/photo-1556742111-a301076d9d18?w=800&h=400&fit=crop',
    '/dashboard/add-store',
    'home_spotlight',
    9
),
(
    '{"en": "Boost Your Store Visibility", "ar": "عزز ظهور متجرك", "fr": "Boostez la visibilité de votre magasin"}',
    '{"en": "Get featured in category listings and reach more customers", "ar": "احصل على الظهور في قوائم الفئات واصل إلى المزيد من العملاء", "fr": "Soyez mis en avant dans les listes de catégories et atteignez plus de clients"}',
    'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    '/advertise',
    'category_match',
    8
),
(
    '{"en": "Premium Store Features", "ar": "ميزات المتجر المميز", "fr": "Fonctionnalités de magasin premium"}',
    '{"en": "Unlock advanced features for your store with our premium plans", "ar": "افتح الميزات المتقدمة لمتجرك مع خططنا المميزة", "fr": "Débloquez des fonctionnalités avancées pour votre magasin avec nos plans premium"}',
    'https://images.unsplash.com/photo-1556742111-a301076d9d18?w=800&h=400&fit=crop',
    '/advertise',
    'store_boost',
    7
);

-- Insert country-specific static ads for major markets
INSERT INTO static_advertisements (name, description, image_url, click_url, ad_type, country, priority) VALUES
(
    '{"en": "Grow Your Business in Tunisia", "ar": "نمّ عملك في تونس", "fr": "Développez votre entreprise en Tunisie"}',
    '{"en": "Connect with local customers in Tunisia", "ar": "تواصل مع العملاء المحليين في تونس", "fr": "Connectez-vous avec les clients locaux en Tunisie"}',
    'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    '/advertise',
    'home_spotlight',
    'TN',
    6
),
(
    '{"en": "Expand Your Reach in USA", "ar": "وسع نطاق وصولك في الولايات المتحدة", "fr": "Élargissez votre portée aux États-Unis"}',
    '{"en": "Tap into the American market with targeted advertising", "ar": "استفد من السوق الأمريكي من خلال الإعلانات المستهدفة", "fr": "Exploitez le marché américain avec une publicité ciblée"}',
    'https://images.unsplash.com/photo-1556742111-a301076d9d18?w=800&h=400&fit=crop',
    '/advertise',
    'home_spotlight',
    'US',
    6
),
(
    '{"en": "Reach French Customers", "ar": "اصل إلى العملاء الفرنسيين", "fr": "Atteignez les clients français"}',
    '{"en": "Grow your business in the French market", "ar": "نمّ عملك في السوق الفرنسي", "fr": "Développez votre entreprise sur le marché français"}',
    'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    '/advertise',
    'home_spotlight',
    'FR',
    6
);
