create table if not exists public.daily_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  checkin_date date not null,
  points_awarded integer default 10,
  created_at timestamptz default now()
);

alter table public.daily_checkins add column if not exists user_id text;
alter table public.daily_checkins add column if not exists checkin_date date;
alter table public.daily_checkins add column if not exists points_awarded integer default 10;
alter table public.daily_checkins add column if not exists created_at timestamptz default now();

create unique index if not exists daily_checkins_user_date_unique
on public.daily_checkins (user_id, checkin_date);

alter table public.daily_checkins enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'daily_checkins'
      and policyname = 'daily_checkins_select_all'
  ) then
    create policy "daily_checkins_select_all"
    on public.daily_checkins
    for select
    using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'daily_checkins'
      and policyname = 'daily_checkins_insert_all'
  ) then
    create policy "daily_checkins_insert_all"
    on public.daily_checkins
    for insert
    with check (true);
  end if;
end $$;

notify pgrst, 'reload schema';
