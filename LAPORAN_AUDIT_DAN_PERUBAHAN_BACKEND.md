# Laporan Audit & Perubahan Backend (IMPAL Smart Task Manager)

**Proyek:** `Impal-02-07` — Smart Academic Task Manager (Dart Frog REST API + PostgreSQL 18.6 + Flutter)  
**Tanggal Pembaruan:** 26 November 2026  
**Database Target:** `db_manajemen_tugas` (PostgreSQL 18.6, 16 tabel pada skema `public`)

---

## 1. Ringkasan Eksekutif

Laporan ini merangkum hasil audit arsitektur, keamanan, skema database, serta daftar perbaikan yang telah diimplementasikan pada sisi **Backend** (`Impal-02-07/backend/`), **Migrasi Skema PostgreSQL**, **Sinkronisasi Modul Frontend (`auth`, `schedule`, `profile`)**, dan **Tata Kelola Agent Skills (`.agents/`)**.

Tujuan utama pekerjaan ini:
1. Memastikan kestabilan koneksi dan integritas transaksi PostgreSQL (connection pool + transaksi atomik).
2. Menyelaraskan seluruh query SQL dengan skema live PostgreSQL (kolom `id_user`, flag integer `0/1`, batas panjang `VARCHAR`, tanpa fallback usang `id_student`).
3. Menutup temuan bug QA lapangan (register tidak tersimpan, fake save saat API gagal, dan penumpukan data duplikat di tabel `course`).
4. Memigrasikan relasi mata kuliah dari `course_code` + `lecturer` menjadi `id_course` (UUID) + `id_user` dengan kuota **30 mata kuliah kustom per user** dan pembersihan otomatis (*auto-cleanup*).

---

## 2. Hasil Audit Awal & Temuan Bug Lapangan

### 2.1 Audit Infrastruktur & Skema Database Live
1. **Single Connection vs Connection Pool (`db.dart`):** Sebelumnya backend menggunakan koneksi tunggal yang rentan putus atau bentrok saat request paralel; skrip juga memiliki fallback kredensial/JWT secret hardcoded.
2. **Ketidaksesuaian Skema Live PostgreSQL:**
   - Seluruh tabel user-owned memakai `id_user` (bukan `id_student`), namun beberapa model lama masih melakukan query fallback ganda ke `id_student`.
   - Kolom flag status legacy (`task.is_completed`, `task.is_fuzzy_auto`, `group_task.is_completed`, `group_sub_task.is_completed`, `notification.is_read`, `todo_item.is_done`) bertipe **`integer` (`0`/`1`)**, bukan `boolean`. Query `IS TRUE` berisiko gagal/tidak akurat.
   - Tabel legacy (`agenda`, `course_schedule`, `personal_schedule`, dll.) belum memiliki FK `ON DELETE CASCADE`, sehingga penghapusan harus eksplisit *child-first* di dalam transaksi.
   - Tabel `users` dan `agenda` tidak memiliki default `created_at`/`updated_at` dari PostgreSQL.
3. **Bug pada `CourseSchedule.update`:** Logika lama tidak menjaga konsistensi `safeCode` dan `_normalizeDay` saat pembaruan jadwal.
4. **Kebocoran Error Internal:** Beberapa controller/route mengembalikan `e.toString()` pada respons HTTP `500`, berpotensi membocorkan detail DB.

### 2.2 Audit Bug Lapangan (Dari Pengujian End-to-End)
1. **Registrasi Akun Baru Tidak Tersimpan (`regist_page.dart`):** Method `_handleRegister()` masih berupa simulasi `Future.delayed(600ms)` dan tidak pernah memanggil endpoint `/api/auth/register`. Selain itu, `AuthRemoteDatasource.register()` melakukan cast langsung ke `response['idStudent'] as String`, padahal backend mengembalikan `idUser`.
2. **Optimistic Update Tanpa Rollback (`schedule_repository.dart`):** Saat menambah, mengubah, atau menghapus jadwal, UI & `SharedPreferences` (`saved_schedules_v1`) langsung diperbarui dan tetap sukses meski backend menolak (misalnya `400` untuk jam `start >= end` atau saat skema DB berubah). Selain itu, cache jadwal tidak dibersihkan saat user logout.
3. **Pembengkakan & Duplikasi Tabel `course`:**
   - Tabel `course` masih memakai `course_code` + `lecturer` yang tidak dipakai UI frontend, dan setiap free-text jadwal berpotensi membuat baris baru yang terus menumpuk.
   - Saat jadwal diedit ke matkul lain atau dihapus, matkul kustom yang sudah tidak dipakai tetap tertinggal memakan kuota.
4. **UX Validasi Form Jadwal (`schedule_form_page.dart`):**
   - `maxLength` input Room bernilai `80`, melebihi batas DB `course_schedule.room` (`VARCHAR(50)`).
   - Validasi rentang waktu `startTime < endTime` belum dicegah sebelum dialog konfirmasi.
   - Campuran bahasa error Indonesia/Inggris pada notifikasi UI (`PopUpPemberitahuan` otomatis tertutup cepat dalam 2,8 detik).

---

## 3. Rincian Perubahan yang Diimplementasikan

### 3.1 Prioritas 0: Backend Hardening & Security
- **Connection Pool & Transaksi Atomik (`backend/lib/config/db.dart`):**
  - Migrasi dari single `Connection` ke `Pool.withEndpoints` (`DB_POOL_MAX`, `queryTimeout: 15s`, `idleCheckAfter: 30s`).
  - Penambahan wrapper `DbTransaction`, `Database.transaction(...)` (`pool.runTx`), `Database.close()`, serta penghapusan seluruh hardcoded fallback kredensial/JWT secret (fail-fast dengan `StateError` bila `.env` tidak lengkap).
- **Penyelarasan Skema & Validasi Controller (`auth`, `agenda`, `profile`):**
  - Normalisasi email lowercase, validasi regex email, panjang password minimal 6 karakter tanpa spasi, validasi jam `HH:MM` dengan `startTime < endTime`, pembatasan panjang string sesuai kolom DB (`title <= 150`, `room <= 50`, `location <= 100`, `category <= 50`).
  - Penanganan `FormatException` (`400 Bad Request`), `DuplicateEmailException` (`409 Conflict`), serta sanitasi total seluruh respons error `500` agar tidak mengembalikan `e.toString()`.
  - Penghapusan query `id_student` yang tidak ada di DB dan perbaikan query flag integer `is_completed = 1` / `= 0` di `ProfileModel`.
  - Graceful shutdown connection pool saat `SIGINT` di `bin/server.dart`.

### 3.2 Migrasi Skema `id_course` & Modul `/api/courses`
- **Skrip Migrasi SQL (`backend/database/002_course_id_migration.sql` — sudah dieksekusi di live DB):**
  - Menambahkan `id_course VARCHAR(36)` (UUID PK), `id_user VARCHAR(36)` nullable (`NULL` = katalog global, non-`NULL` = matkul kustom user), dan `updated_at` pada `public.course`.
  - Memindahkan relasi `course_schedule` dan `task` dari `course_code` ke `id_course` beserta FK (`fk_course_schedule_course` `ON DELETE RESTRICT`, `fk_task_course` `ON DELETE SET NULL`) dan index unik `uq_course_owner_name` pada `(COALESCE(id_user, '__GLOBAL__'), LOWER(TRIM(course_name)))`.
  - Menghapus kolom `lecturer` dan `course_code` yang tidak lagi digunakan.
- **Modul Baru `/api/courses`:**
  - `CourseModel` (`lib/models/course/course_model.dart`), `CourseController` (`lib/controllers/course/course_controller.dart`), dan `CourseRoutes` (`lib/routes/course/course_routes.dart`) terpasang di `/api/courses` dengan proteksi `checkAuthMiddleware()`.
  - Menegakkan **batas maksimal 30 matkul kustom per user** (`maxCustomCoursesPerUser = 30`), pengecekan duplikat case-insensitive (`409`), proteksi BOLA (`404`), dan pencegahan hapus (`409`) bila masih direferensikan oleh `course_schedule`.
  - **`resolveOrCreateForSchedule(...)`:** Saat jadwal dibuat/diubah, backend mencari matkul cocok secara case-insensitive (milik user atau global) terlebih dahulu sebelum membuat entri kustom baru.
  - **Auto-Cleanup (`cleanupUnusedCustomCourse`):** Saat `CourseSchedule.delete(...)` menghapus jadwal atau `CourseSchedule.update(...)` memindahkan jadwal ke matkul lain, matkul kustom lama milik user (`id_user = :idUser`) yang tidak lagi direferensikan oleh `course_schedule` maupun `task` otomatis dihapus agar kuota 30 tidak bocor. Katalog global (`id_user IS NULL`) tidak pernah tersentuh.
- **Penyelarasan Model & Controller:**
  - `CourseSchedule` dan `AgendaController` menggunakan `id_course` + `LEFT JOIN course` dan tetap menyertakan key `'course'`, `'courseName'`, `'idCourse'` pada respons JSON.
  - `ProfileModel` (`getProfile`, `viewDailyAgenda`, `viewCourseSchedule`, `viewRemainingTasks`) disesuaikan sepenuhnya ke `id_course` & `course_name`.

### 3.3 Perbaikan Modul Frontend (`auth`, `schedule`, `profile`)
- **`auth_remote_datasource.dart` & `regist_page.dart`:** Register sekarang terhubung penuh ke `POST /api/auth/register`, membaca `idUser ?? idStudent`, dan menampilkan error pop-up berbahasa Inggris (`Registration Failed`) jika gagal.
- **`schedule_repository.dart`:** `addSchedule`, `updateSchedule`, dan `deleteSchedule` kini menyimpan snapshot state sebelum optimistic update, memverifikasi `response['status'] == 'success'`, melakukan **rollback** state & `SharedPreferences` bila backend menolak/gagal terhubung, menormalisasi payload (`course` & `courseName` menggantikan `courseCode`), memetakan pesan error ke Bahasa Inggris, serta menyediakan `clearLocalCache()`.
- **`schedule_form_page.dart` & `schedule_page.dart`:** Menampilkan pop-up error (`Failed to Save Schedule`, `Delete Failed`, durasi `4200ms`) dan membatalkan navigasi keluar saat gagal; menyamakan `maxLength` input Room menjadi `50` untuk Lecture (`100` untuk Meeting/External); serta menambahkan validasi jam `startTime < endTime` (`Invalid Time Range`) sebelum dialog konfirmasi.
- **`profile_page.dart`:** Memanggil `ScheduleRepository().clearLocalCache()` saat Sign Out agar cache jadwal lokal tidak terbawa saat ganti akun.

### 3.4 Tata Kelola Skills & Dokumentasi Proyek
- Penambahan skill `impal-backend-engineer` (beserta skrip `introspect_schema.dart` & snapshot `live_schema_snapshot.md`) dan `sync-project-skills` (beserta validator `validate_agent_sync.dart`).
- Pembaruan `AGENTS.md` (7.861 bytes), `.agents/rules/`, `.agents/memory/`, feature logs, dan `ROADMAP_AUDIT_DAN_PENINGKATAN.md`.

---

## 4. Daftar Berkas yang Dibuat & Dimodifikasi

### Backend (`Impal-02-07/backend/`)
| Status | Berkas | Ringkasan Peran |
| :--- | :--- | :--- |
| Modified | `lib/config/db.dart` | Connection pool `Pool.withEndpoints`, transaksi `DbTransaction`, fail-fast `.env` |
| Modified | `.env.example` | Variabel `DB_POOL_MAX` & `DB_SSL` |
| Modified | `bin/server.dart` | Mount `/api/courses` dan graceful shutdown pool `SIGINT` |
| Modified | `routes/index.dart`, `test_db.dart`, `tables.dart` | Daftar endpoint root & sanitasi error |
| Created | `lib/models/course/course_model.dart` | Model `/api/courses`, kuota 30, `resolveOrCreateForSchedule`, `cleanupUnusedCustomCourse` |
| Created | `lib/controllers/course/course_controller.dart` | HTTP controller CRUD `/api/courses` |
| Created | `lib/routes/course/course_routes.dart` | Router `/api/courses` berproteksi JWT |
| Modified | `lib/models/auth/user_model.dart`, `lib/controllers/auth/auth_controller.dart` | Kolom `id_user`, normalisasi email, validasi register/login |
| Modified | `lib/models/agenda/course_schedule.dart`, `personal_schedule.dart` | Transaksi atomik, migrasi `id_course`, auto-cleanup, child-first delete |
| Modified | `lib/controllers/agenda/agenda_controller.dart` | Validasi jam/panjang field & penanganan `idCourse`/`courseName` |
| Modified | `lib/models/profile/profile_model.dart`, `lib/controllers/profile/profile_controller.dart` | Query agregasi `getProfile`, integer flag `0/1`, relasi `id_course` |
| Created | `database/001_recommended_indexes.sql` | Skrip rekomendasi index |
| Created | `database/002_course_id_migration.sql` | Skrip migrasi atomik `course_code` -> `id_course` (sudah dijalankan) |
| Created | `test/priority0_test.dart` | Integration test langsung ke PostgreSQL (Auth, Profile, Agenda, Courses, Quota, Auto-Cleanup, Pool) |

### Frontend (`Impal-02-07/frontend/`)
| Status | Berkas | Ringkasan Peran |
| :--- | :--- | :--- |
| Modified | `lib/data/datasources/auth_remote_datasource.dart` | Perbaikan parsing `idUser ?? idStudent` & pesan error English |
| Modified | `lib/presentation/features/auth/regist_page.dart` | Integrasi register nyata ke `/api/auth/register` |
| Modified | `lib/presentation/features/schedule/models/schedule_repository.dart` | Rollback saat gagal, payload `courseName`, normalisasi error English, `clearLocalCache()` |
| Modified | `lib/presentation/features/schedule/schedule_form_page.dart` | Validasi `start < end`, `maxLength` room 50/100, pop-up error 4,2 detik |
| Modified | `lib/presentation/features/schedule/schedule_page.dart` | Penanganan error & rollback saat delete schedule |
| Modified | `lib/presentation/features/profile/profile_page.dart` | Pembersihan cache `ScheduleRepository` saat logout |

### Dokumentasi & Agent Skills (`Impal-02-07/`)
- `.agents/skills/impal-backend-engineer/` (`SKILL.md`, `references/live_schema_snapshot.md`, `scripts/introspect_schema.dart`)
- `.agents/skills/sync-project-skills/` (`SKILL.md`, `scripts/validate_agent_sync.dart`)
- `.agents/features/backend_priority0_hardening.md` & `.agents/features/backend_course_id_migration.md`
- `.agents/rules/backend_dart_frog_rules.md`, `AGENTS.md`, `ROADMAP_AUDIT_DAN_PENINGKATAN.md`
- `LAPORAN_AUDIT_DAN_PERUBAHAN_BACKEND.md` (laporan ini)

---

## 5. Hasil Pengujian & Verifikasi

### 5.1 Pengujian Otomatis (Pasca-Perubahan Terakhir)
- **`dart analyze`** (`Impal-02-07/backend`): **`No issues found!`** (`0` error/warning).
- **`dart test -r expanded`** (`Impal-02-07/backend/test/priority0_test.dart`): **`All tests passed!` (7/7 kasus uji)** terhadap database live `db_manajemen_tugas`:
  1. Validasi payload register tidak valid (`400`).
  2. Register user, penolakan duplikat email case-insensitive (`409`), & login JWT (`200`).
  3. Agregasi statistik integer flag `0/1` pada `ProfileModel` & duplikat email (`409`).
  4. CRUD `CourseSchedule`, resolusi `id_course`, reuse case-insensitive, BOLA (`404`), auto-cleanup saat ganti/hapus matkul, & hapus bebas orphan.
  5. CRUD `PersonalSchedule` & hapus bebas orphan.
  6. Katalog `/api/courses`: list, create, duplikat (`409`), edit in-place (`200`), BOLA (`404`), blokir hapus saat dipakai jadwal (`409`), auto-cleanup pasca hapus jadwal, hapus eksplisit (`200`), dan penegakan batas kuota 30 matkul kustom (`400` pada entri ke-31).
  7. Konkurensi 10 query paralel melalui `Pool`.
- **`validate_agent_sync.dart`**: **`PASS`** (`AGENTS.md` size `7861 / 24000 bytes`).
- **`flutter analyze`** (`Impal-02-07/frontend`): **`No issues found!`** (`0` error/warning).

### 5.2 QA Manual End-to-End (Browser Chrome + HeidiSQL)
- Register akun baru + simpan ke `users` + login ulang: **Lulus**.
- Penolakan register email duplikat (`409`): **Lulus**.
- Tambah jadwal kuliah + relasi `id_course` & `id_user` di `course`, `agenda`, `course_schedule`: **Lulus**.
- Persistensi pasca-tutup browser: **Lulus**.
- Rollback otomatis saat input ditolak backend (jam tidak valid): **Lulus**.
- Hapus jadwal bersih dari `agenda` & `course_schedule`: **Lulus** (dan setelah pembaruan terakhir, matkul kustom yang tidak lagi terpakai juga otomatis terhapus dari `course`).
- Pembersihan cache jadwal saat logout antar akun: **Lulus**.

---

## 6. Rencana Pengembangan Berikutnya
1. **Prioritas 1 Backend:** Endpoint CRUD `/api/tasks` + sinkronisasi `/api/tasks/sync` (Last-Write-Wins) + Engine Fuzzy Mamdani XAI (`/api/smart-priority`).
2. **Prioritas 2 Backend:** Endpoint modul tim (`/api/groups`, `group_member`, `group_milestone`, `group_task`, `group_sub_task`, `meeting_schedule`), `/api/notifications`, dan `/api/dashboard/summary`.
3. **Prioritas 3:** Alur Forgot/Reset Password OTP, `/api/profile/preferences`, `/api/todos`, serta pembersihan endpoint legacy pada `frontend/lib/core/network/api_endpoints.dart`.
