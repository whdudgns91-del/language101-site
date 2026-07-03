alter table public.votes
  add column if not exists attended boolean not null default false,
  add column if not exists synced_to_sheet boolean not null default false,
  add column if not exists sheet_sync_status text not null default 'pending',
  add column if not exists sheet_synced_at timestamptz;

alter table public.votes
  alter column sheet_sync_status set default 'pending';

create index if not exists votes_sheet_sync_idx
  on public.votes (level, synced_to_sheet, sheet_sync_status);

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'votes'
      and policyname = 'Allow anon update votes'
  ) then
    create policy "Allow anon update votes"
      on public.votes
      for update
      to anon
      using (true)
      with check (true);
  end if;
end $$;

notify pgrst, 'reload schema';
