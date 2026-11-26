# Feature Log: Sinkronisasi Backend `id_course` & Modul `/api/courses` (Kuota 30 Matkul Kustom)

**Tanggal**: 25 November 2026  
**Penulis**: Antigravity Assistant & Yoga Perkasa Didik  
**Status**: Completed  
**Domain Terkait**: Course Catalog (`/api/courses`), Agenda (`CourseSchedule`), Profile (`ProfileModel`), Database Schema `002_course_id_migration.sql`

---

## 1. Daftar Berkas yang Dibuat / Dimodifikasi

### Backend (`Impal-02-07/backend/`)
- `lib/models/course/course_model.dart` — Model `CourseModel` dengan `maxCustomCoursesPerUser = 30`, exception khusus (`CourseLimitExceededException`, `DuplicateCourseException`, `CourseInUseException`, `CourseNotFoundException`), query daftar mata kuliah (`global` `id_user IS NULL` + custom `id_user = :idUser`), `resolveOrCreateForSchedule` untuk resolusi/auto-create dengan batas kuota, `cleanupUnusedCustomCourse` untuk penghapusan otomatis matkul kustom tak terpakai, serta CRUD transaksi atomik dengan proteksi BOLA.
- `lib/controllers/course/course_controller.dart` — Handler HTTP `GET /api/courses` (mendukung `?q=` & `?scope=mine|global|all`), `POST /api/courses` (`400` jika melebihi kuota 30, `409` jika duplikat case-insensitive), `PUT /api/courses/<idCourse>` (`404` BOLA, `409` duplikat), dan `DELETE /api/courses/<idCourse>` (`409` jika masih dipakai di `course_schedule`).
- `lib/routes/course/course_routes.dart` — Router `/api/courses` terlindungi `checkAuthMiddleware()`.
- `bin/server.dart` & `routes/index.dart` — Mounting `/api/courses` dan pembaruan daftar endpoint root.
- `lib/models/agenda/course_schedule.dart` — Migrasi dari `course_code`/`lecturer` ke `id_course` (`LEFT JOIN course c ON cs.id_course = c.id_course`), tetap mengembalikan field `course` + `courseName` + `idCourse` di JSON untuk kompatibilitas frontend Flutter, memakai `CourseModel.resolveOrCreateForSchedule(...)` pada `create` & `update`, serta otomatis memanggil `CourseModel.cleanupUnusedCustomCourse(...)` saat jadwal dihapus atau ganti matkul.
- `lib/controllers/agenda/agenda_controller.dart` — Dukungan input `idCourse` maupun `courseName`/`course` dan penanganan `CourseLimitExceededException` (`400`) serta `CourseNotFoundException` (`404`).
- `lib/models/profile/profile_model.dart` — Penyelarasan `getProfile`, `viewDailyAgenda`, `viewCourseSchedule` (tanpa kolom `lecturer`), dan `viewRemainingTasks` ke `id_course` & `c.course_name`.
- `test/priority0_test.dart` — Pembaruan test CRUD `CourseSchedule`, agregasi `ProfileModel`, serta penambahan suite test `/api/courses` (list, create, duplikat `409`, edit in-place, BOLA `404`, blokir hapus saat dipakai jadwal `409`, dan penegakan kuota maksimal 30 mata kuliah kustom per user).

### Governance & Schema Snapshot (`Impal-02-07/.agents/`)
- `.agents/skills/impal-backend-engineer/references/live_schema_snapshot.md` — Diperbarui via `introspect_schema.dart --write` mencerminkan 16 tabel pasca-migrasi `002_course_id_migration.sql`.

---

## 2. Verifikasi Keamanan & Mutu
- `dart analyze`: `No issues found!`
- `dart test -r expanded`: 7/7 test cases lulus (`All tests passed!`) langsung terhadap PostgreSQL `db_manajemen_tugas`.
- Semua error tidak membocorkan `e.toString()`, mutasi memakai JWT `idUser` (BOLA-safe) dan transaksi atomik `Database.transaction`.
