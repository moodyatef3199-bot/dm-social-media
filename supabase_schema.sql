-- ============================================================
-- DREAMS MARKET — Complete Supabase Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- ── PROFILES (extends auth.users) ──────────────────────────
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'viewer'
    CHECK (role IN ('admin','marketing','designer','content_manager','media_buyer','viewer')),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active','disabled')),
  avatar_url TEXT,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── SOCIAL DATA ─────────────────────────────────────────────
CREATE TABLE public.social_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  platform TEXT NOT NULL CHECK (platform IN ('Facebook','Instagram','TikTok','YouTube','Snapchat','X')),
  month TEXT NOT NULL, -- YYYY-MM format
  reach BIGINT DEFAULT 0,
  impressions BIGINT DEFAULT 0,
  engagement DECIMAL(6,2) DEFAULT 0,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  saves INTEGER DEFAULT 0,
  followers_growth INTEGER DEFAULT 0,
  video_views BIGINT DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  messages INTEGER DEFAULT 0,
  orders INTEGER DEFAULT 0,
  revenue DECIMAL(12,2) DEFAULT 0,
  notes TEXT,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(platform, month)
);

-- ── ADS CAMPAIGNS ───────────────────────────────────────────
CREATE TABLE public.ads_campaigns (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  platform TEXT NOT NULL,
  objective TEXT,
  budget DECIMAL(12,2) DEFAULT 0,
  amount_spent DECIMAL(12,2) DEFAULT 0,
  start_date DATE,
  end_date DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active','paused','ended','draft')),
  -- Performance
  reach BIGINT DEFAULT 0,
  impressions BIGINT DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  ctr DECIMAL(6,3) DEFAULT 0,
  cpc DECIMAL(8,2) DEFAULT 0,
  cpm DECIMAL(8,2) DEFAULT 0,
  cpp DECIMAL(8,2) DEFAULT 0,
  -- Conversions
  messages INTEGER DEFAULT 0,
  leads INTEGER DEFAULT 0,
  orders INTEGER DEFAULT 0,
  revenue DECIMAL(12,2) DEFAULT 0,
  roas DECIMAL(6,2) DEFAULT 0,
  conversion_rate DECIMAL(6,2) DEFAULT 0,
  -- Computed fields (auto-calculated)
  profit DECIMAL(12,2) GENERATED ALWAYS AS (revenue - amount_spent) STORED,
  notes TEXT,
  tags TEXT[],
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── COMPETITORS ──────────────────────────────────────────────
CREATE TABLE public.competitors (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  business_type TEXT,
  website TEXT,
  -- Social links
  fb_page TEXT,
  ig_handle TEXT,
  tt_handle TEXT,
  yt_channel TEXT,
  sc_handle TEXT,
  x_handle TEXT,
  -- Metrics (manually tracked or AI-analyzed)
  fb_followers BIGINT DEFAULT 0,
  ig_followers BIGINT DEFAULT 0,
  tt_followers BIGINT DEFAULT 0,
  yt_subscribers BIGINT DEFAULT 0,
  total_followers BIGINT DEFAULT 0,
  avg_engagement DECIMAL(6,2) DEFAULT 0,
  posts_per_week INTEGER DEFAULT 0,
  content_type TEXT,
  posting_times TEXT,
  top_offer TEXT,
  top_hashtags TEXT[],
  -- Analysis
  strengths TEXT,
  weaknesses TEXT,
  opportunities TEXT,
  market_gap TEXT,
  content_ideas TEXT,
  ai_analysis JSONB,
  threat_level TEXT DEFAULT 'medium' CHECK (threat_level IN ('low','medium','high')),
  last_analyzed_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── CONTENT POSTS ────────────────────────────────────────────
CREATE TABLE public.content_posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  post_date DATE NOT NULL,
  platform TEXT NOT NULL,
  content_type TEXT, -- reels, carousel, story, post, video
  department TEXT,   -- bakery, butchery, vegetables, cheese, offers
  title TEXT NOT NULL,
  caption TEXT,
  hashtags TEXT,
  cta TEXT,
  goal TEXT CHECK (goal IN ('sales','engagement','awareness','promotion','hiring','brand','traffic')),
  target_audience TEXT,
  budget DECIMAL(10,2) DEFAULT 0,
  -- Status tracking
  design_status TEXT DEFAULT 'pending' CHECK (design_status IN ('pending','in_progress','review','done')),
  publish_status TEXT DEFAULT 'idea' CHECK (publish_status IN ('idea','in_design','ready','scheduled','published','cancelled')),
  published_at TIMESTAMPTZ,
  scheduled_at TIMESTAMPTZ,
  -- Performance (filled after publishing)
  actual_reach INTEGER,
  actual_engagement DECIMAL(6,2),
  actual_orders INTEGER,
  -- Meta
  notes TEXT,
  attachments TEXT[],
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── GOALS ────────────────────────────────────────────────────
CREATE TABLE public.goals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  month TEXT NOT NULL, -- YYYY-MM
  main_goal TEXT,
  -- Targets
  reach_target BIGINT DEFAULT 0,
  engagement_target DECIMAL(6,2) DEFAULT 0,
  orders_target INTEGER DEFAULT 0,
  followers_target INTEGER DEFAULT 0,
  ads_budget BIGINT DEFAULT 0,
  conversion_target DECIMAL(6,2) DEFAULT 0,
  posts_target INTEGER DEFAULT 0,
  messages_target INTEGER DEFAULT 0,
  views_target BIGINT DEFAULT 0,
  revenue_target DECIMAL(12,2) DEFAULT 0,
  -- Status
  status TEXT DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(month)
);

-- ── PLATFORM STRATEGIES ──────────────────────────────────────
CREATE TABLE public.platform_strategies (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  platform TEXT NOT NULL UNIQUE,
  goal TEXT,
  content_type TEXT,
  posting_frequency TEXT,
  target_audience TEXT,
  content_pillars TEXT,
  ad_strategy TEXT,
  kpi_reach BIGINT DEFAULT 0,
  kpi_engagement DECIMAL(6,2) DEFAULT 0,
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low','medium','high')),
  notes TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── NOTIFICATIONS ─────────────────────────────────────────────
CREATE TABLE public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── ACTIVITY LOG ─────────────────────────────────────────────
CREATE TABLE public.activity_log (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════
--  FUNCTIONS
-- ═══════════════════════════════════════════════

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_social_updated_at BEFORE UPDATE ON public.social_data FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_ads_updated_at BEFORE UPDATE ON public.ads_campaigns FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_competitors_updated_at BEFORE UPDATE ON public.competitors FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_posts_updated_at BEFORE UPDATE ON public.content_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_goals_updated_at BEFORE UPDATE ON public.goals FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'viewer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Compute ROAS automatically
CREATE OR REPLACE FUNCTION compute_roas()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.amount_spent > 0 THEN
    NEW.roas := ROUND((NEW.revenue / NEW.amount_spent)::DECIMAL, 2);
  ELSE
    NEW.roas := 0;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compute_roas BEFORE INSERT OR UPDATE ON public.ads_campaigns FOR EACH ROW EXECUTE FUNCTION compute_roas();

-- ═══════════════════════════════════════════════
--  ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ads_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;

-- Helper: get current user role
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Profiles policies
CREATE POLICY "read_own_profile" ON public.profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "admin_all_profiles" ON public.profiles FOR ALL USING (get_my_role() = 'admin');

-- Team data: all authenticated users can read, specific roles can write
CREATE POLICY "team_read_social" ON public.social_data FOR SELECT USING (auth.uid() IS NOT NULL AND is_deleted = FALSE);
CREATE POLICY "team_write_social" ON public.social_data FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND get_my_role() IN ('admin','marketing','content_manager'));
CREATE POLICY "team_update_social" ON public.social_data FOR UPDATE USING (auth.uid() IS NOT NULL AND get_my_role() IN ('admin','marketing'));
CREATE POLICY "soft_delete_social" ON public.social_data FOR UPDATE USING (get_my_role() = 'admin');

CREATE POLICY "team_read_ads" ON public.ads_campaigns FOR SELECT USING (auth.uid() IS NOT NULL AND is_deleted = FALSE);
CREATE POLICY "team_write_ads" ON public.ads_campaigns FOR INSERT WITH CHECK (get_my_role() IN ('admin','media_buyer'));
CREATE POLICY "team_update_ads" ON public.ads_campaigns FOR UPDATE USING (get_my_role() IN ('admin','media_buyer'));

CREATE POLICY "team_read_competitors" ON public.competitors FOR SELECT USING (auth.uid() IS NOT NULL AND is_deleted = FALSE);
CREATE POLICY "team_write_competitors" ON public.competitors FOR INSERT WITH CHECK (get_my_role() IN ('admin','marketing'));
CREATE POLICY "team_update_competitors" ON public.competitors FOR UPDATE USING (get_my_role() IN ('admin','marketing'));

CREATE POLICY "team_read_posts" ON public.content_posts FOR SELECT USING (auth.uid() IS NOT NULL AND is_deleted = FALSE);
CREATE POLICY "team_write_posts" ON public.content_posts FOR INSERT WITH CHECK (get_my_role() IN ('admin','marketing','content_manager'));
CREATE POLICY "team_update_posts" ON public.content_posts FOR UPDATE USING (get_my_role() IN ('admin','marketing','content_manager','designer'));

CREATE POLICY "team_read_goals" ON public.goals FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "admin_write_goals" ON public.goals FOR ALL USING (get_my_role() IN ('admin','marketing'));

CREATE POLICY "team_read_strategies" ON public.platform_strategies FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "admin_write_strategies" ON public.platform_strategies FOR ALL USING (get_my_role() IN ('admin','marketing'));

CREATE POLICY "own_notifications" ON public.notifications FOR ALL USING (user_id = auth.uid());
CREATE POLICY "admin_read_log" ON public.activity_log FOR SELECT USING (get_my_role() = 'admin');
CREATE POLICY "write_log" ON public.activity_log FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ═══════════════════════════════════════════════
--  VIEWS
-- ═══════════════════════════════════════════════

CREATE OR REPLACE VIEW public.dashboard_summary AS
SELECT
  (SELECT COUNT(*) FROM public.social_data WHERE is_deleted = FALSE) as social_records,
  (SELECT COALESCE(SUM(reach),0) FROM public.social_data WHERE is_deleted = FALSE) as total_reach,
  (SELECT COALESCE(AVG(engagement),0) FROM public.social_data WHERE is_deleted = FALSE) as avg_engagement,
  (SELECT COALESCE(SUM(orders),0) FROM public.social_data WHERE is_deleted = FALSE) as total_orders,
  (SELECT COUNT(*) FROM public.ads_campaigns WHERE is_deleted = FALSE) as total_campaigns,
  (SELECT COALESCE(SUM(amount_spent),0) FROM public.ads_campaigns WHERE is_deleted = FALSE) as total_spend,
  (SELECT COALESCE(AVG(roas),0) FROM public.ads_campaigns WHERE is_deleted = FALSE AND roas > 0) as avg_roas,
  (SELECT COUNT(*) FROM public.content_posts WHERE is_deleted = FALSE) as total_posts,
  (SELECT COUNT(*) FROM public.content_posts WHERE publish_status = 'published' AND is_deleted = FALSE) as published_posts,
  (SELECT COUNT(*) FROM public.competitors WHERE is_deleted = FALSE) as total_competitors;

-- ═══════════════════════════════════════════════
--  SEED DATA
-- ═══════════════════════════════════════════════

-- Default platform strategies
INSERT INTO public.platform_strategies (platform, goal, content_type, posting_frequency, target_audience, kpi_reach, kpi_engagement, priority) VALUES
('Facebook','Sales + Awareness','عروض، بوستات نصية، فيديو','يومي (1-2 بوست)','25-45 سنة، أسر مصرية',80000,6.5,'high'),
('Instagram','Engagement + Brand','ريلز، كاروسيل، ستوري','يومي (2-3 قطعة)','18-35 سنة، شباب',60000,12,'high'),
('TikTok','Awareness + Viral','ريلز قصيرة، خلف الكواليس','يومي (1-2 فيديو)','16-30 سنة',40000,9,'medium'),
('X','Engagement + CS','تغريدات، ردود','3-4 مرات/أسبوع','25-45 سنة',5000,3,'low'),
('YouTube','Awareness + SEO','فيديوهات تعليمية','أسبوعي','25-50 سنة',12000,4,'medium'),
('Snapchat','Offers + Youth','ستوري عروض','يومي','15-30 سنة',9000,5,'low')
ON CONFLICT (platform) DO NOTHING;
