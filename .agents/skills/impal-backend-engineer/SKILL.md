---
name: impal-backend-engineer
description: >-
  Standard operating procedure for developing, hardening, and testing the
  Impal-02-07 Dart Frog + PostgreSQL backend. Use whenever creating or modifying
  REST API routes, controllers, models, database queries, or backend tests.
---

# IMPAL Backend Engineer Runbook (Dart Frog + PostgreSQL)

Follow this runbook whenever working in `Impal-02-07/backend/`.

## Architecture & Core Rules

1. **Runtime & Stack:** Dart Frog + Shelf sub-routers on port `3000`, connected to PostgreSQL `db_manajemen_tugas` via `Database.getPool()` (`package:postgres`).
2. **Feature-Based Layout:** Always place code inside feature subfolders under `backend/lib/`:
   - `lib/controllers/<feature>/`
   - `lib/models/<feature>/`
   - `lib/routes/<feature>/`
   - `lib/middleware/<feature>/` (if needed)
3. **Environment & Secrets:** Never hardcode DB credentials or `JWT_SECRET`. Load via `Database` (`dotenv`), keeping secrets strictly in `.env` (gitignored).
4. **Transactions:** Any multi-table write or delete (`agenda` + `course_schedule` / `personal_schedule`, `groups` + `group_member`, etc.) MUST use `Database.transaction((tx) async { ... })`.
5. **Live Schema Alignment:** Always verify column names and types against [live_schema_snapshot.md](./references/live_schema_snapshot.md) before writing SQL:
   - All user-owned tables use `id_user` (never `id_student`).
   - Legacy boolean-like columns (`task.is_completed`, `task.is_fuzzy_auto`, `group_task.is_completed`, `group_task.is_fuzzy_auto`, `group_sub_task.is_completed`, `notification.is_read`, `todo_item.is_done`) are PostgreSQL `integer` (`0` / `1`) — compare with `= 1` / `= 0`, never `IS TRUE`.
   - `task.priority` and `group_task.priority` are `VARCHAR(6)` (`HIGH`, `MEDIUM`, `LOW`).
   - Legacy tables lack `ON DELETE CASCADE` foreign keys; delete child rows explicitly before parent rows inside `Database.transaction`.
6. **Security & Response Envelope:**
   - Standard JSON envelope: `{"status": "success" | "error", "message": "...", "data": ...}`.
   - Extract `idUser` exclusively from verified JWT context (`req.context['user']`) for BOLA/IDOR protection.
   - Use parameterized queries (`:param` / `Sql.named`). Never interpolate user input into SQL.
   - Never return raw `e.toString()` or stack traces in HTTP responses; log server-side only.
   - Follow `.agents/cybersecurity.md` and `.agents/rules/backend_dart_frog_rules.md`.

## Verification & Sync Steps

Run from `Impal-02-07/backend/`:

1. Inspect live PostgreSQL schema if any table may have changed:
   ```powershell
   dart run --packages=.dart_tool/package_config.json ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart
   ```
   (Pass `--write` to update `./references/live_schema_snapshot.md` directly.)
2. Run static analysis and tests:
   ```powershell
   dart analyze; dart test
   ```
3. After completing backend/schema changes, activate the `sync-project-skills` skill (`../sync-project-skills/SKILL.md`) to keep project skills, rules, memory, feature logs, and roadmap synchronized.
