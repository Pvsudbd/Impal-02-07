# Live PostgreSQL Schema Snapshot (`db_manajemen_tugas`)

> Generated from live PostgreSQL (`10.147.115.231:5432`) via `scripts/introspect_schema.dart`.
> Always re-run `dart run ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart --write` from `Impal-02-07/backend` after team schema updates.

## Critical Schema Gotchas

1. **User Foreign Key:** Every user-owned table uses `id_user` (never `id_student`).
2. **Integer Flags (`0`/`1`):** `task.is_completed`, `task.is_fuzzy_auto`, `group_task.is_completed`, `group_task.is_fuzzy_auto`, `group_sub_task.is_completed`, `notification.is_read`, `todo_item.is_done` are `integer` (use `= 1` / `= 0`, never `IS TRUE`).
3. **Priority Length:** `task.priority` and `group_task.priority` are `character varying(6)` (`HIGH`, `MEDIUM`, `LOW` — `'VERY HIGH'` does NOT fit!).
4. **No Legacy Cascade FKs:** Legacy tables lack `ON DELETE CASCADE` FKs in live DB — always delete children explicitly inside `Database.transaction`.
5. **No Default Timestamps on Legacy Tables:** `users.created_at/updated_at` and `agenda.created_at/updated_at` have `default = null` — set `NOW()` explicitly in `INSERT`/`UPDATE`.

---

## Tables (16)

### 1. `agenda`
- `id_agenda`: `character varying(36)` (nullable=YES)
- `id_user`: `character varying(36)` (nullable=YES)
- `title`: `character varying(150)` (nullable=YES)
- `start_time`: `time without time zone` (nullable=NO)
- `end_time`: `time without time zone` (nullable=NO)
- `agenda_type`: `character varying(8)` (nullable=YES)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES)

### 2. `course`
- `course_name`: `character varying(100)` (nullable=NO)
- `credits`: `integer` (nullable=NO, default=`3`)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `id_course`: `character varying(36)` (nullable=NO)
- `id_user`: `character varying(36)` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES, default=`CURRENT_TIMESTAMP`)
- Indexes: `course_pkey`, `idx_course_user`, `uq_course_owner_name`

### 3. `course_schedule`
- `id_agenda`: `character varying(36)` (nullable=YES)
- `day`: `character varying(20)` (nullable=YES)
- `room`: `character varying(50)` (nullable=YES)
- `id_course`: `character varying(36)` (nullable=NO)
- Indexes: `idx_course_schedule_id_course`

### 4. `group_member`
- `id_member`: `character varying(36)` (nullable=YES)
- `id_group`: `character varying(36)` (nullable=YES)
- `id_user`: `character varying(36)` (nullable=YES)
- `role`: `character varying(6)` (nullable=YES)
- `joined_at`: `timestamp without time zone` (nullable=YES)

### 5. `group_milestone`
- `id_milestone`: `character varying(36)` (nullable=NO)
- `id_group`: `character varying(36)` (nullable=NO)
- `title`: `character varying(150)` (nullable=NO)
- `description`: `text` (nullable=YES)
- `deadline`: `timestamp without time zone` (nullable=NO)
- `created_at`: `timestamp without time zone` (nullable=YES, default=`CURRENT_TIMESTAMP`)
- Indexes: `group_milestone_pkey`

### 6. `group_sub_task`
- `id_sub_task`: `character varying(36)` (nullable=YES)
- `id_group_task`: `character varying(36)` (nullable=YES)
- `id_assigned_to`: `character varying(36)` (nullable=YES)
- `sub_task_title`: `character varying(150)` (nullable=YES)
- `description`: `text` (nullable=YES)
- `deadline`: `timestamp without time zone` (nullable=NO)
- `grade_weight`: `double precision` (nullable=NO)
- `is_completed`: `integer` (nullable=NO)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES)

### 7. `group_task`
- `id_group_task`: `character varying(36)` (nullable=YES)
- `id_group`: `character varying(36)` (nullable=YES)
- `id_assigned_to`: `character varying(36)` (nullable=YES)
- `task_title`: `character varying(150)` (nullable=YES)
- `description`: `text` (nullable=YES)
- `deadline`: `timestamp without time zone` (nullable=NO)
- `grade_weight`: `double precision` (nullable=NO)
- `priority`: `character varying(6)` (nullable=YES)
- `is_fuzzy_auto`: `integer` (nullable=NO)
- `is_completed`: `integer` (nullable=NO)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES)
- `id_milestone`: `character varying(36)` (nullable=YES)
- `tags`: `jsonb` (nullable=NO, default=`'[]'::jsonb`)

### 8. `groups`
- `id_group`: `character varying(36)` (nullable=NO)
- `id_leader`: `character varying(36)` (nullable=YES)
- `group_name`: `character varying(100)` (nullable=YES)
- `description`: `text` (nullable=YES)
- `invite_code`: `character varying(10)` (nullable=YES)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `group_size`: `integer` (nullable=NO, default=`1`)
- Indexes: `groups_pkey`

### 9. `meeting_schedule`
- `id_meeting`: `character varying(36)` (nullable=YES)
- `id_group`: `character varying(36)` (nullable=YES)
- `meeting_title`: `character varying(100)` (nullable=YES)
- `description`: `text` (nullable=YES)
- `start_time`: `timestamp without time zone` (nullable=NO)
- `platform_location`: `character varying(100)` (nullable=YES)
- `created_at`: `timestamp without time zone` (nullable=YES)

### 10. `notification`
- `id_notification`: `character varying(36)` (nullable=YES)
- `id_user`: `character varying(36)` (nullable=YES)
- `id_task`: `character varying(36)` (nullable=YES)
- `message_title`: `character varying(100)` (nullable=YES)
- `message`: `text` (nullable=YES)
- `sent_time`: `timestamp without time zone` (nullable=NO)
- `is_read`: `integer` (nullable=NO)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `category`: `character varying(30)` (nullable=NO, default=`'deadline'::character varying`)
- `category_label`: `character varying(100)` (nullable=NO, default=`'Reminder'::character varying`)
- `status_tag`: `character varying(60)` (nullable=NO, default=`'Upcoming'::character varying`)
- `action_label`: `character varying(50)` (nullable=YES, default=`'View →'::character varying`)
- `action_type`: `character varying(30)` (nullable=YES, default=`'view_task'::character varying`)
- `target_id`: `character varying(50)` (nullable=YES)
- `dedup_key`: `character varying(150)` (nullable=YES)
- Indexes: `idx_notification_user_read`, `uq_notification_user_dedup`

### 11. `personal_schedule`
- `id_agenda`: `character varying(36)` (nullable=YES)
- `date`: `date` (nullable=NO)
- `category`: `character varying(50)` (nullable=YES)
- `location`: `character varying(100)` (nullable=YES)
- `notes`: `text` (nullable=YES)

### 12. `task`
- `id_task`: `character varying(36)` (nullable=YES)
- `id_user`: `character varying(36)` (nullable=YES)
- `task_title`: `character varying(150)` (nullable=YES)
- `description`: `text` (nullable=YES)
- `deadline`: `timestamp without time zone` (nullable=NO)
- `grade_weight`: `double precision` (nullable=NO)
- `priority_score`: `double precision` (nullable=YES)
- `priority`: `character varying(6)` (nullable=YES)
- `is_fuzzy_auto`: `integer` (nullable=NO)
- `is_completed`: `integer` (nullable=NO)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES)
- `tags`: `jsonb` (nullable=NO, default=`'[]'::jsonb`)
- `id_course`: `character varying(36)` (nullable=YES)
- Indexes: `idx_task_id_course`

### 13. `task_tags`
- `id_tag`: `character varying(36)` (nullable=NO)
- `id_user`: `character varying(36)` (nullable=NO)
- `label`: `character varying(24)` (nullable=NO)
- `background_color`: `bigint` (nullable=NO)
- `text_color`: `bigint` (nullable=NO)
- `is_default`: `boolean` (nullable=NO, default=`false`)
- `created_at`: `timestamp with time zone` (nullable=YES, default=`CURRENT_TIMESTAMP`)
- `updated_at`: `timestamp with time zone` (nullable=YES, default=`CURRENT_TIMESTAMP`)
- Indexes: `idx_task_tags_user`, `task_tags_pkey`, `uq_task_tags_user_label`

### 14. `todo_item`
- `id_item`: `character varying(36)` (nullable=YES)
- `id_user`: `character varying(36)` (nullable=YES)
- `activity_title`: `character varying(150)` (nullable=YES)
- `notes`: `text` (nullable=YES)
- `date`: `date` (nullable=NO)
- `is_done`: `integer` (nullable=NO)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES)

### 15. `user_preferences`
- `id_user`: `character varying(50)` (nullable=NO)
- `sound_vibration_enabled`: `boolean` (nullable=NO, default=`true`)
- `is_fuzzy_model_active`: `boolean` (nullable=NO, default=`true`)
- `score_explainability_enabled`: `boolean` (nullable=NO, default=`true`)
- `task_deadline_alerts`: `jsonb` (nullable=NO, default=`'{"enabled": true, "timings": ["H-24 Jam", "H-1 Jam"], "soundMode": "soundAndVibration"}'::jsonb`)
- `lecture_schedule_alerts`: `jsonb` (nullable=NO, default=`'{"enabled": true, "timings": ["15m Before", "At Start"], "soundMode": "soundAndVibration"}'::jsonb`)
- `external_schedule_alerts`: `jsonb` (nullable=NO, default=`'{"enabled": true, "timings": ["15m Before"], "soundMode": "soundAndVibration"}'::jsonb`)
- `team_task_alerts`: `jsonb` (nullable=NO, default=`'{"enabled": true, "timings": ["H-24 Jam", "H-1 Jam"], "soundMode": "soundAndVibration"}'::jsonb`)
- `team_meeting_alerts`: `jsonb` (nullable=NO, default=`'{"enabled": true, "timings": ["1h Before", "15m Before"], "soundMode": "soundAndVibration"}'::jsonb`)
- `daily_briefing_enabled`: `boolean` (nullable=NO, default=`true`)
- `daily_briefing_time`: `character varying(20)` (nullable=NO, default=`'07:00 WIB'::character varying`)
- `daily_briefing_topics`: `jsonb` (nullable=NO, default=`'["personal_tasks", "lecture_schedule", "external_schedule", "team_tasks", "team_meetings"]'::jsonb`)
- `daily_briefing_compact`: `boolean` (nullable=NO, default=`false`)
- `updated_at`: `timestamp with time zone` (nullable=YES, default=`CURRENT_TIMESTAMP`)
- Indexes: `user_preferences_pkey`

### 16. `users`
- `id_user`: `character varying(36)` (nullable=YES)
- `name`: `character varying(100)` (nullable=YES)
- `email`: `character varying(100)` (nullable=YES)
- `password_hash`: `character varying(255)` (nullable=YES)
- `created_at`: `timestamp without time zone` (nullable=YES)
- `updated_at`: `timestamp without time zone` (nullable=YES)

