# Admin System Setup Guide

## Overview
The Matajir app includes a comprehensive admin system for managing users, categories, advertisements, and store reports.

## Admin Features
- **User Management**: View, block/unblock, and delete users
- **Category Management**: Create, edit, and manage categories and subcategories
- **Advertisement Management**: View, stop, and delete advertisements
- **Reports Management**: Handle store reports and user complaints

## Creating an Admin Account

### Step 1: Access Admin Setup
1. Open the app and go to the login screen
2. **Long press** on the app title "متاجر" (Matajir) at the top
3. This will open the Admin Setup screen

### Step 2: Create Admin Account
1. Fill in the admin details:
   - **Full Name**: Admin's full name
   - **Email**: Use a real email domain (gmail.com, yahoo.com, etc.)
   - **Phone Number**: Optional but recommended
   - **Password**: Strong password (minimum 6 characters)
   - **Confirm Password**: Must match the password

2. Click "Create Admin Account"

### Step 3: Activate Admin Privileges
After creating the account:
1. The account will be created as a regular user
2. **Manual activation required**: Admin privileges must be activated manually in the database
3. Update the `profiles` table in Supabase:
   ```sql
   UPDATE profiles 
   SET is_admin = true 
   WHERE email = 'your-admin-email@domain.com';
   ```

## Accessing Admin Dashboard

### For Admin Users
1. Login with your admin credentials
2. If you have admin privileges, you'll see an "Admin" button in the app
3. Click the Admin button to access the admin dashboard

### Admin Dashboard Features

#### User Management
- View all registered users
- Search users by name or email
- Block/unblock users with reasons
- Delete user accounts
- View user details and activity

#### Category Management
- Create new categories and subcategories
- Edit existing categories
- Set category images and grid sizes
- Activate/deactivate categories
- Delete categories

#### Advertisement Management
- View all advertisements
- Filter by status (active/inactive)
- Stop running advertisements
- Delete advertisements
- View advertisement details

#### Reports Management
- View store reports from users
- Filter reports by status
- Mark reports as under review
- Add admin notes to reports
- Dismiss reports with reasons

## Important Notes

### Email Validation
- Use real email domains (gmail.com, yahoo.com, outlook.com, etc.)
- Avoid fake domains like "commercify.com" as they will be rejected by Supabase

### Security
- Admin privileges are powerful - only grant to trusted users
- Regularly review admin actions and user reports
- Keep admin credentials secure

### Database Access
- Admin privilege activation requires direct database access
- Use Supabase dashboard or SQL client to update the `is_admin` field
- Ensure proper backup before making database changes

## Troubleshooting

### Email Validation Error
If you get "Email address invalid" error:
- Make sure you're using a real email domain
- Check for typos in the email address
- Try a different email provider (Gmail, Yahoo, Outlook)

### Admin Dashboard Not Showing
If the admin dashboard doesn't appear after login:
- Verify the `is_admin` field is set to `true` in the database
- Check that you're logged in with the correct admin account
- Try logging out and logging back in

### Cannot Access Admin Setup
- Make sure you're long-pressing the app title on the login screen
- The gesture should be held for about 1-2 seconds
- Try from the main login screen, not registration screen

## Support
For additional support or issues with the admin system, contact the development team.
