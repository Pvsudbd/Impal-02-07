# Feature Log: Prioritas 0 Backend Hardening & Mekanisme Update Skill Agent

**Tanggal**: 25 November 2026  
**Penulis**: Antigravity Assistant & Yoga Perkasa Didik  
**Status**: Completed  
**Domain Terkait**: Database Config (`Pool` + `runTx`), Auth, Agenda (`CourseSchedule` / `PersonalSchedule`), Profile, Security Hardening, Workspace Skills & Governance Sync

---

## 1. Daftar Berkas yang Dibuat / Dimodifikasi

### Backend (`Impal-02-07/backend/`)
- `lib/config/db.dart` — Migrasi ke `Pool.withEndpoints`, penambahan `DbTransaction` & `Database.transaction(...)`, `Database.close()`, penghapusan hardcoded fallback credentials/JWT secret.
- `.env.example` — Penambahan `DB_SSL`, `DB_POOL_MAX`, dan placeholder host netral.
- `lib/models/auth/user_model.dart` — Penyelarasan kolom `id_user`, normalisasi email lowercase, dan timestamp eksplisit `NOW()`.
- `lib/models/agenda/course_schedule.dart` — Penghapusan fallback `id_student`, transaksi atomik (`create`/`update`/`delete`), perbaikan bug `safeCode` & `_normalizeDay` di `update`, delete child-first anti-orphan, dan helper `findConflicts(...)`.
- `lib/models/agenda/personal_schedule.dart` — Penghapusan fallback `id_student`, transaksi atomik (`create`/`update`/`delete`), delete child-first anti-orphan.
- `lib/models/profile/profile_model.dart` — Optimasi `getProfile` menjadi 1 query agregasi, perbaikan bug integer flag (`is_completed = 1` / `= 0` menggantikan `IS TRUE`), penambahan `DuplicateEmailException`, sanitasi error `joinGroup`, dan serialisasi `DateTime` aman JSON.
- `lib/controllers/auth/auth_controller.dart` — Validasi email regex, panjang password ≥ 6 karakter tanpa spasi, batas panjang string, penanganan `FormatException` (`400`), sanitasi response error.
- `lib/controllers/agenda/agenda_controller.dart` — Dukungan alias `startTime`/`endTime` saat `update`, validasi format jam & rentang `startTime < endTime`, batas panjang field, sanitasi error.
- `lib/controllers/profile/profile_controller.dart` — Mapping `DuplicateEmailException` ke HTTP `409 Conflict`, validasi email & panjang nama, penanganan `FormatException`.
- `bin/server.dart`, `routes/test_db.dart`, `routes/tables.dart` — Sanitasi error DB endpoint dan graceful shutdown pool (`SIGINT`).
- `database/001_recommended_indexes.sql` — Skrip migrasi index idempoten (review-only untuk koordinasi tim).
- `test/priority0_test.dart` — Suite integration test otomatis Prioritas 0.

### Governance & Workspace Skills (`Impal-02-07/.agents/` & `AGENTS.md`)
- `.agents/skills/impal-backend-engineer/SKILL.md`
- `.agents/skills/impal-backend-engineer/references/live_schema_snapshot.md`
- `.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart`
- `.agents/skills/sync-project-skills/SKILL.md`
- `.agents/skills/sync-project-skills/scripts/validate_agent_sync.dart`
- `.agents/rules/backend_dart_frog_rules.md`
- `AGENTS.md`, `.agents/rules/Agents.md`, `.agents/rules/README.md`, `.agents/memory/project_conventions.md`, `.agents/memory/anti_patterns.md`, `ROADMAP_AUDIT_DAN_PENINGKATAN.md`

---

## 2. Rincian Teknis & Keselarasan Skema Live PostgreSQL
- Hasil inspeksi live DB `db_manajemen_tugas` (16 tabel) memastikan seluruh tabel memakai `id_user`, flag legacy (`task.is_completed`, `is_fuzzy_auto`, `notification.is_read`, `todo_item.is_done`, `group_task.is_completed`, `group_sub_task.is_completed`) bertipe `integer` (`0`/`1`), `priority` bertipe `VARCHAR(6)`, dan tabel legacy belum memiliki FK `ON DELETE CASCADE`.
- Seluruh query fallback ganda `id_user`/`id_student` dihilangkan untuk memotong latensi hingga 50% dan mencegah error log PostgreSQL.

---

## 3. Verifikasi Keamanan (`.agents/cybersecurity.md`)
- **Zero Hardcoded Secrets:** `db.dart` gagal cepat (`StateError`) jika `.env` tidak lengkap.
- **Zero Error Leakage:** Tidak ada `e.toString()` yang dikembalikan di body JSON HTTP controller/route.
- **BOLA/IDOR & Parameterized Queries:** Seluruh mutasi memakai `idUser` dari JWT context dan parameterized `:param` / `Sql.named`.
