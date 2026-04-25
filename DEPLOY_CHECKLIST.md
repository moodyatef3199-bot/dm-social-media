# ✅ Dreams Market — Deployment Checklist

## 1. Supabase Setup
- [ ] Create new Supabase project at supabase.com
- [ ] Run `supabase_schema.sql` in SQL Editor
- [ ] Run `supabase_fixes.sql` in SQL Editor (adds missing columns + triggers)
- [ ] Enable Email auth in Authentication → Settings
- [ ] Copy Project URL and anon key

## 2. Create Admin User
- [ ] Authentication → Users → "Invite user" with your email
- [ ] Open the invite email and set your password
- [ ] Run in SQL Editor:
  ```sql
  UPDATE public.profiles SET role = 'admin' WHERE email = 'YOUR_EMAIL';
  ```

## 3. GitHub
- [ ] `git init` in dm-app folder
- [ ] `git add .`
- [ ] `git commit -m "Dreams Market v7 — initial"`
- [ ] Create repo on github.com
- [ ] `git remote add origin YOUR_REPO_URL`
- [ ] `git push -u origin main`

## 4. Vercel
- [ ] Sign in at vercel.com → "Add New Project"
- [ ] Import your GitHub repo
- [ ] Add environment variables:
  - [ ] `NEXT_PUBLIC_SUPABASE_URL`
  - [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - [ ] `ANTHROPIC_API_KEY`
  - [ ] `SUPABASE_SERVICE_ROLE_KEY` (optional)
- [ ] Click Deploy
- [ ] Wait ~2 minutes for build

## 5. Post-Deploy Verify
- [ ] Visit your Vercel URL
- [ ] Login with admin account
- [ ] Check Dashboard loads correctly
- [ ] Test Social data entry (add one row)
- [ ] Test AI feature (Competitors → Analyze)
- [ ] Create a second user with a different role
- [ ] Verify role permissions work correctly

## 🔥 Common Issues

| Problem | Solution |
|---|---|
| "Invalid API key" | Check NEXT_PUBLIC_SUPABASE_ANON_KEY in Vercel env vars |
| "relation does not exist" | Run supabase_fixes.sql in Supabase SQL Editor |
| Profile not created on signup | Check the trigger in supabase_fixes.sql was run |
| AI not working | Add ANTHROPIC_API_KEY to Vercel env vars |
| Login redirects back to login | Clear browser cookies and try again |
