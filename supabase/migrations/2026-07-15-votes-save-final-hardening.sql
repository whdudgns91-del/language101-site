create table if not exists public.votes (
  id uuid primary key default gen_random_uuid()
);

alter table public.votes
  add column if not exists id uuid default gen_random_uuid();

alter table public.votes
  add column if not exists study_id text,
  add column if not exists user_id text,
  add column if not exists name text,
  add column if not exists birth text,
  add column if not exists level text,
  add column if not exists vote_option text,
  add column if not exists attended boolean default false,
  add column if not exists synced_to_sheet boolean default false,
  add column if not exists cancelled boolean default false,
  add column if not exists is_ghost boolean default false,
  add column if not exists ghost_batch_id text,
  add column if not exists ghost_display_name text,
  add column if not exists vote_closed_at timestamptz,
  add column if not exists created_at timestamptz default now(),
  add column if not exists updated_at timestamptz default now();

alter table public.votes
  alter column id set default gen_random_uuid(),
  alter column attended set default false,
  alter column synced_to_sheet set default false,
  alter column cancelled set default false,
  alter column is_ghost set default false,
  alter column created_at set default now(),
  alter column updated_at set default now();

update public.votes
set
  id = coalesce(id, gen_random_uuid()),
  name = coalesce(nullif(name, ''), nullif(ghost_display_name, ''), nullif(user_id, ''), 'Unknown'),
  birth = coalesce(nullif(birth, ''), nullif(regexp_replace(split_part(coalesce(user_id, ''), '|', 1), '\D', '', 'g'), ''), '000000'),
  level = coalesce(nullif(level, ''), nullif(vote_option, ''), 'I''m not sure yet'),
  vote_option = coalesce(nullif(vote_option, ''), nullif(level, ''), 'I''m not sure yet'),
  attended = coalesce(attended, false),
  synced_to_sheet = coalesce(synced_to_sheet, false),
  cancelled = coalesce(cancelled, false),
  is_ghost = coalesce(is_ghost, user_id like 'ghost:%', false),
  created_at = coalesce(created_at, now()),
  updated_at = coalesce(updated_at, created_at, now());

alter table public.votes
  alter column name set not null,
  alter column birth set not null,
  alter column vote_option set not null;

create index if not exists votes_study_user_idx
  on public.votes (study_id, user_id);

create index if not exists votes_study_name_birth_idx
  on public.votes (study_id, name, birth);

create index if not exists votes_study_cancelled_idx
  on public.votes (study_id, cancelled);

create index if not exists votes_study_ghost_level_idx
  on public.votes (study_id, is_ghost, cancelled, level);

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
