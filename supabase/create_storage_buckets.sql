-- Create storage buckets for the application

-- Create advertisements bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'advertisements',
  'advertisements',
  true,
  52428800, -- 50MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- Create images bucket if it doesn't exist (for stores)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images',
  'images',
  true,
  52428800, -- 50MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- Set up RLS policies for advertisements bucket
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload advertisement images to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'advertisements' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow authenticated users to update their own advertisement images
CREATE POLICY "Users can update their own advertisement images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'advertisements' AND (storage.foldername(name))[1] = auth.uid()::text)
WITH CHECK (bucket_id = 'advertisements' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow authenticated users to delete their own advertisement images
CREATE POLICY "Users can delete their own advertisement images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'advertisements' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow public read access to advertisement images
CREATE POLICY "Anyone can view advertisement images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'advertisements');

-- Set up RLS policies for images bucket (stores)
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload store images to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow authenticated users to update their own store images
CREATE POLICY "Users can update their own store images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'images' AND (storage.foldername(name))[1] = auth.uid()::text)
WITH CHECK (bucket_id = 'images' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow authenticated users to delete their own store images
CREATE POLICY "Users can delete their own store images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'images' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Allow public read access to store images
CREATE POLICY "Anyone can view store images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'images');
