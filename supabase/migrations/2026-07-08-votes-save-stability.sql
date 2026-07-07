create table if not exists public.votes (
  id uuid primary key default gen_random_uuid()
);

alter table public.votes
  add column if not exists id uuid default gen_random_uuid();

alter table public.votes
  alter column id set default gen_random_uuid();

alter table public.votes
  add column if not exists study_id text,
  add column if not exists user_id text,
  add column if not exists name text,
  add column if not exists level text,
  add column if not exists attended boolean default false,
  add column if not exists synced_to_sheet boolean default false,
  add column if not exists cancelled boolean default false,
  add column if not exists created_at timestamptz default now(),
  add column if not exists updated_at timestamptz default now();

update public.votes
set
  id = coalesce(id, gen_random_uuid()),
  attended = coalesce(attended, false),
  synced_to_sheet = coalesce(synced_to_sheet, false),
  cancelled = coalesce(cancelled, false),
  created_at = coalesce(created_at, now()),
  updated_at = coalesce(updated_at, created_at, now());

create index if not exists votes_study_user_idx
  on public.votes (study_id, user_id);

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
