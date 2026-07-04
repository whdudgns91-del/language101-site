alter table public.events add column if not exists deleted_at timestamptz;
alter table public.events add column if not exists image_fit text default 'cover';
alter table public.events add column if not exists event_type text;
alter table public.events add column if not exists max_participants integer default 0;

drop policy if exists events_update_all on public.events;

create policy events_update_all
on public.events
for update
using (true)
with check (true);

notify pgrst, 'reload schema';
