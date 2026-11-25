# Backend Dart Frog & PostgreSQL Rules
<!-- Official Location: .agents/rules/backend_dart_frog_rules.md -->

Rules governing all backend work under `Impal-02-07/backend/`.

## 1. Architecture & Database Access
- **Connection Pool Only:** Use `Database.getPool()`, `Database.query()`, and `Database.transaction((tx) async { ... })` from `lib/config/db.dart`. Never instantiate raw `Connection.open()` in controllers or models.
- **No Hardcoded Secrets:** All DB credentials and `JWT_SECRET` must come exclusively from `.env` via `Database`.
- **Feature Grouping:** Group code into `lib/controllers/<feature>/`, `lib/models/<feature>/`, and `lib/routes/<feature>/`.

## 2. Live PostgreSQL Schema Rules
- **User Column:** Always use `id_user` (never `id_student` fallback queries).
- **Integer Flags:** Compare `is_completed`, `is_fuzzy_auto`, `is_read`, `is_done` as integer `1` / `0` (never `IS TRUE` / `IS NOT TRUE`).
- **Atomic Multi-Table Writes & Deletes:** Wrap `create`, `update`, and `delete` spanning superclass/subclass or parent/child tables in `Database.transaction(...)`. Delete child rows explicitly before parent rows when legacy tables lack cascade FKs.
- **Explicit Timestamps:** Set `NOW()` on `created_at` / `updated_at` for legacy tables lacking column defaults.

## 3. Security & Error Handling
- Follow `.agents/cybersecurity.md`: BOLA checks via `req.context['user']`, parameterized `:param` queries, strict input validation & length bounds, `409 Conflict` for duplicate unique fields, and zero raw SQL/exception leakage in HTTP responses.

## 4. Mandatory Skill Sync Loop
- After completing any backend endpoint, model, or schema change, execute `.agents/skills/sync-project-skills/SKILL.md` and verify with `validate_agent_sync.dart`.
