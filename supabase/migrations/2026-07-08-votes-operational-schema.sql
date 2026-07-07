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
set id = gen_random_uuid()
where id is null;

update public.votes
set
  study_id = coalesce(study_id, level),
  updated_at = coalesce(updated_at, created_at, now())
where study_id is null
   or updated_at is null;

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'votes' and column_name = 'birth'
  ) then
    execute $sql$
      update public.votes
      set user_id = coalesce(user_id, birth || '|' || lower(trim(name)))
      where user_id is null and birth is not null and name is not null
    $sql$;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'votes' and column_name = 'vote_option'
  ) then
    execute $sql$
      update public.votes
      set
        level = case
          when vote_option is not null and vote_option <> '__cancelled__' then vote_option
          else level
        end,
        cancelled = coalesce(cancelled, vote_option = '__cancelled__', false)
      where vote_option is not null or cancelled is null
    $sql$;
  end if;
end $$;

update public.votes
set cancelled = false
where cancelled is null;

create index if not exists votes_study_cancelled_idx
  on public.votes (study_id, cancelled);

create index if not exists votes_user_study_idx
  on public.votes (user_id, study_id);

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
