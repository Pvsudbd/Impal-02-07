-- ============================================================================
-- 002_course_id_migration.sql
-- Purpose : Migrate `course` from (course_code, lecturer) to per-user/global
--           `id_course` (UUID PK) + `id_user` (nullable; NULL = master catalog,
--           non-NULL = custom user course with max 30/user enforced in backend).
-- Target  : PostgreSQL 18.6 (db_manajemen_tugas)
-- Safety  : Wrapped in BEGIN ... COMMIT (atomic: all succeed or all roll back).
--
-- IMPORTANT PERMISSION NOTE:
-- All tables in `public` are owned by `postgres` (verified via pg_tables).
-- Running ALTER TABLE as `todolist_dev` fails with:
--   SQLSTATE 42501: must be owner of table course
-- Execute this script as the `postgres` owner account (e.g., by your DB admin
-- in pgAdmin/HeidiSQL/psql) AND coordinate with the team because this drops
-- `course_code` from `course`, `course_schedule`, and `task`, and `lecturer`
-- from `course`.
-- ============================================================================

BEGIN;

-- ─── 1. EXPAND: Add new columns without breaking existing data ──────────────
ALTER TABLE public.course
    ADD COLUMN IF NOT EXISTS id_course VARCHAR(36),
    ADD COLUMN IF NOT EXISTS id_user VARCHAR(36),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE public.course_schedule
    ADD COLUMN IF NOT EXISTS id_course VARCHAR(36);

ALTER TABLE public.task
    ADD COLUMN IF NOT EXISTS id_course VARCHAR(36);

-- ─── 2. CLEANUP: Remove unreferenced custom orphan courses ──────────────────
DELETE FROM public.course c
WHERE c.lecturer = 'Dosen Pengampu'
  AND NOT EXISTS (
      SELECT 1 FROM public.course_schedule cs WHERE cs.course_code = c.course_code
  )
  AND NOT EXISTS (
      SELECT 1 FROM public.task t WHERE t.course_code = c.course_code
  );

-- ─── 3. BACKFILL: Assign UUIDs and map existing relations ───────────────────
UPDATE public.course
SET id_course = gen_random_uuid()::text,
    course_name = TRIM(course_name),
    created_at = COALESCE(created_at, CURRENT_TIMESTAMP),
    updated_at = COALESCE(updated_at, created_at, CURRENT_TIMESTAMP)
WHERE id_course IS NULL;

-- Assign `id_user` to legacy custom courses created via Schedule (used by a single user)
UPDATE public.course c
SET id_user = sub.owner_id
FROM (
    SELECT cs.course_code, MIN(a.id_user) AS owner_id
    FROM public.course_schedule cs
    JOIN public.agenda a ON a.id_agenda = cs.id_agenda
    GROUP BY cs.course_code
    HAVING COUNT(DISTINCT a.id_user) = 1
) sub
WHERE c.course_code = sub.course_code
  AND c.lecturer = 'Dosen Pengampu'
  AND c.id_user IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM public.task t WHERE t.course_code = c.course_code
  );

-- Backfill course_schedule.id_course
UPDATE public.course_schedule cs
SET id_course = c.id_course
FROM public.course c
WHERE cs.course_code = c.course_code
  AND cs.id_course IS NULL;

-- Backfill task.id_course
UPDATE public.task t
SET id_course = c.id_course
FROM public.course c
WHERE t.course_code = c.course_code
  AND t.id_course IS NULL;

-- ─── 4. VERIFY: Abort transaction automatically if any relation is unmapped ─
DO $$
DECLARE
    unmapped_cs INT;
    unmapped_task INT;
BEGIN
    SELECT COUNT(*) INTO unmapped_cs
    FROM public.course_schedule
    WHERE id_course IS NULL;

    SELECT COUNT(*) INTO unmapped_task
    FROM public.task
    WHERE course_code IS NOT NULL AND id_course IS NULL;

    IF unmapped_cs > 0 OR unmapped_task > 0 THEN
        RAISE EXCEPTION 'Migration aborted: unmapped rows found (course_schedule=%, task=%)',
            unmapped_cs, unmapped_task;
    END IF;
END $$;

-- ─── 5. CONTRACT: Enforce PK, constraints, indexes, and drop old columns ────
ALTER TABLE public.course
    ALTER COLUMN id_course SET NOT NULL,
    ALTER COLUMN course_name SET NOT NULL,
    ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (id_course);

ALTER TABLE public.course_schedule
    ALTER COLUMN id_course SET NOT NULL;

-- Foreign keys (safe: all rows verified above)
ALTER TABLE public.course_schedule
    ADD CONSTRAINT fk_course_schedule_course
    FOREIGN KEY (id_course) REFERENCES public.course (id_course) ON DELETE RESTRICT;

ALTER TABLE public.task
    ADD CONSTRAINT fk_task_course
    FOREIGN KEY (id_course) REFERENCES public.course (id_course) ON DELETE SET NULL;

-- Indexes & per-user/global case-insensitive uniqueness on course_name
CREATE INDEX IF NOT EXISTS idx_course_user
    ON public.course (id_user);

CREATE UNIQUE INDEX IF NOT EXISTS uq_course_owner_name
    ON public.course (COALESCE(id_user, '__GLOBAL__'), LOWER(TRIM(course_name)));

CREATE INDEX IF NOT EXISTS idx_course_schedule_id_course
    ON public.course_schedule (id_course);

CREATE INDEX IF NOT EXISTS idx_task_id_course
    ON public.task (id_course);

-- Drop unused columns (`lecturer` & `course_code`)
ALTER TABLE public.course
    DROP COLUMN IF EXISTS lecturer,
    DROP COLUMN IF EXISTS course_code;

ALTER TABLE public.course_schedule
    DROP COLUMN IF EXISTS course_code;

ALTER TABLE public.task
    DROP COLUMN IF EXISTS course_code;

-- Ensure runtime app role retains full DML access after DDL changes
GRANT SELECT, INSERT, UPDATE, DELETE
    ON public.course, public.course_schedule, public.task
    TO todolist_dev;

COMMIT;
