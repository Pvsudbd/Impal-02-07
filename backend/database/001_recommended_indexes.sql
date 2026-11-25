-- ============================================================================
-- 001_recommended_indexes.sql
-- Purpose : Idempotent performance indexes for legacy tables in db_manajemen_tugas.
-- Status  : REVIEW-ONLY (Coordinate with team before executing in HeidiSQL/psql).
-- Note    : Safe to run multiple times via IF NOT EXISTS.
-- ============================================================================

-- Users (case-insensitive email lookup during login/register/profile update)
CREATE INDEX IF NOT EXISTS idx_users_email_lower
    ON public.users (LOWER(email));

-- Agenda & Schedule Subclasses
CREATE INDEX IF NOT EXISTS idx_agenda_user_type_time
    ON public.agenda (id_user, agenda_type, start_time, end_time);

CREATE INDEX IF NOT EXISTS idx_course_schedule_agenda
    ON public.course_schedule (id_agenda);

CREATE INDEX IF NOT EXISTS idx_course_schedule_day
    ON public.course_schedule (day);

CREATE INDEX IF NOT EXISTS idx_personal_schedule_agenda_date
    ON public.personal_schedule (id_agenda, date);

-- Personal Tasks
CREATE INDEX IF NOT EXISTS idx_task_user_completed_deadline
    ON public.task (id_user, is_completed, deadline);

-- Daily To-Do Checklist
CREATE INDEX IF NOT EXISTS idx_todo_item_user_date
    ON public.todo_item (id_user, date);

-- Collaborative Groups & Tasks
CREATE INDEX IF NOT EXISTS idx_groups_invite_code
    ON public.groups (invite_code);

CREATE INDEX IF NOT EXISTS idx_group_member_user
    ON public.group_member (id_user);

CREATE INDEX IF NOT EXISTS idx_group_member_group_user
    ON public.group_member (id_group, id_user);

CREATE INDEX IF NOT EXISTS idx_group_task_group_completed
    ON public.group_task (id_group, is_completed, deadline);

CREATE INDEX IF NOT EXISTS idx_group_sub_task_group_task
    ON public.group_sub_task (id_group_task);

CREATE INDEX IF NOT EXISTS idx_group_sub_task_assigned
    ON public.group_sub_task (id_assigned_to);

CREATE INDEX IF NOT EXISTS idx_meeting_schedule_group_time
    ON public.meeting_schedule (id_group, start_time);
