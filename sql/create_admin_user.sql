-- Create Admin User Script
-- Run this after you've successfully registered a user account

-- First, let's fix the RLS policies to prevent infinite recursion
-- Temporarily disable RLS on profiles
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Add admin columns if they don't exist
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Update your user to be an admin (replace 'admin@gmail.com' with your actual email)
UPDATE profiles 
SET is_admin = TRUE, 
    is_blocked = FALSE,
    updated_at = NOW()
WHERE email = 'admin@gmail.com';  -- Change this to your actual email

-- Re-enable RLS with simple policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop any existing problematic policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Create simple, safe policies
CREATE POLICY "Users can manage own profile"
  ON profiles FOR ALL
  USING (auth.uid() = id);

CREATE POLICY "Service role full access"
  ON profiles FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Authenticated users can view profiles"
  ON profiles FOR SELECT
  USING (auth.role() = 'authenticated');

-- Create reports table if it doesn't exist
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

-- Create policies for reports
CREATE POLICY "Users can view own reports"
  ON reports FOR SELECT
  USING (auth.uid() = reporter_id);

CREATE POLICY "Users can create reports"
  ON reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Service role can manage reports"
  ON reports FOR ALL
  USING (auth.role() = 'service_role');

-- Grant permissions
GRANT ALL ON profiles TO service_role;
GRANT ALL ON reports TO service_role;

-- Verify the admin user was created
SELECT id, email, name, is_admin, is_blocked, created_at 
FROM profiles 
WHERE email = 'admin@gmail.com';  -- Change this to your actual email

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Admin user setup completed!';
  RAISE NOTICE 'Please verify your email appears in the results above with is_admin = true';
END $$;
