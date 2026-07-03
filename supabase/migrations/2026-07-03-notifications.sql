create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  study_id text,
  type text not null,
  title text,
  message text,
  target_view text,
  is_read boolean default false,
  read_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz default now()
);

alter table public.notifications add column if not exists user_id text;
alter table public.notifications add column if not exists study_id text;
alter table public.notifications add column if not exists type text;
alter table public.notifications add column if not exists title text;
alter table public.notifications add column if not exists message text;
alter table public.notifications add column if not exists target_view text;
alter table public.notifications add column if not exists is_read boolean default false;
alter table public.notifications add column if not exists read_at timestamptz;
alter table public.notifications add column if not exists expires_at timestamptz;
alter table public.notifications add column if not exists created_at timestamptz default now();

create unique index if not exists notifications_user_study_type_unique
on public.notifications (user_id, study_id, type);

alter table public.notifications enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'notifications'
      and policyname = 'notifications_select_all'
  ) then
    create policy "notifications_select_all"
    on public.notifications
    for select
    using (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'notifications'
      and policyname = 'notifications_insert_all'
  ) then
    create policy "notifications_insert_all"
    on public.notifications
    for insert
    with check (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'notifications'
      and policyname = 'notifications_update_all'
  ) then
    create policy "notifications_update_all"
    on public.notifications
    for update
    using (true)
    with check (true);
  end if;
end $$;

notify pgrst, 'reload schema';
