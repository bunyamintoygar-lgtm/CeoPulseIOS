-- 1. Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('opinion_attachments', 'opinion_attachments', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Clear existing policies for this bucket to avoid conflicts (optional but safer)
-- DROP POLICY IF EXISTS "Allow authenticated users to upload opinion attachments" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow public to view opinion attachments" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow users to delete their own opinion attachments" ON storage.objects;

-- 3. Policy: Allow authenticated users to upload files to 'opinion_attachments' bucket
CREATE POLICY "Allow authenticated users to upload opinion attachments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'opinion_attachments');

-- 4. Policy: Allow anyone to view files (Public access)
CREATE POLICY "Allow public to view opinion attachments"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'opinion_attachments');

-- 5. Policy: Allow users to delete/update their own files
CREATE POLICY "Allow users to manage their own opinion attachments"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'opinion_attachments' AND auth.uid() = owner);
