# Quick Fix Guide for Admin System

## Current Issue
You're getting a PostgreSQL infinite recursion error because of conflicting Row Level Security (RLS) policies on the `profiles` table.

## Step-by-Step Fix

### Step 1: Fix the Database (Run in Supabase SQL Editor)

```sql
-- Fix RLS policies to prevent infinite recursion
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

-- Re-enable RLS with simple policies
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
```

### Step 2: Create Your Admin User

After running the above SQL, update your user account to be an admin:

```sql
-- Replace 'admin@gmail.com' with your actual email address
UPDATE profiles 
SET is_admin = TRUE, 
    is_blocked = FALSE,
    updated_at = NOW()
WHERE email = 'admin@gmail.com';

-- Verify it worked
SELECT id, email, name, is_admin, is_blocked 
FROM profiles 
WHERE email = 'admin@gmail.com';
```

### Step 3: Create Reports Table (if needed)

```sql
-- Create reports table for admin system
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

-- Enable RLS and create policies
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reports"
  ON reports FOR SELECT
  USING (auth.uid() = reporter_id);

CREATE POLICY "Users can create reports"
  ON reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Service role can manage reports"
  ON reports FOR ALL
  USING (auth.role() = 'service_role');

GRANT ALL ON reports TO service_role;
```

### Step 4: Test the Fix

1. **Restart your app** (stop and run `flutter run` again)
2. **Try to register a new user** - the error should be gone
3. **Login with your admin account** - you should see the Admin button
4. **Access the admin dashboard** - all features should work

## How to Access Admin Features

1. **Create Admin Account:**
   - Use the admin setup screen (long-press app title on login)
   - OR register normally and then run the SQL to make yourself admin

2. **Login as Admin:**
   - Login with your admin credentials
   - You'll see an "Admin" button in the app
   - Click it to access the admin dashboard

3. **Admin Features Available:**
   - User Management (view, block, unblock users)
   - Category Management (create, edit, delete categories)
   - Advertisement Management (view, stop, delete ads)
   - Reports Management (handle user reports)

## Troubleshooting

### If you still get RLS errors:
```sql
-- Completely disable RLS temporarily
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE advertisements DISABLE ROW LEVEL SECURITY;
```

### If admin features don't show:
1. Verify your user has `is_admin = TRUE` in the database
2. Restart the app completely
3. Check that you're logged in with the correct account

### If you can't access admin functions:
- Make sure the service role has proper permissions
- Check that the admin controller is properly checking admin status

## Alternative: Use Supabase Dashboard

If SQL commands don't work, you can also:
1. Go to Supabase Dashboard → Table Editor
2. Find your user in the `profiles` table
3. Edit the row and set `is_admin` to `true`
4. Save the changes

## Success Indicators

✅ Registration works without errors
✅ Admin user shows "Admin" button when logged in
✅ Admin dashboard loads and shows management options
✅ All admin features are accessible

The admin system should now be fully functional! 🎉
