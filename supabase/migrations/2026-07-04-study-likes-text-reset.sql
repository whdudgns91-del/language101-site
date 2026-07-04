drop table if exists public.study_likes;

create table public.study_likes (
  id uuid primary key default gen_random_uuid(),
  study_id text not null,
  sender_user_id text not null,
  receiver_user_id text not null,
  created_at timestamptz default now(),
  unique (study_id, sender_user_id, receiver_user_id)
);

alter table public.study_likes enable row level security;

drop policy if exists study_likes_select_all on public.study_likes;
drop policy if exists study_likes_insert_all on public.study_likes;

create policy study_likes_select_all
on public.study_likes
for select
using (true);

create policy study_likes_insert_all
on public.study_likes
for insert
with check (true);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  study_id text,
  type text,
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

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'notifications'
      and column_name = 'user_id'
      and data_type = 'uuid'
  ) then
    alter table public.notifications alter column user_id type text using user_id::text;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'notifications'
      and column_name = 'study_id'
      and data_type = 'uuid'
  ) then
    alter table public.notifications alter column study_id type text using study_id::text;
  end if;
end $$;

drop policy if exists notifications_select_all on public.notifications;
drop policy if exists notifications_insert_all on public.notifications;
drop policy if exists notifications_update_all on public.notifications;

alter table public.notifications enable row level security;

create policy notifications_select_all
on public.notifications
for select
using (true);

create policy notifications_insert_all
on public.notifications
for insert
with check (true);

create policy notifications_update_all
on public.notifications
for update
using (true)
with check (true);

notify pgrst, 'reload schema';
