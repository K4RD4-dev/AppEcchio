-- APPecchio · Slice 1 backend schema (Supabase / Postgres)
-- Idempotent-ish initial migration: profiles + core domain tables + RLS.
-- Run in the Supabase SQL editor (or via `supabase db push`).

-- ---------------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type user_role as enum (
      'resident', 'tourist', 'merchant', 'organization',
      'supervisor', 'mayor', 'admin'
    );
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- profiles  (1:1 with auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  email       text,
  name        text not null default 'Utente',
  role        user_role not null default 'resident',
  settings    jsonb not null default '{
    "language": "Italiano",
    "notificationsEnabled": true,
    "locationEnabled": false,
    "analyticsEnabled": false,
    "marketingEnabled": false
  }'::jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles read own" on public.profiles;
create policy "profiles read own"
  on public.profiles for select using (auth.uid() = id);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own"
  on public.profiles for update using (auth.uid() = id);

drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own"
  on public.profiles for insert with check (auth.uid() = id);

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(nullif(new.raw_user_meta_data ->> 'name', ''), split_part(new.email, '@', 1)),
    coalesce((new.raw_user_meta_data ->> 'role')::user_role, 'resident')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Gamification  (per-user)
-- ---------------------------------------------------------------------------
create table if not exists public.gamification_state (
  user_id   uuid primary key references public.profiles (id) on delete cascade,
  xp        integer not null default 0,
  tokens    integer not null default 0,
  updated_at timestamptz not null default now()
);
alter table public.gamification_state enable row level security;
drop policy if exists "gamification own" on public.gamification_state;
create policy "gamification own"
  on public.gamification_state for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.reward_ledger (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  delta_xp   integer not null default 0,
  delta_tokens integer not null default 0,
  reason     text,
  created_at timestamptz not null default now()
);
alter table public.reward_ledger enable row level security;
drop policy if exists "ledger own" on public.reward_ledger;
create policy "ledger own"
  on public.reward_ledger for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.vouchers (
  id            bigint generated always as identity primary key,
  user_id       uuid not null references public.profiles (id) on delete cascade,
  code          text not null,
  label         text,
  discount_pct  integer not null default 0,
  status        text not null default 'attivo',
  merchant_name text,
  issued_at     timestamptz not null default now(),
  redeemed_at   timestamptz
);
alter table public.vouchers enable row level security;
drop policy if exists "vouchers own" on public.vouchers;
create policy "vouchers own"
  on public.vouchers for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Public catalog  (readable by any authenticated user; written later/backoffice)
-- ---------------------------------------------------------------------------
create table if not exists public.organizations (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  kind       text,
  owner_id   uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.organizations enable row level security;
drop policy if exists "orgs read" on public.organizations;
create policy "orgs read" on public.organizations for select using (auth.role() = 'authenticated');

create table if not exists public.merchants (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  org_id       uuid references public.organizations (id) on delete set null,
  cash_balance numeric not null default 0
);
alter table public.merchants enable row level security;
drop policy if exists "merchants read" on public.merchants;
create policy "merchants read" on public.merchants for select using (auth.role() = 'authenticated');

create table if not exists public.events (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  category   text,
  starts_at  timestamptz,
  ends_at    timestamptz,
  org_id     uuid references public.organizations (id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.events enable row level security;
drop policy if exists "events read" on public.events;
create policy "events read" on public.events for select using (auth.role() = 'authenticated');

create table if not exists public.event_participations (
  user_id   uuid not null references public.profiles (id) on delete cascade,
  event_id  uuid not null references public.events (id) on delete cascade,
  status    text not null default 'joined',
  joined_at timestamptz not null default now(),
  primary key (user_id, event_id)
);
alter table public.event_participations enable row level security;
drop policy if exists "participations own" on public.event_participations;
create policy "participations own"
  on public.event_participations for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.sport_reservations (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  slot_id    text not null,
  status     text not null default 'reserved',
  created_at timestamptz not null default now()
);
alter table public.sport_reservations enable row level security;
drop policy if exists "reservations own" on public.sport_reservations;
create policy "reservations own"
  on public.sport_reservations for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.trails (
  id        uuid primary key default gen_random_uuid(),
  name      text not null,
  gpx_url   text,
  source_url text,
  geometry  jsonb
);
alter table public.trails enable row level security;
drop policy if exists "trails read" on public.trails;
create policy "trails read" on public.trails for select using (true);
