-- ============================================================
-- EMR Ranking Dashboard — Login, Roles & Shared Comments setup
-- Run ONCE: Supabase -> SQL Editor -> New query -> paste all -> Run
-- ============================================================

-- 1) PROFILES: one row per user, holds their role (admin / editor / viewer)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'viewer' check (role in ('admin','editor','viewer')),
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;

-- helper: current user's role (security definer avoids RLS recursion)
create or replace function public.my_role() returns text
  language sql security definer stable as $$
  select role from public.profiles where id = auth.uid()
$$;

drop policy if exists "profiles read" on public.profiles;
create policy "profiles read" on public.profiles
  for select using (auth.uid() is not null);

drop policy if exists "profiles admin update" on public.profiles;
create policy "profiles admin update" on public.profiles
  for update using (public.my_role() = 'admin') with check (true);

drop policy if exists "profiles admin delete" on public.profiles;
create policy "profiles admin delete" on public.profiles
  for delete using (public.my_role() = 'admin');

-- auto-create a profile when someone signs up.
-- The VERY FIRST account becomes 'admin' automatically; everyone after = 'viewer'.
create or replace function public.handle_new_user() returns trigger
  language plpgsql security definer as $$
declare admin_count int;
begin
  select count(*) into admin_count from public.profiles where role = 'admin';
  insert into public.profiles (id, email, role)
  values (new.id, new.email, case when admin_count = 0 then 'admin' else 'viewer' end)
  on conflict (id) do nothing;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- 2) ANNOTATIONS: shared comments + keyword-name edits (editor/admin can write)
create table if not exists public.annotations (
  kw text primary key,
  edited_name text,
  comment text,
  updated_at timestamptz default now()
);
alter table public.annotations enable row level security;

drop policy if exists "annotations read" on public.annotations;
create policy "annotations read" on public.annotations for select using (true);

drop policy if exists "annotations insert" on public.annotations;
create policy "annotations insert" on public.annotations for insert
  with check (public.my_role() in ('admin','editor'));

drop policy if exists "annotations update" on public.annotations;
create policy "annotations update" on public.annotations for update
  using (public.my_role() in ('admin','editor')) with check (true);

drop policy if exists "annotations delete" on public.annotations;
create policy "annotations delete" on public.annotations for delete
  using (public.my_role() in ('admin','editor'));

-- ============================================================
-- AFTER you sign up your first account in the dashboard,
-- run this ONE line to make yourself ADMIN (change the email):
--
--   update public.profiles set role='admin' where email='YOUR_EMAIL_HERE';
-- ============================================================
