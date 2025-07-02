-- Complete Fix for Registration Issues
-- This will resolve the RLS policy violations

-- Step 1: Completely disable RLS on profiles to fix registration
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies that might conflict
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can manage own profile" ON profiles;
DROP POLICY IF EXISTS "Service role full access" ON profiles;
DROP POLICY IF EXISTS "Authenticated users can view profiles" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on email" ON profiles;

-- Step 3: Add admin columns if they don't exist
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Step 4: Re-enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Step 5: Create simple, working policies
-- Allow authenticated users to insert their own profile
CREATE POLICY "Allow authenticated insert"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Allow users to view their own profile
CREATE POLICY "Allow own profile view"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Allow own profile update"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Allow service role full access (for admin operations)
CREATE POLICY "Service role full access"
  ON profiles FOR ALL
  TO service_role
  USING (true);

-- Step 6: Grant necessary permissions
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;

-- Step 7: Create the admin user if it doesn't exist
DO $$
DECLARE
    admin_user_id UUID;
BEGIN
    -- Check if admin user already exists
    SELECT id INTO admin_user_id FROM auth.users WHERE email = 'admin@matajir.com';
    
    IF admin_user_id IS NULL THEN
        -- Create admin user in auth.users
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
            'admin@matajir.com',
            crypt('admin123456', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            '',
            '',
            '',
            ''
        ) RETURNING id INTO admin_user_id;
        
        -- Create admin profile
        INSERT INTO profiles (
            id,
            email,
            name,
            is_admin,
            is_verified,
            is_blocked,
            created_at,
            updated_at
        ) VALUES (
            admin_user_id,
            'admin@matajir.com',
            'System Administrator',
            TRUE,
            TRUE,
            FALSE,
            NOW(),
            NOW()
        );
        
        RAISE NOTICE 'Admin user created successfully!';
    ELSE
        -- Update existing user to be admin
        UPDATE profiles 
        SET is_admin = TRUE, 
            is_verified = TRUE, 
            is_blocked = FALSE,
            updated_at = NOW()
        WHERE id = admin_user_id;
        
        RAISE NOTICE 'Existing user updated to admin!';
    END IF;
END $$;

-- Step 8: Create reports table with proper policies
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

-- Enable RLS on reports
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Drop existing report policies
DROP POLICY IF EXISTS "Users can view own reports" ON reports;
DROP POLICY IF EXISTS "Users can create reports" ON reports;
DROP POLICY IF EXISTS "Service role can manage reports" ON reports;

-- Create report policies
CREATE POLICY "Users can view own reports"
  ON reports FOR SELECT
  TO authenticated
  USING (auth.uid() = reporter_id);

CREATE POLICY "Users can create reports"
  ON reports FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Service role can manage reports"
  ON reports FOR ALL
  TO service_role
  USING (true);

-- Grant permissions on reports
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;

-- Step 9: Verify everything is working
SELECT 
    'Admin user verification:' as info,
    p.id, 
    p.email, 
    p.name, 
    p.is_admin, 
    p.is_blocked
FROM profiles p
WHERE p.email = 'admin@matajir.com';

-- Success message
DO $$
BEGIN
  RAISE NOTICE '=== SETUP COMPLETE ===';
  RAISE NOTICE 'Admin Email: admin@matajir.com';
  RAISE NOTICE 'Admin Password: admin123456';
  RAISE NOTICE 'Registration should now work for new users!';
  RAISE NOTICE 'Please restart your app and try registering again.';
END $$;
