-- Admin System Database Updates
-- Run this SQL file to add admin functionality to your database

-- Add admin fields to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_reason TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES profiles(id);

-- Create reports table for store reporting
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reported_store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending', -- 'pending', 'reviewed', 'resolved', 'dismissed'
    reviewed_by UUID REFERENCES profiles(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON profiles(is_admin);
CREATE INDEX IF NOT EXISTS idx_profiles_is_blocked ON profiles(is_blocked);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported_store_id ON reports(reported_store_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported_user_id ON reports(reported_user_id);

-- Enable RLS on reports table
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for reports
-- Users can view their own reports
CREATE POLICY "Users can view their own reports"
  ON reports FOR SELECT
  USING (auth.uid() = reporter_id);

-- Users can create reports
CREATE POLICY "Users can create reports"
  ON reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

-- Service role can manage reports (for admin operations)
CREATE POLICY "Service role can manage reports"
  ON reports FOR ALL
  USING (auth.role() = 'service_role');

-- First, let's drop any existing conflicting policies on profiles
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Create a function to safely check admin status
CREATE OR REPLACE FUNCTION is_admin_user(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = user_id AND is_admin = TRUE AND is_blocked = FALSE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create simplified RLS policies for profiles
-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Service role can do everything (for admin operations)
CREATE POLICY "Service role full access"
  ON profiles FOR ALL
  USING (auth.role() = 'service_role');

-- Update RLS policies for categories to allow admin management
-- Drop existing policies first
DROP POLICY IF EXISTS "Admins can manage categories" ON categories;

-- Service role can manage categories (for admin operations)
CREATE POLICY "Service role can manage categories"
  ON categories FOR ALL
  USING (auth.role() = 'service_role');

-- Update RLS policies for advertisements to allow admin management
-- Drop existing policies first
DROP POLICY IF EXISTS "Admins can view all advertisements" ON advertisements;
DROP POLICY IF EXISTS "Admins can update all advertisements" ON advertisements;
DROP POLICY IF EXISTS "Admins can delete all advertisements" ON advertisements;

-- Service role can manage advertisements (for admin operations)
CREATE POLICY "Service role can manage advertisements"
  ON advertisements FOR ALL
  USING (auth.role() = 'service_role');

-- Create a function to check if user is blocked during authentication
CREATE OR REPLACE FUNCTION check_user_blocked()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the user is blocked
  IF EXISTS (
    SELECT 1 FROM profiles
    WHERE id = NEW.id AND is_blocked = TRUE
  ) THEN
    RAISE EXCEPTION 'User account is blocked. Please contact support.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to check blocked status on auth
-- Note: This trigger will be on auth.users table if you have access
-- Otherwise, implement the check in your application logic

-- Insert a default admin user (you should change the email and set proper password)
-- This is just for initial setup - you should create your admin account properly
INSERT INTO profiles (id, email, name, is_admin, is_verified, created_at, updated_at)
VALUES (
  uuid_generate_v4(),
  'admin@matajir.com', -- Change this to your admin email
  'System Administrator',
  TRUE,
  TRUE,
  NOW(),
  NOW()
) ON CONFLICT (email) DO UPDATE SET
  is_admin = TRUE,
  is_verified = TRUE,
  updated_at = NOW();

-- Create updated_at trigger for reports table
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_reports_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE reports IS 'Store and user reports submitted by users for admin review';
COMMENT ON COLUMN profiles.is_admin IS 'Whether the user has admin privileges';
COMMENT ON COLUMN profiles.is_blocked IS 'Whether the user account is blocked';
COMMENT ON COLUMN profiles.blocked_at IS 'When the user was blocked';
COMMENT ON COLUMN profiles.blocked_reason IS 'Reason for blocking the user';
COMMENT ON COLUMN profiles.blocked_by IS 'Admin who blocked the user';
