-- ================================================================
-- Dreams Market — Schema Fixes & Additions
-- Run this AFTER supabase_schema.sql if you get column errors
-- ================================================================

-- Add soft-delete columns if missing
ALTER TABLE social_data ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;
ALTER TABLE social_data ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE ads_campaigns ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;
ALTER TABLE ads_campaigns ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE ads_campaigns ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id);
ALTER TABLE competitors ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;
ALTER TABLE competitors ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE competitors ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id);
ALTER TABLE content_posts ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;
ALTER TABLE content_posts ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE content_posts ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id);
ALTER TABLE content_posts ADD COLUMN IF NOT EXISTS notes text;

-- Add competitor AI fields if missing
ALTER TABLE competitors ADD COLUMN IF NOT EXISTS content_ideas text;
ALTER TABLE competitors ADD COLUMN IF NOT EXISTS yt_channel text;
ALTER TABLE competitors ADD COLUMN IF NOT EXISTS last_analyzed_at timestamptz;

-- Ensure profiles has all needed columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_login timestamptz;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS status text DEFAULT 'active';

-- Activity log table (for audit trail)
CREATE TABLE IF NOT EXISTS activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  action text NOT NULL,
  table_name text,
  record_id uuid,
  old_values jsonb,
  new_values jsonb,
  created_at timestamptz DEFAULT now()
);

-- RLS for activity_log
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Admins can view logs" ON activity_log
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
CREATE POLICY IF NOT EXISTS "Authenticated users can insert logs" ON activity_log
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_social_data_platform ON social_data(platform);
CREATE INDEX IF NOT EXISTS idx_ads_campaigns_status ON ads_campaigns(status);
CREATE INDEX IF NOT EXISTS idx_content_posts_platform ON content_posts(platform);
CREATE INDEX IF NOT EXISTS idx_content_posts_publish_status ON content_posts(publish_status);
CREATE INDEX IF NOT EXISTS idx_competitors_threat_level ON competitors(threat_level);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Update profile trigger (auto-creates profile on signup)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username, full_name, role, status)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'viewer'),
    'active'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    last_login = now();
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Update last_login on sign-in
CREATE OR REPLACE FUNCTION public.handle_user_login()
RETURNS trigger AS $$
BEGIN
  UPDATE public.profiles SET last_login = now() WHERE id = new.id;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE OF last_sign_in_at ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_user_login();
