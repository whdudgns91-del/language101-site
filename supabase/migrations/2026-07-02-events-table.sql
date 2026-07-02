create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  event_date date not null,
  start_time text,
  end_time text,
  location text,
  image_url text,
  short_description text,
  detail_content text,
  price text,
  status text default '모집중',
  apply_url text,
  detail_url text,
  is_visible boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.events enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'events'
      and policyname = 'events_select_anon'
  ) then
    create policy "events_select_anon"
    on public.events
    for select
    to anon
    using (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'events'
      and policyname = 'events_insert_anon'
  ) then
    create policy "events_insert_anon"
    on public.events
    for insert
    to anon
    with check (true);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'events'
      and policyname = 'events_update_anon'
  ) then
    create policy "events_update_anon"
    on public.events
    for update
    to anon
    using (true)
    with check (true);
  end if;
end $$;

insert into public.events (
  id,
  title,
  event_date,
  start_time,
  end_time,
  location,
  image_url,
  short_description,
  detail_content,
  price,
  status,
  apply_url,
  detail_url,
  is_visible
) values (
  '00000000-0000-4000-8000-000020260725',
  '7월 언어교환101 술파티 🍻',
  '2026-07-25',
  '19:00',
  '22:00',
  '종각 / 추후 공지',
  '',
  '외국인 친구들과 함께하는 월말 술파티!',
  '7월에도 언어교환101 술파티가 열립니다.
영어, 일본어, 중국어를 공부하는 멤버들과 외국인 친구들이 함께 모여 편하게 대화하고 친해질 수 있는 네트워킹 파티입니다.',
  '31,000원~',
  '모집중',
  'https://forms.gle/y239zmAiwcNMvTXg6',
  'https://blog.naver.com/bonsin11/224334559759',
  true
) on conflict (id) do update set
  title = excluded.title,
  event_date = excluded.event_date,
  start_time = excluded.start_time,
  end_time = excluded.end_time,
  location = excluded.location,
  short_description = excluded.short_description,
  detail_content = excluded.detail_content,
  price = excluded.price,
  status = excluded.status,
  apply_url = excluded.apply_url,
  detail_url = excluded.detail_url,
  is_visible = excluded.is_visible,
  updated_at = now();
