-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can view store categories" ON store_categories;
DROP POLICY IF EXISTS "Store owners can manage their store categories" ON store_categories;

-- Create new policies
CREATE POLICY "Anyone can view store categories"
  ON store_categories FOR SELECT
  USING (TRUE);

CREATE POLICY "Store owners can manage their store categories"
  ON store_categories FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM stores
      WHERE stores.id = store_categories.store_id
      AND stores.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM stores
      WHERE stores.id = store_categories.store_id
      AND stores.owner_id = auth.uid()
    )
  );
