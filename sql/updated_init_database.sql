-- Matajir Database Initialization Script
-- This script creates all necessary tables for the Matajir app with the updated schema including payment integration

-- Create extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE,
    name TEXT,
    phone_number TEXT,
    profile_image_url TEXT,
    is_store_owner BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name JSONB NOT NULL, -- Multilingual name: {"en": "Category Name", "ar": "اسم الفئة"}
    parent_id UUID REFERENCES categories(id),
    photo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create stores table with promotion fields
CREATE TABLE IF NOT EXISTS stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES profiles(id) NOT NULL,
    name TEXT NOT NULL,
    second_name TEXT,
    description TEXT,
    logo_url TEXT,
    location TEXT,
    country TEXT,
    state TEXT,
    city TEXT,
    keywords TEXT, -- Keywords for search instead of address
    phone_number TEXT,
    email TEXT,
    website TEXT,
    social_links JSONB,
    category_id UUID REFERENCES categories(id),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_promoted BOOLEAN DEFAULT FALSE, -- New field for store promotion
    promotion_starts_at TIMESTAMP WITH TIME ZONE, -- New field for promotion start date
    promotion_ends_at TIMESTAMP WITH TIME ZONE, -- New field for promotion end date
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create store_banners table
CREATE TABLE IF NOT EXISTS store_banners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create store_categories table (for many-to-many relationship)
CREATE TABLE IF NOT EXISTS store_categories (
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (store_id, category_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create favorites table
CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, store_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    payment_intent_id TEXT NOT NULL,
    amount TEXT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'usd',
    status TEXT NOT NULL,
    description TEXT,
    advertisement_id UUID,
    store_id UUID REFERENCES stores(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create advertisements table with payment fields
CREATE TABLE IF NOT EXISTS advertisements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id),
    name TEXT NOT NULL,
    image_url TEXT NOT NULL,
    click_url TEXT NOT NULL,
    location TEXT DEFAULT 'home', -- 'home', 'category', 'store'
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ends_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    ad_type TEXT NOT NULL, -- 'home_spotlight', 'category_match', 'top_store_boost'
    category_id UUID REFERENCES categories(id),
    subcategory_id UUID REFERENCES categories(id),
    store_id UUID REFERENCES stores(id),
    payment_id UUID REFERENCES payments(id),
    is_paid BOOLEAN DEFAULT FALSE,
    payment_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create advertisement_categories table (for targeting ads to specific categories)
CREATE TABLE IF NOT EXISTS advertisement_categories (
    advertisement_id UUID REFERENCES advertisements(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (advertisement_id, category_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_stores_owner ON stores(owner_id);
CREATE INDEX IF NOT EXISTS idx_stores_country ON stores(country);
CREATE INDEX IF NOT EXISTS idx_stores_category ON stores(category_id);
CREATE INDEX IF NOT EXISTS idx_stores_promoted ON stores(is_promoted);
CREATE INDEX IF NOT EXISTS idx_store_banners_store ON store_banners(store_id);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_store_categories_store ON store_categories(store_id);
CREATE INDEX IF NOT EXISTS idx_store_categories_category ON store_categories(category_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_store ON favorites(store_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_user ON advertisements(user_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_active ON advertisements(is_active);
CREATE INDEX IF NOT EXISTS idx_advertisements_paid ON advertisements(is_paid);
CREATE INDEX IF NOT EXISTS idx_advertisements_payment ON advertisements(payment_id);
CREATE INDEX IF NOT EXISTS idx_advertisement_categories_ad ON advertisement_categories(advertisement_id);
CREATE INDEX IF NOT EXISTS idx_advertisement_categories_category ON advertisement_categories(category_id);
CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_intent_id ON payments(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_payments_advertisement ON payments(advertisement_id);
CREATE INDEX IF NOT EXISTS idx_payments_store ON payments(store_id);

-- Create text search indexes
CREATE INDEX IF NOT EXISTS idx_stores_name ON stores USING gin (to_tsvector('english', name));
CREATE INDEX IF NOT EXISTS idx_stores_keywords ON stores USING gin (to_tsvector('english', keywords));

-- Create trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables with updated_at column
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON stores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_store_banners_updated_at BEFORE UPDATE ON store_banners FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_advertisements_updated_at BEFORE UPDATE ON advertisements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to automatically update store promotion status based on dates
CREATE OR REPLACE FUNCTION update_store_promotion_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the promotion period is active
  IF NEW.promotion_starts_at IS NOT NULL AND NEW.promotion_ends_at IS NOT NULL THEN
    IF NOW() BETWEEN NEW.promotion_starts_at AND NEW.promotion_ends_at THEN
      NEW.is_promoted := TRUE;
    ELSE
      NEW.is_promoted := FALSE;
    END IF;
  ELSE
    NEW.is_promoted := FALSE;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update the is_promoted field
CREATE TRIGGER update_store_promotion_status_trigger
BEFORE INSERT OR UPDATE ON stores
FOR EACH ROW EXECUTE FUNCTION update_store_promotion_status();

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, name, created_at, updated_at)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'name', NOW(), NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE advertisements ENABLE ROW LEVEL SECURITY;
ALTER TABLE advertisement_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Create RLS policies for stores
CREATE POLICY "Anyone can view active stores"
  ON stores FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Store owners can manage their own stores"
  ON stores FOR ALL
  USING (auth.uid() = owner_id);

-- Create RLS policies for categories
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  USING (TRUE);

-- Create RLS policies for advertisements
CREATE POLICY "Anyone can view active advertisements"
  ON advertisements FOR SELECT
  USING (is_active = TRUE AND is_paid = TRUE AND NOW() BETWEEN starts_at AND ends_at);

CREATE POLICY "Users can manage their own advertisements"
  ON advertisements FOR ALL
  USING (auth.uid() = user_id);

-- Create RLS policies for payments
CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);
