alter table public.votes
  add column if not exists attended boolean default false;

alter table public.votes
  add column if not exists synced_to_sheet boolean default false;

alter table public.votes
  add column if not exists sheet_sync_status text default 'pending';

alter table public.votes
  add column if not exists sheet_synced_at timestamptz;

alter table public.votes
  alter column attended set default false;

alter table public.votes
  alter column synced_to_sheet set default false;

alter table public.votes
  alter column sheet_sync_status set default 'pending';

notify pgrst, 'reload schema';
