alter table public.events
add column if not exists detail_url text;

notify pgrst, 'reload schema';
