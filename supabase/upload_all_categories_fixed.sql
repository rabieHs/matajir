-- Script to upload all categories and subcategories to Supabase

-- First, make sure the categories table exists with the photo_url column
ALTER TABLE IF EXISTS categories ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Run Part 1 script
\i 'upload_categories_part1_fixed.sql'

-- Run Part 2 script
\i 'upload_categories_part2_fixed.sql'

-- Verify the data was inserted correctly
SELECT COUNT(*) AS total_categories FROM categories;
SELECT COUNT(*) AS main_categories FROM categories WHERE parent_id IS NULL;
SELECT COUNT(*) AS subcategories FROM categories WHERE parent_id IS NOT NULL;
