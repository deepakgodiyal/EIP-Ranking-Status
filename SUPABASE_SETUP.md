# Shared Comments + Edits — Supabase Setup (one-time, ~5 min)

Yeh tabhi chahiye jab aap chahte ho ki keyword edits aur comments **sabko dikhein** (real-time shared),
sirf aapke browser mein nahi. Backend = Supabase (free). Ek baar set karna hai, phir hamesha chalega.

## Steps

1. **Account banao:** https://supabase.com → "Start your project" → GitHub/Google se sign in (free).

2. **Naya project:** "New project" → koi naam (e.g. `emr-ranking`) → ek strong DB password (kahin note kar lo) → Region: nazdeeki (e.g. Mumbai/Singapore) → Create. ~2 min lagenge.

3. **Table banao:** left menu → **SQL Editor** → "New query" → neeche wala poora code paste karo → **Run**:

```sql
create table if not exists annotations (
  kw text primary key,
  edited_name text,
  comment text,
  updated_at timestamptz default now()
);
alter table annotations enable row level security;
create policy "public read"   on annotations for select using (true);
create policy "public insert" on annotations for insert with check (true);
create policy "public update" on annotations for update using (true) with check (true);
```

4. **Keys copy karo:** left menu → **Project Settings** (gear) → **API**. Wahan se do cheezein:
   - **Project URL** (e.g. `https://abcdxyz.supabase.co`)
   - **anon public** key (lamba token, "anon" / "public" wala — service_role NAHI).

5. **Mujhe dono bhej do** (URL + anon public key). Main dashboard mein daal ke "Shared" mode on kar dunga,
   phir Vercel par redeploy karte hi sabke comments/edits live shared ho jayenge.

## Notes
- anon key public hota hai (page mein dikhega) — yeh normal hai internal team tool ke liye. Koi bhi jise dashboard link mile woh comment kar/padh sakega.
- Shared mode **hosted site (Vercel) par best chalta hai.** Cowork ke andar preview mein external calls block ho sakte hain — woh normal hai.
- Jab tak Supabase connect nahi hota, feature **Local mode** mein chalta hai (badge "Local") — aapke browser mein save, dusron ko nahi dikhta.
