-- Automatically clean old voting and log data only.
-- Never deletes member/profile/point/level/attendance/like data.

create extension if not exists pg_cron with schema extensions;

do $$
begin
  if not exists (
    select 1
    from cron.job
    where jobname = 'cleanup_old_data'
  ) then
    perform cron.schedule(
      'cleanup_old_data',
      '0 3 * * *',
      $cron$
        DELETE FROM public.votes
        WHERE created_at < NOW() - INTERVAL '180 days';

        do $cleanup$
        begin
          if to_regclass('public.error_logs') is not null
            and exists (
              select 1
              from information_schema.columns
              where table_schema = 'public'
                and table_name = 'error_logs'
                and column_name = 'created_at'
            ) then
            delete from public.error_logs
            where created_at < now() - interval '30 days';
          end if;

          if to_regclass('public.logs') is not null
            and exists (
              select 1
              from information_schema.columns
              where table_schema = 'public'
                and table_name = 'logs'
                and column_name = 'created_at'
            ) then
            delete from public.logs
            where created_at < now() - interval '30 days';
          end if;

          if to_regclass('public.app_logs') is not null
            and exists (
              select 1
              from information_schema.columns
              where table_schema = 'public'
                and table_name = 'app_logs'
                and column_name = 'created_at'
            ) then
            delete from public.app_logs
            where created_at < now() - interval '30 days';
          end if;

          if to_regclass('public.access_logs') is not null
            and exists (
              select 1
              from information_schema.columns
              where table_schema = 'public'
                and table_name = 'access_logs'
                and column_name = 'created_at'
            ) then
            delete from public.access_logs
            where created_at < now() - interval '90 days';
          end if;

          if to_regclass('public.visit_logs') is not null
            and exists (
              select 1
              from information_schema.columns
              where table_schema = 'public'
                and table_name = 'visit_logs'
                and column_name = 'created_at'
            ) then
            delete from public.visit_logs
            where created_at < now() - interval '90 days';
          end if;

          if to_regclass('public.page_views') is not null
            and exists (
              select 1
              from information_schema.columns
              where table_schema = 'public'
                and table_name = 'page_views'
                and column_name = 'created_at'
            ) then
            delete from public.page_views
            where created_at < now() - interval '90 days';
          end if;
        end;
        $cleanup$;
      $cron$
    );
  end if;
end;
$$;
