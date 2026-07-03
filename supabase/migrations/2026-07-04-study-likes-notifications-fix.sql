create table if not exists public.study_likes (
  id uuid primary key default gen_random_uuid(),
  study_id text not null,
  sender_user_id text not null,
  receiver_user_id text not null,
  created_at timestamptz default now(),
  constraint study_likes_no_self_like check (sender_user_id <> receiver_user_id)
);

alter table public.study_likes add column if not exists study_id text;
alter table public.study_likes add column if not exists sender_user_id text;
alter table public.study_likes add column if not exists receiver_user_id text;
alter table public.study_likes add column if not exists created_at timestamptz default now();

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'study_likes'
      and column_name = 'study_id'
      and data_type = 'uuid'
  ) then
    alter table public.study_likes alter column study_id type text using study_id::text;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'study_likes'
      and column_name = 'sender_user_id'
      and data_type = 'uuid'
  ) then
    alter table public.study_likes alter column sender_user_id type text using sender_user_id::text;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'study_likes'
      and column_name = 'receiver_user_id'
      and data_type = 'uuid'
  ) then
    alter table public.study_likes alter column receiver_user_id type text using receiver_user_id::text;
  end if;
end $$;

create unique index if not exists study_likes_unique_receiver
on public.study_likes (study_id, sender_user_id, receiver_user_id);

alter table public.study_likes enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'study_likes'
      and policyname = 'study_likes_select_all'
  ) then
    create policy "study_likes_select_all"
    on public.study_likes
    for select
    using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'study_likes'
      and policyname = 'study_likes_insert_all'
  ) then
    create policy "study_likes_insert_all"
    on public.study_likes
    for insert
    with check (true);
  end if;
end $$;

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

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'study_likes'
    ) then
      alter publication supabase_realtime add table public.study_likes;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'notifications'
    ) then
      alter publication supabase_realtime add table public.notifications;
    end if;
  end if;
end $$;

notify pgrst, 'reload schema';
