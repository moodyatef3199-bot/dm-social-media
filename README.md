# 🛒 Dreams Market — نظام إدارة التسويق الرقمي

**Next.js 14 + Supabase + Vercel | Full-Stack Marketing Dashboard**

---

## 🚀 Quick Deploy (3 Steps)

### Step 1 — Supabase
1. [supabase.com](https://supabase.com) → New Project
2. SQL Editor → paste `supabase_schema.sql` → **Run**
3. Settings → API → copy **Project URL** + **anon key**
4. Authentication → Settings → enable **Email** provider
5. Create admin: Authentication → Users → Invite, then run:
   ```sql
   UPDATE public.profiles SET role = 'admin' WHERE email = 'your@email.com';
   ```

### Step 2 — GitHub
```bash
git init && git add . && git commit -m "Dreams Market v7"
git remote add origin https://github.com/YOUR_USERNAME/dm-app.git
git push -u origin main
```

### Step 3 — Vercel
1. [vercel.com](https://vercel.com) → Import Git Repo
2. Add Environment Variables:
   | Variable | Value |
   |---|---|
   | `NEXT_PUBLIC_SUPABASE_URL` | `https://xxxxx.supabase.co` |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbGc...` |
   | `ANTHROPIC_API_KEY` | `sk-ant-api03-...` |
   | `SUPABASE_SERVICE_ROLE_KEY` | (optional, for admin user creation) |
3. Deploy → **Done!** 🎉

---

## 📁 Project Structure
```
dm-app/
├── src/
│   ├── app/
│   │   ├── page.tsx                 # Main app (auth-protected)
│   │   ├── layout.tsx               # Root layout + fonts
│   │   ├── login/page.tsx           # Login + Register
│   │   └── api/
│   │       ├── dashboard/route.ts   # KPIs, alerts, trends
│   │       ├── social/route.ts      # Social media CRUD
│   │       ├── ads/route.ts         # Campaigns CRUD
│   │       ├── competitors/route.ts # Competitor tracking + AI
│   │       ├── posts/route.ts       # Content planner CRUD
│   │       ├── goals/route.ts       # Monthly goals CRUD
│   │       ├── reports/route.ts     # Analytics reports
│   │       ├── users/route.ts       # User management (admin)
│   │       └── auth/ai/route.ts     # Claude AI integration
│   ├── components/
│   │   ├── DreamsMarketClient.tsx   # App shell + sidebar
│   │   ├── LoginForm.tsx            # Auth forms
│   │   ├── ui/index.tsx             # Full UI component library
│   │   └── pages/                  # 9 page components
│   ├── lib/supabase.ts              # Supabase client + types
│   └── middleware.ts                # Auth middleware
├── supabase_schema.sql              # Complete DB schema + RLS
├── vercel.json                      # Vercel config
├── .env.example                     # Env variables template
└── package.json                     # Dependencies
```

---

## 👥 Role System
| Role | Pages | Edit | Ads | Users |
|---|---|---|---|---|
| `admin` | All | ✅ | ✅ | ✅ |
| `marketing` | Dashboard, Social, Content, Competitors, Goals, Reports | ✅ | 👁 | ❌ |
| `media_buyer` | Dashboard, Ads, Reports | ✅ | ✅ | ❌ |
| `content_manager` | Dashboard, Content, Goals, Reports | ✅ | ❌ | ❌ |
| `designer` | Content | ❌ | ❌ | ❌ |
| `viewer` | Dashboard, Reports | ❌ | ❌ | ❌ |

---

## 🛠 Local Development
```bash
cp .env.example .env.local
# Fill in your Supabase + Anthropic keys
npm install
npm run dev
# → http://localhost:3000
```

---

## 📊 Features
- 🔐 Auth (Login, Register, Role-based access)
- 📊 Executive Dashboard (KPIs, charts, alerts)
- 📱 Social Media Manager (Facebook, Instagram, TikTok, YouTube...)
- 📢 Ads Manager (ROAS, CPC, CPM, profit tracking)
- 🏆 Competitor Analysis + AI insights (Claude)
- 📅 Content Planner (design workflow + AI caption generation)
- 🎯 Monthly Goals + progress tracking
- 📄 Reports (monthly analytics + PDF export)
- 👥 User Management (admin only)
- ☁️ Multi-user, online, all data in Supabase PostgreSQL
