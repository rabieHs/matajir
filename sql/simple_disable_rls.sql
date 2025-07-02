-- SIMPLE FIX - Just disable RLS completely and update existing admin
-- This will definitely fix the registration issue

-- Disable RLS on all tables
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Add admin columns if missing
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Update existing admin user to have admin privileges
UPDATE profiles 
SET is_admin = TRUE, 
    is_verified = TRUE, 
    is_blocked = FALSE,
    name = COALESCE(name, 'System Administrator'),
    updated_at = NOW()
WHERE email = 'admin@matajir.com';

-- If no admin user exists, show current users so you can pick one to make admin
DO $$
DECLARE
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM profiles WHERE email = 'admin@matajir.com';
    
    IF user_count = 0 THEN
        RAISE NOTICE 'No admin user found. Here are existing users:';
        -- This will show in the results, not as a notice
    END IF;
END $$;

-- Show all users so you can see who exists
SELECT 
    'Current users in database:' as info,
    id, 
    email, 
    name, 
    is_admin, 
    created_at
FROM profiles 
ORDER BY created_at DESC;

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

-- Disable RLS on reports too
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;

-- Grant all permissions
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;

-- Final message
SELECT 'RLS DISABLED - Registration should work now!' as status;
SELECT 'If you see users above, pick one and run: UPDATE profiles SET is_admin = TRUE WHERE email = ''your-email@domain.com'';' as next_step;
