CREATE TABLE IF NOT EXISTS public.post_study_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  study_id text NOT NULL,
  sender_id text NOT NULL,
  sender_name text NOT NULL,
  receiver_ids text[] NOT NULL DEFAULT '{}',
  receiver_names text[] NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT post_study_likes_one_submission UNIQUE (study_id, sender_id),
  CONSTRAINT post_study_likes_receiver_count CHECK (
    coalesce(array_length(receiver_ids, 1), 0) BETWEEN 1 AND 2
  )
);

ALTER TABLE public.post_study_likes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'post_study_likes'
      AND policyname = 'post_study_likes_select_anon'
  ) THEN
    CREATE POLICY post_study_likes_select_anon
      ON public.post_study_likes
      FOR SELECT
      TO anon
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'post_study_likes'
      AND policyname = 'post_study_likes_insert_anon'
  ) THEN
    CREATE POLICY post_study_likes_insert_anon
      ON public.post_study_likes
      FOR INSERT
      TO anon
      WITH CHECK (
        sender_id IS NOT NULL
        AND study_id IS NOT NULL
        AND coalesce(array_length(receiver_ids, 1), 0) BETWEEN 1 AND 2
      );
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) AND NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'post_study_likes'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.post_study_likes;
  END IF;
END $$;
