create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  event_date date not null,
  start_time text,
  end_time text,
  location text,
  image_url text,
  short_description text,
  detail_content text,
  price text,
  status text default '모집중',
  apply_url text,
  detail_url text,
  is_visible boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.events add column if not exists title text;
alter table public.events add column if not exists event_date date;
alter table public.events add column if not exists start_time text;
alter table public.events add column if not exists end_time text;
alter table public.events add column if not exists location text;
alter table public.events add column if not exists image_url text;
alter table public.events add column if not exists short_description text;
alter table public.events add column if not exists detail_content text;
alter table public.events add column if not exists price text;
alter table public.events add column if not exists status text default '모집중';
alter table public.events add column if not exists apply_url text;
alter table public.events add column if not exists detail_url text;
alter table public.events add column if not exists is_visible boolean default true;
alter table public.events add column if not exists created_at timestamptz default now();
alter table public.events add column if not exists updated_at timestamptz default now();

alter table public.events enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'events'
      and policyname = 'events_select_all'
  ) then
    create policy "events_select_all"
    on public.events
    for select
    using (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'events'
      and policyname = 'events_insert_all'
  ) then
    create policy "events_insert_all"
    on public.events
    for insert
    with check (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'events'
      and policyname = 'events_update_all'
  ) then
    create policy "events_update_all"
    on public.events
    for update
    using (true)
    with check (true);
  end if;
end $$;

notify pgrst, 'reload schema';
