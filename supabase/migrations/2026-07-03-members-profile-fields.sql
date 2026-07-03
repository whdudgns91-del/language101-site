create table if not exists public.members (
  id text primary key,
  name text not null,
  birth text,
  english_level text,
  my_level text,
  gender text,
  nationality text,
  age_group text,
  target_language text,
  joined_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.members add column if not exists name text;
alter table public.members add column if not exists birth text;
alter table public.members add column if not exists english_level text;
alter table public.members add column if not exists my_level text;
alter table public.members add column if not exists gender text;
alter table public.members add column if not exists nationality text;
alter table public.members add column if not exists age_group text;
alter table public.members add column if not exists target_language text;
alter table public.members add column if not exists joined_at timestamptz default now();
alter table public.members add column if not exists updated_at timestamptz default now();

update public.members
set my_level = coalesce(my_level, english_level)
where my_level is null and english_level is not null;

do $$
begin
  if to_regclass('public.users') is not null then
    alter table public.users add column if not exists gender text;
    alter table public.users add column if not exists nationality text;
    alter table public.users add column if not exists age_group text;
    alter table public.users add column if not exists english_level text;
    alter table public.users add column if not exists my_level text;
    alter table public.users add column if not exists target_language text;
  end if;
end $$;

alter table public.members enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'members' and policyname = 'members_select_all'
  ) then
    create policy members_select_all on public.members for select using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'members' and policyname = 'members_insert_all'
  ) then
    create policy members_insert_all on public.members for insert with check (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'members' and policyname = 'members_update_all'
  ) then
    create policy members_update_all on public.members for update using (true) with check (true);
  end if;
end $$;

notify pgrst, 'reload schema';
