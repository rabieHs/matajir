-- EMERGENCY FIX - Temporarily disable RLS to allow registration
-- Use this if you just want to get registration working quickly

-- Disable RLS on all tables that might cause issues
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;

-- Add admin columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Create reports table
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reported_store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending',
    reviewed_by UUID REFERENCES profiles(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Grant all permissions
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;

-- Create admin user
INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000000',
    'admin@matajir.com',
    crypt('admin123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Create admin profile
INSERT INTO profiles (
    id,
    email,
    name,
    is_admin,
    is_verified,
    created_at,
    updated_at
) 
SELECT 
    u.id,
    u.email,
    'System Administrator',
    TRUE,
    TRUE,
    NOW(),
    NOW()
FROM auth.users u 
WHERE u.email = 'admin@matajir.com'
ON CONFLICT (email) DO UPDATE SET
    is_admin = TRUE,
    is_verified = TRUE;

-- Success message
SELECT 'RLS DISABLED - Registration should work now!' as status;
SELECT 'Admin created: admin@matajir.com / admin123456' as credentials;
