create table if not exists public.events (
  id text primary key,
  title text not null,
  event_date date,
  start_time time,
  end_time time,
  location text,
  image_url text,
  short_description text,
  detail_content text,
  price text,
  status text default '모집중',
  apply_url text,
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
  is_visible
) values (
  '2026-07-language101-drinking-party',
  '7월 언어교환101 술파티',
  '2026-07-25',
  '19:00',
  null,
  '종각 / 추후 공지',
  '',
  '외국인 친구들과 함께하는 언어교환101 월말 술파티입니다.',
  '7월에도 언어교환101 술파티가 열립니다.
영어, 일본어, 중국어를 공부하는 멤버들과 외국인 친구들이 함께 모여
편하게 대화하고 친해질 수 있는 네트워킹 파티입니다.

평소 스터디에서는 짧게 대화했던 사람들과 더 자연스럽게 친해지고,
새로운 외국인 친구도 만들 수 있는 자리입니다.

이런 분들에게 추천합니다.
- 외국인 친구를 만들고 싶은 분
- 영어로 자연스럽게 대화하고 싶은 분
- 언어교환101 멤버들과 더 친해지고 싶은 분
- 혼자 오기 어색하지만 새로운 사람을 만나고 싶은 분

참여 안내:
- 사전 신청 필수
- 선착순 마감
- 자세한 장소와 안내는 신청자에게 별도 공지',
  '추후 공지',
  '모집중',
  'https://pf.kakao.com/_xbMxiVxb',
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
  is_visible = excluded.is_visible,
  updated_at = now();
