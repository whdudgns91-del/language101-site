alter table public.votes
  add column if not exists is_ghost boolean default false;

alter table public.votes
  add column if not exists ghost_batch_id text;

alter table public.votes
  add column if not exists ghost_display_name text;

alter table public.votes
  add column if not exists vote_closed_at timestamptz;

update public.votes
set is_ghost = true
where user_id like 'ghost:%';

create index if not exists votes_study_ghost_level_idx
  on public.votes (study_id, is_ghost, cancelled, level);

create index if not exists votes_study_created_idx
  on public.votes (study_id, created_at);

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
