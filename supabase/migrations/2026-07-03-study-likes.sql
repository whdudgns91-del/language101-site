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

do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'study_likes'
  ) then
    alter publication supabase_realtime add table public.study_likes;
  end if;
end $$;

notify pgrst, 'reload schema';
