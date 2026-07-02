alter table public.events
add column if not exists id text;

update public.events
set id = 'event-' || md5(
  coalesce(title, '') || '-' ||
  coalesce(event_date::text, '') || '-' ||
  coalesce(created_at::text, now()::text)
)
where id is null or id = '';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.events'::regclass
      and contype = 'p'
  ) then
    alter table public.events
    add constraint events_pkey primary key (id);
  end if;
end $$;

alter table public.events
add column if not exists title text,
add column if not exists event_date date,
add column if not exists start_time time,
add column if not exists end_time time,
add column if not exists location text,
add column if not exists image_url text,
add column if not exists short_description text,
add column if not exists detail_content text,
add column if not exists price text,
add column if not exists status text default '모집중',
add column if not exists apply_url text,
add column if not exists is_visible boolean default true,
add column if not exists created_at timestamptz default now(),
add column if not exists updated_at timestamptz default now();

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'events_status_check'
      and conrelid = 'public.events'::regclass
  ) then
    alter table public.events
    add constraint events_status_check
    check (status in ('모집중', '마감임박', '마감'));
  end if;
end $$;
