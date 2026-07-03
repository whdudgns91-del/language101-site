alter table public.events
add column if not exists deleted_at timestamptz;

alter table public.events
add column if not exists image_fit text default 'cover';

notify pgrst, 'reload schema';
