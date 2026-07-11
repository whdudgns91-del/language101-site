create table if not exists public.votes (
  id uuid primary key default gen_random_uuid()
);

alter table public.votes
  add column if not exists id uuid default gen_random_uuid();

alter table public.votes
  alter column id set default gen_random_uuid();

alter table public.votes add column if not exists study_id text;
alter table public.votes add column if not exists user_id text;
alter table public.votes add column if not exists name text;
alter table public.votes add column if not exists birth text;
alter table public.votes add column if not exists level text;
alter table public.votes add column if not exists vote_option text;
alter table public.votes add column if not exists attended boolean default false;
alter table public.votes add column if not exists synced_to_sheet boolean default false;
alter table public.votes add column if not exists cancelled boolean default false;
alter table public.votes add column if not exists created_at timestamptz default now();
alter table public.votes add column if not exists updated_at timestamptz default now();

update public.votes
set
  id = coalesce(id, gen_random_uuid()),
  birth = coalesce(birth, nullif(split_part(user_id, '|', 1), '')),
  level = coalesce(level, vote_option),
  vote_option = coalesce(vote_option, level),
  attended = coalesce(attended, false),
  synced_to_sheet = coalesce(synced_to_sheet, false),
  cancelled = coalesce(cancelled, false),
  created_at = coalesce(created_at, now()),
  updated_at = coalesce(updated_at, created_at, now());

do $$
begin
  if not exists (
    select 1
    from public.votes
    where birth is null or birth = ''
  ) then
    alter table public.votes alter column birth set not null;
  end if;
end $$;

alter table public.votes alter column vote_option drop not null;

create index if not exists votes_study_user_idx
  on public.votes (study_id, user_id);

create index if not exists votes_study_name_birth_idx
  on public.votes (study_id, name, birth);

create index if not exists votes_study_cancelled_idx
  on public.votes (study_id, cancelled);

alter table public.votes enable row level security;

drop policy if exists votes_select_all on public.votes;
drop policy if exists votes_insert_all on public.votes;
drop policy if exists votes_update_all on public.votes;

create policy votes_select_all
on public.votes
for select
using (true);

create policy votes_insert_all
on public.votes
for insert
with check (true);

create policy votes_update_all
on public.votes
for update
using (true)
with check (true);
