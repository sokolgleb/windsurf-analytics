-- Windsurf Gliding Analytics: initial schema
-- Tables: spots, weather_hours, weather_sync_status

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ============================================================================
-- spots — preset and user-defined windsurf spots
-- ============================================================================
create table spots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  latitude real not null,
  longitude real not null,
  timezone text not null default 'UTC',
  description text,
  default_directions text[] not null default '{}',
  is_preset boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_spots_user_id on spots (user_id) where user_id is not null;
create index idx_spots_preset on spots (id) where is_preset = true;

-- ============================================================================
-- weather_hours — cached hourly wind data from Open-Meteo
-- ============================================================================
create table weather_hours (
  spot_id uuid not null references spots(id) on delete cascade,
  time timestamptz not null,
  wind_speed_kn real not null,
  wind_gust_kn real,
  wind_direction smallint not null,
  primary key (spot_id, time)
);

-- ============================================================================
-- weather_sync_status — tracks data freshness per spot
-- ============================================================================
create table weather_sync_status (
  spot_id uuid primary key references spots(id) on delete cascade,
  earliest_date date,
  latest_date date,
  last_synced_at timestamptz,
  sync_status text not null default 'pending'
    check (sync_status in ('pending', 'syncing', 'done', 'error'))
);

-- ============================================================================
-- RLS policies
-- ============================================================================
alter table spots enable row level security;
alter table weather_hours enable row level security;
alter table weather_sync_status enable row level security;

-- spots: everyone can read presets
create policy "Anyone can read preset spots"
  on spots for select
  using (is_preset = true);

-- spots: authenticated users can read their own
create policy "Users can read own spots"
  on spots for select
  using (auth.uid() = user_id);

-- spots: authenticated users can insert their own
create policy "Users can create own spots"
  on spots for insert
  with check (auth.uid() = user_id and is_preset = false);

-- spots: authenticated users can update their own
create policy "Users can update own spots"
  on spots for update
  using (auth.uid() = user_id and is_preset = false)
  with check (auth.uid() = user_id and is_preset = false);

-- spots: authenticated users can delete their own
create policy "Users can delete own spots"
  on spots for delete
  using (auth.uid() = user_id and is_preset = false);

-- weather_hours: everyone can read (public data)
create policy "Anyone can read weather data"
  on weather_hours for select
  using (true);

-- weather_sync_status: everyone can read
create policy "Anyone can read sync status"
  on weather_sync_status for select
  using (true);

-- Note: INSERT/UPDATE on weather_hours and weather_sync_status
-- is restricted to service_role (Edge Functions).
-- No explicit INSERT/UPDATE policies = only service_role can write.
