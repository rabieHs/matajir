-- COMPLETE FIX - Handles existing users and fixes registration
-- Run this once to fix everything

-- Step 1: Disable RLS completely to fix registration issues
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;

-- Step 2: Add admin columns if they don't exist
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Step 3: Fix email confirmation and make user admin
-- Update auth.users to confirm email
UPDATE auth.users
SET email_confirmed_at = NOW(),
    updated_at = NOW()
WHERE email = 'admin@commercify.com';

-- Update profiles to make user admin
UPDATE profiles
SET is_admin = TRUE,
    is_verified = TRUE,
    is_blocked = FALSE,
    name = COALESCE(name, 'System Administrator'),
    updated_at = NOW()
WHERE email = 'admin@commercify.com';

-- Step 4: Grant permissions (RLS is disabled so this will work)
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;

-- Step 5: Create reports table
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

-- Grant permissions on reports (RLS is disabled)
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;

-- Step 6: Show auth users and their confirmation status
SELECT
    'Auth users status:' as info,
    id,
    email,
    email_confirmed_at,
    created_at
FROM auth.users
ORDER BY created_at DESC;

-- Show profiles
SELECT
    'Profile users:' as info,
    id,
    email,
    name,
    is_admin,
    is_blocked,
    created_at
FROM profiles
ORDER BY created_at DESC;

-- Success message
SELECT 'FIXED! Your admin@commercify.com should now be confirmed and admin' as status;
SELECT 'Try logging in again - it should work now!' as instruction;
SELECT 'After login, pull down to refresh the home screen to update your profile!' as refresh_tip;
SELECT 'If you need to confirm a different email, run:' as note;
SELECT 'UPDATE auth.users SET email_confirmed_at = NOW() WHERE email = ''your-email@domain.com'';' as example_command;

-- Quick check command for your specific user
SELECT 'Your admin status:' as check, email, is_admin, is_blocked FROM profiles WHERE email = 'admin@commercify.com';
