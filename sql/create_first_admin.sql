-- Create First Admin User Script
-- Run this in Supabase SQL Editor to create your first admin user

-- First, fix the RLS policies to prevent errors
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Drop problematic policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Add admin columns if they don't exist
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Create the admin user directly in auth.users and profiles
-- You'll need to replace these values with your desired admin credentials

-- Step 1: Create user in auth.users table (this creates the authentication)
INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000000',
    'admin@matajir.com',  -- Change this to your desired admin email
    crypt('admin123456', gen_salt('bf')),  -- Change 'admin123456' to your desired password
    NOW(),
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
) ON CONFLICT (email) DO NOTHING;

-- Step 2: Create profile for the admin user
INSERT INTO profiles (
    id,
    email,
    name,
    is_admin,
    is_verified,
    is_blocked,
    created_at,
    updated_at
) 
SELECT 
    u.id,
    u.email,
    'System Administrator',  -- Change this to desired admin name
    TRUE,
    TRUE,
    FALSE,
    NOW(),
    NOW()
FROM auth.users u 
WHERE u.email = 'admin@matajir.com'  -- Must match the email above
ON CONFLICT (email) DO UPDATE SET
    is_admin = TRUE,
    is_verified = TRUE,
    is_blocked = FALSE,
    updated_at = NOW();

-- Re-enable RLS with safe policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create safe policies
CREATE POLICY "Users can manage own profile"
  ON profiles FOR ALL
  USING (auth.uid() = id);

CREATE POLICY "Service role full access"
  ON profiles FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Authenticated users can view profiles"
  ON profiles FOR SELECT
  USING (auth.role() = 'authenticated');

-- Grant permissions
GRANT ALL ON profiles TO service_role;

-- Verify the admin user was created
SELECT 
    p.id, 
    p.email, 
    p.name, 
    p.is_admin, 
    p.is_blocked,
    u.email_confirmed_at
FROM profiles p
JOIN auth.users u ON p.id = u.id
WHERE p.email = 'admin@matajir.com';  -- Must match the email above

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Admin user created successfully!';
  RAISE NOTICE 'Email: admin@matajir.com';
  RAISE NOTICE 'Password: admin123456';
  RAISE NOTICE 'Please change these credentials after first login!';
END $$;
