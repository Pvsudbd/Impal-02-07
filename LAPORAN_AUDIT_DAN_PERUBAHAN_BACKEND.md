# Laporan Audit & Perubahan Backend (IMPAL Smart Task Manager)

**Proyek:** `Impal-02-07` — Smart Academic Task Manager (Dart Frog REST API + PostgreSQL 18.6 + Flutter)  
**Tanggal Pembaruan:** 26 November 2026  
**Database Target:** `db_manajemen_tugas` (PostgreSQL 18.6, 16 tabel pada skema `public`)

---

## 1. Ringkasan Eksekutif

Laporan ini merangkum hasil audit arsitektur, keamanan, keselarasan skema PostgreSQL, serta seluruh perubahan yang telah diimplementasikan pada **Backend** (`Impal-02-07/backend/`), **Migrasi Skema Database**, **Sinkronisasi Modul Frontend (`auth`, `schedule`, `profile`)**, dan **Tata Kelola Agent Skills (`.agents/`)**.

Cakupan endpoint aktif yang saat ini sudah berjalan dan teruji di backend meliputi **7 modul bisnis utama + endpoint kesehatan/skema** yang melayani **12 dari 16 tabel live PostgreSQL**:
- `/api/auth` & `/api/profile` (`users`, plus agregasi `task`, `agenda`, `course_schedule`, `group_member`, `groups`)
- `/api/agenda` & `/api/courses` (`agenda`, `course_schedule`, `personal_schedule`, `course`)
- `/api/tasks` & `/api/smart-priority` (`task`, serta pembacaan konfigurasi `user_preferences`)
- `/api/groups` (`groups`, `group_member`, `group_milestone`, `group_task`, `group_sub_task`, `meeting_schedule`)
- `/`, `/test-db`, `/tables` (monitoring kesehatan backend & database)

Tujuan utama pengerjaan ini:
1. Memastikan kestabilan koneksi dan integritas transaksi PostgreSQL (connection pool + transaksi atomik).
2. Menyelaraskan seluruh query SQL dengan skema live PostgreSQL (`id_user`, integer flag `0`/`1`, `VARCHAR` length guard, `tags::jsonb`, tanpa fallback usang `id_student`).
3. Menutup seluruh temuan bug QA lapangan (register tidak tersimpan, fake save saat API gagal, dan pembengkakan tabel `course`).
4. Memigrasikan relasi mata kuliah ke `id_course` (UUID) + `id_user` dengan kuota **30 mata kuliah kustom/user** serta pembersihan otomatis (*auto-cleanup*).
5. Menghadirkan **Engine Fuzzy Mamdani XAI** untuk prioritas cerdas dan **Modul Kolaborasi Tim (`/api/groups`)** yang lengkap dengan kontrol akses berbasis peran (`LEADER`/`MEMBER`).

---

## 2. Hasil Audit Awal & Temuan Bug Lapangan

### 2.1 Audit Infrastruktur, Keamanan, & Skema Live PostgreSQL
1. **Single Connection vs Connection Pool (`db.dart`):** Backend awal memakai koneksi tunggal tanpa `Pool` dan menyimpan fallback kredensial/JWT secret hardcoded.
2. **Ketidaksesuaian Skema Live PostgreSQL:**
   - Seluruh tabel milik pengguna menggunakan `id_user` (bukan `id_student`), tetapi beberapa query lama melakukan fallback ganda ke `id_student` yang memicu error/latensi ganda.
   - Kolom flag status legacy (`task.is_completed`, `task.is_fuzzy_auto`, `group_task.is_completed`, `group_task.is_fuzzy_auto`, `group_sub_task.is_completed`, `notification.is_read`, `todo_item.is_done`) bertipe **`integer` (`0`/`1`)**, bukan `boolean`. Query `IS TRUE` berisiko gagal/tidak akurat.
   - Kolom `task.priority` dan `group_task.priority` dibatasi **`VARCHAR(6)`** (`HIGH`, `MEDIUM`, `LOW`).
   - Tabel legacy (`agenda`, `course_schedule`, `personal_schedule`, `groups`, `group_task`, dll.) tidak memiliki FK `ON DELETE CASCADE`, sehingga penghapusan harus eksplisit *child-first* di dalam transaksi agar bebas *orphan row*.
   - Tabel `users` dan `agenda` tidak memiliki nilai default `created_at`/`updated_at` dari database, sehingga wajib diisi eksplisit (`NOW()`).
   - Tabel `groups` menggunakan keyword SQL sehingga wajib di-quote (`"groups"`), serta `groups`, `group_milestone`, dan `meeting_schedule` tidak memiliki kolom `updated_at`.
3. **Bug pada `CourseSchedule.update`:** Logika lama tidak menjaga konsistensi `safeCode` dan `_normalizeDay` saat pembaruan jadwal.
4. **Kebocoran Error Internal:** Beberapa controller/route sempat mengembalikan `e.toString()` pada respons HTTP `500`.
5. **Kesiapan Integrasi UI Frontend (Gap Audit):**
   - Backend `/api/tasks`, `/api/smart-priority`, dan `/api/groups` kini sudah siap produksi, sedangkan layar UI `TaskPage`, `SmartPriorityPage`, `TeamListPage`, dan `DashboardTeamPage` di frontend (bagian anggota tim lain) saat ini masih memakai repositori in-memory lokal dan belum disambungkan ke endpoint backend baru tersebut.

### 2.2 Audit Bug Lapangan (Pengujian End-to-End Frontend–Backend)
1. **Registrasi Akun Baru Tidak Tersimpan (`regist_page.dart`):** `_handleRegister()` masih berupa simulasi `Future.delayed(600ms)` dan tidak pernah memanggil `/api/auth/register`. Di sisi lain, `AuthRemoteDatasource.register()` mewajibkan `response['idStudent'] as String`, padahal backend mengembalikan `idUser`.
2. **Optimistic Update Tanpa Rollback (`schedule_repository.dart`):** Penambahan, pembaruan, dan penghapusan jadwal langsung disimpan ke UI & `SharedPreferences` (`saved_schedules_v1`) meskipun API menolak (`400`/`500`), serta cache lokal tidak dibersihkan saat user logout.
3. **Pembengkakan & Duplikasi Tabel `course`:** Kolom `course_code` & `lecturer` tidak digunakan UI frontend, setiap free-text jadwal berpotensi membuat entri baru, dan entri custom course yang ditinggalkan saat hapus/edit jadwal tetap menghabiskan kuota user.
4. **UX Validasi Form Jadwal (`schedule_form_page.dart`):** `maxLength` input Room tadinya `80` (melebihi kolom DB `VARCHAR(50)`), tidak ada pencegahan awal `startTime < endTime`, dan pesan error API masih campur Bahasa Indonesia–Inggris dengan durasi toast singkat (`2,8` detik).

---

## 3. Rincian Perubahan yang Diimplementasikan

### 3.1 Prioritas 0: Backend Hardening & Security
- **Connection Pool & Transaksi Atomik (`backend/lib/config/db.dart`):**
  - Migrasi ke `Pool.withEndpoints` (`DB_POOL_MAX`, `queryTimeout: 15s`, `idleCheckAfter: 30s`), penambahan wrapper `DbTransaction`, `Database.transaction(...)` (`pool.runTx`), `Database.close()`, serta fail-fast `StateError` bila variabel `.env` tidak lengkap.
- **Penyelarasan Skema & Validasi Controller (`auth`, `agenda`, `profile`):**
  - Normalisasi email lowercase, validasi regex email, password min 6 karakter tanpa spasi, validasi jam `HH:MM` dengan `startTime < endTime`, pembatasan panjang string sesuai kolom DB (`title <= 150`, `room <= 50`, `location <= 100`, `category <= 50`).
  - Pemetaan error bersih: `FormatException` (`400`), `DuplicateEmailException` (`409`), sanitasi total respons `500` (tanpa `e.toString()`), penghapusan fallback `id_student`, perbaikan flag integer `0/1` pada `ProfileModel`, serta graceful shutdown `SIGINT` di `bin/server.dart`.

### 3.2 Migrasi Skema `id_course` & Modul `/api/courses`
- **Skrip Migrasi SQL (`backend/database/002_course_id_migration.sql` — sudah dijalankan di live DB):**
  - Menambahkan `id_course VARCHAR(36)` (UUID PK), `id_user VARCHAR(36)` nullable (`NULL` = katalog global, non-`NULL` = matkul kustom user), dan `updated_at` pada `public.course`.
  - Memindahkan relasi `course_schedule` dan `task` dari `course_code` ke `id_course` beserta FK (`fk_course_schedule_course` `ON DELETE RESTRICT`, `fk_task_course` `ON DELETE SET NULL`) dan index unik `uq_course_owner_name` pada `(COALESCE(id_user, '__GLOBAL__'), LOWER(TRIM(course_name)))`.
  - Menghapus kolom `lecturer` dan `course_code`.
- **Modul `/api/courses` (`course_model.dart`, `course_controller.dart`, `course_routes.dart`):**
  - Mendukung `GET /api/courses` (filter `?q=` & `?scope=mine|global|all`), `POST /api/courses`, `PUT /api/courses/<idCourse>`, `DELETE /api/courses/<idCourse>`.
  - Menegakkan **kuota maksimal 30 matkul kustom per user** (`maxCustomCoursesPerUser = 30`), penolakan duplikat case-insensitive (`409`), proteksi BOLA (`404`), dan penolakan hapus (`409`) selama masih dipakai `course_schedule`.
  - **`resolveOrCreateForSchedule(...)`:** Resolusi case-insensitive ke katalog global/user sebelum membuat custom course baru dalam transaksi.
  - **Auto-Cleanup (`cleanupUnusedCustomCourse`):** Saat `CourseSchedule.delete`, `CourseSchedule.update` (ganti matkul), `Task.delete`, atau `Task.update` (ganti matkul) meninggalkan custom course milik user yang tidak lagi direferensikan `course_schedule` maupun `task`, baris tersebut otomatis dihapus agar kuota 30 tidak bocor. Katalog global (`id_user IS NULL`) tidak pernah tersentuh.
- **Penyelarasan Model & Controller Terkait:** `CourseSchedule`, `AgendaController`, dan `ProfileModel` sepenuhnya memakai `id_course` + `course_name` sambil mempertahankan key `'course'` di JSON agar kompatibel dengan frontend Flutter.

### 3.3 Perbaikan Modul Frontend (`auth`, `schedule`, `profile`)
- **`auth_remote_datasource.dart` & `regist_page.dart`:** Register terhubung nyata ke `POST /api/auth/register`, membaca `idUser ?? idStudent`, dan menampilkan pop-up error Bahasa Inggris (`Registration Failed`) jika ditolak server.
- **`schedule_repository.dart`:** `addSchedule`, `updateSchedule`, dan `deleteSchedule` kini menyimpan snapshot sebelum optimistic update, mengecek `response['status'] == 'success'`, melakukan **rollback** state & `SharedPreferences` saat gagal, memakai payload `course` & `courseName`, menormalisasi pesan error ke Bahasa Inggris (`_normalizeApiError`), serta menambahkan `clearLocalCache()`.
- **`schedule_form_page.dart` & `schedule_page.dart`:** Menampilkan pop-up error (`Failed to Save Schedule`, `Delete Failed`, durasi `4200ms`) dan membatalkan penutupan halaman saat gagal; menyamakan `maxLength` input Room menjadi `50` untuk Lecture (`100` untuk Meeting/External); serta memvalidasi `startTime < endTime` (`Invalid Time Range`) sebelum konfirmasi.
- **`profile_page.dart`:** Memanggil `ScheduleRepository().clearLocalCache()` saat Sign Out.

### 3.4 Modul Fuzzy Mamdani XAI (`/api/smart-priority`) & CRUD Tugas (`/api/tasks`)
- **Engine Inferensi Mamdani (`backend/lib/services/fuzzy_mamdani_service.dart`):**
  - **Fuzzifikasi 2 Input:**
    - `hoursRemaining` (`0..336` jam; overdue `< 0` clamped ke `0`): `Urgent (0,0,12,92)`, `Moderate (12,120,240)`, `Relaxed (120,288,336,336)`.
    - `gradeWeight` (`0..100`%): `Low (0,0,10,25)`, `Medium (10,25,40)`, `High (25,40,100,100)`.
  - **9 Aturan Mamdani Min-Max** ($3 \times 3$) memetakan kombinasi ke `LOW`, `MEDIUM`, dan `HIGH`.
  - **Agregasi & Defuzzifikasi Centroid (CoG)** pada domain $z = 0 \dots 100$ (`LOW (0,0,20,45)`, `MEDIUM (25,50,75)`, `HIGH (55,80,100,100)`), menghasilkan skor `0.0–100.0`, label `HIGH` (`>= 65.0`), `MEDIUM` (`>= 38.0`), `LOW` (`< 38.0`), serta detail Explainable AI (`deadlineParam`, `courseWeightParam`, `aggregationAreaText`, `reasonExplanation`, `firedRules`).
- **CRUD Tugas (`task.dart`, `task_controller.dart`, `task_routes.dart` — `/api/tasks`):**
  - Endpoint `GET /api/tasks` (filter `?isCompleted=`, `?priority=`, `?idCourse=`, `?q=`), `GET /api/tasks/<idTask>`, `POST /api/tasks`, `PUT /api/tasks/<idTask>`, `PATCH /api/tasks/<idTask>/complete`, `DELETE /api/tasks/<idTask>`.
  - Penghitungan Fuzzy otomatis pada `create`/`update` ketika `isFuzzyAuto = true`, dukungan `tags::jsonb` (maks 20 tag), flag integer `0`/`1`, validasi ketat (`gradeWeight` `0..100`, `title <= 150`), proteksi BOLA, serta integrasi `idCourse`/`courseName` + auto-cleanup custom course.
- **Smart Priority Ranking & XAI (`smart_priority_controller.dart`, `smart_priority_routes.dart` — `/api/smart-priority`):**
  - `GET /api/smart-priority` (opsional `?level=HIGH|MEDIUM|LOW`): evaluasi realtime seluruh tugas aktif (`is_completed = 0`), urut skor tertinggi → deadline terdekat, sertakan `rank`, `rankLabel`, `summary` (`total`, `high`, `medium`, `low`), dan baca status `is_fuzzy_model_active` & `score_explainability_enabled` dari `user_preferences`.
  - `POST /api/smart-priority/evaluate`: simulasi kalkulasi Fuzzy & XAI untuk `(deadline, gradeWeight)` tanpa menyimpan ke DB.
  - `POST /api/smart-priority/recalculate`: hitung ulang dan perbarui `priority_score` & `priority` seluruh tugas aktif auto-Fuzzy di DB dalam 1 transaksi.

### 3.5 Prioritas 2A — Modul Tim / Kelompok (`/api/groups`)
- **Repository, Controller, & Router 6 Tabel (`group_repository.dart`, `group_controller.dart`, `group_routes.dart`):**
  - **Groups & Members (`groups`, `group_member`):**
    - `GET /api/groups` (dukungan `?q=`, menyertakan `myRole`, `memberCount`, `activeTasksCount`, `upcomingMeetingsCount`), `POST /api/groups` (invite code acak 6–7 karakter, pembuat jadi `LEADER`), `GET /api/groups/<idGroup>` (detail + daftar anggota ter-join `users`), `PUT /api/groups/<idGroup>` (`LEADER` only), `POST /api/groups/join` (cek `409` duplikat, sinkron `group_size`), `DELETE /api/groups/<idGroup>/leave` (`409` jika `LEADER` keluar saat masih ada anggota lain), `DELETE /api/groups/<idGroup>` (`LEADER` only, hapus berjenjang *child-first* di seluruh 6 tabel tanpa orphan).
  - **Milestones (`group_milestone`):**
    - `GET / POST / PUT / DELETE /api/groups/<idGroup>/milestones` dengan kalkulasi `totalTasks`, `completedTasks`, dan `progressPercent`. Saat dihapus, `group_task.id_milestone` di-set `NULL` terlebih dahulu dalam transaksi.
  - **Group Tasks (`group_task`) & Subtasks (`group_sub_task`):**
    - `GET / POST / PUT / PATCH .../complete / DELETE /api/groups/<idGroup>/tasks...` (filter `?assignedToMe=true`, `?idMilestone=`, `?isCompleted=`, validasi `idAssignedTo` wajib anggota kelompok, auto-Fuzzy saat `isFuzzyAuto = true`, `tags::jsonb`, serta pembatasan `PATCH .../complete` hanya untuk `id_assigned_to` atau `LEADER` — anggota lain ditolak `403`).
    - `GET / POST / PATCH .../complete / DELETE /api/groups/<idGroup>/tasks/<idGroupTask>/subtasks...` dengan proteksi akses penyelesaian yang sama.
  - **Meetings (`meeting_schedule`):**
    - `GET / POST / PUT / DELETE /api/groups/<idGroup>/meetings`.
- **Keamanan:** Seluruh endpoint diawali pemeriksaan `_requireMembership` (outsider ditolak `403 Forbidden`).

### 3.6 Tata Kelola Skills & Dokumentasi Proyek
- Penambahan skill `impal-backend-engineer` (`introspect_schema.dart`, `live_schema_snapshot.md`) dan `sync-project-skills` (`validate_agent_sync.dart`).
- Pembaruan `AGENTS.md` (7.861 bytes), `.agents/rules/`, `.agents/memory/`, `.agents/features/` (`backend_priority0_hardening.md`, `backend_course_id_migration.md`, `backend_fuzzy_tasks_module.md`, `backend_groups_module.md`), `ROADMAP_AUDIT_DAN_PENINGKATAN.md`, serta laporan ini.

---

## 4. Daftar Berkas yang Dibuat & Dimodifikasi

### Backend (`Impal-02-07/backend/`)
| Status | Berkas | Ringkasan Peran |
| :--- | :--- | :--- |
| Modified | `lib/config/db.dart` | Connection pool `Pool.withEndpoints`, transaksi `DbTransaction`, fail-fast `.env` |
| Modified | `.env.example` | Variabel `DB_POOL_MAX` & `DB_SSL` |
| Modified | `bin/server.dart` & `routes/index.dart` | Mount `/api/courses`, `/api/tasks`, `/api/smart-priority`, `/api/groups`, & graceful shutdown `SIGINT` |
| Modified | `routes/test_db.dart`, `routes/tables.dart` | Sanitasi pesan error database |
| Modified | `lib/models/auth/user_model.dart`, `lib/controllers/auth/auth_controller.dart` | Kolom `id_user`, normalisasi email, validasi register/login |
| Modified | `lib/models/agenda/course_schedule.dart`, `personal_schedule.dart` | Transaksi atomik, migrasi `id_course`, auto-cleanup custom course, child-first delete |
| Modified | `lib/controllers/agenda/agenda_controller.dart` | Validasi jam/panjang field & penanganan `idCourse`/`courseName` |
| Modified | `lib/models/profile/profile_model.dart`, `lib/controllers/profile/profile_controller.dart` | Query agregasi `getProfile`, integer flag `0/1`, relasi `id_course` |
| Created | `lib/models/course/course_model.dart`, `lib/controllers/course/course_controller.dart`, `lib/routes/course/course_routes.dart` | Modul katalog `/api/courses`, kuota 30/user, BOLA, `resolveOrCreateForSchedule`, `cleanupUnusedCustomCourse` |
| Created | `lib/services/fuzzy_mamdani_service.dart` | Engine Fuzzy Mamdani Min-Max + Centroid CoG + output XAI |
| Modified | `lib/models/task/task.dart` | Query PostgreSQL `task`, auto-Fuzzy, `tags::jsonb`, `recalculateAllForUser`, auto-cleanup custom course |
| Created | `lib/controllers/task/task_controller.dart`, `lib/routes/task/task_routes.dart` | Controller & router CRUD `/api/tasks` |
| Created | `lib/controllers/smart_priority/smart_priority_controller.dart`, `lib/routes/smart_priority/smart_priority_routes.dart` | Controller & router `/api/smart-priority` (`GET /`, `POST /evaluate`, `POST /recalculate`) |
| Created | `lib/models/kelompok/group_repository.dart`, `lib/controllers/group/group_controller.dart`, `lib/routes/group/group_routes.dart` | Modul `/api/groups` lengkap 6 tabel (`groups`, `group_member`, `group_milestone`, `group_task`, `group_sub_task`, `meeting_schedule`) |
| Created | `database/001_recommended_indexes.sql`, `database/002_course_id_migration.sql` | Skrip index & migrasi atomik `course_code` -> `id_course` |
| Created | `test/priority0_test.dart`, `test/fuzzy_and_tasks_test.dart`, `test/groups_test.dart` | Unit test & integration test langsung ke PostgreSQL live |

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
- `.agents/skills/impal-backend-engineer/` & `.agents/skills/sync-project-skills/`
- `.agents/features/` (`backend_priority0_hardening.md`, `backend_course_id_migration.md`, `backend_fuzzy_tasks_module.md`, `backend_groups_module.md`)
- `.agents/rules/`, `.agents/memory/`, `AGENTS.md`, `ROADMAP_AUDIT_DAN_PENINGKATAN.md`, `LAPORAN_AUDIT_DAN_PERUBAHAN_BACKEND.md`

---

## 5. Hasil Pengujian & Verifikasi

### 5.1 Pengujian Otomatis (`dart analyze`, `dart test`, `flutter analyze`, Sync Validator)
- **`dart analyze`** (`Impal-02-07/backend`): **`No issues found!`** (`0` error/warning).
- **`dart test -r expanded`** (`Impal-02-07/backend`): **`All tests passed!` (14/14 kasus uji)** langsung terhadap live PostgreSQL `db_manajemen_tugas`:
  - `test/fuzzy_and_tasks_test.dart` (**6 kasus uji**): 5 unit test matematis `FuzzyMamdaniService` (urgent+high, overdue, moderate+medium, relaxed+low, monotonicity) + 1 integration test E2E `/api/tasks` CRUD, validasi `400`, BOLA `404`, ranking `/api/smart-priority`, `POST /evaluate`, `PATCH /complete`, `POST /recalculate`, & auto-cleanup custom course.
  - `test/groups_test.dart` (**1 suite E2E komprehensif** dengan 3 user): create group, invite code join (`group_size`), invalid/dup join (`404`/`409`), BOLA outsider/member (`403`), milestones + `progressPercent`, group tasks + auto-Fuzzy + penolakan non-member assignee (`400`) + pembatasan complete (`403`), subtasks CRUD, meetings CRUD, leader leave guard (`409`), dan orphan-free disband di seluruh 6 tabel.
  - `test/priority0_test.dart` (**7 kasus uji**): validasi & auth (`400`/`409`/`200`), agregasi integer flag profile, CRUD agenda kuliah & personal, `/api/courses` CRUD + BOLA + in-use guard + kuota 30, auto-cleanup custom course, serta konkurensi 10 query `Pool`.
- **`validate_agent_sync.dart`**: **`PASS`** (`AGENTS.md` size `7861 / 24000 bytes`).
- **`flutter analyze`** (`Impal-02-07/frontend`): **`No issues found!`** (`0` error/warning).

### 5.2 QA Manual End-to-End (Browser Chrome + PowerShell + HeidiSQL)
- **Auth & Schedule Frontend–Backend:** Register akun baru (`users`), penolakan duplikat (`409`), login ulang, create/edit jadwal dengan `id_course` + `id_user`, persistensi pasca-close browser, rollback jam tidak valid, hapus jadwal bebas orphan, dan clear cache saat logout — **Lulus**.
- **Fuzzy XAI & `/api/tasks` (`UC-1` s.d. `UC-5`):** Simulasi `POST /evaluate`, pembuatan tugas auto-Fuzzy (`HIGH` & `LOW`), ranking `GET /api/smart-priority`, toggle selesai & `POST /recalculate`, validasi/BOLA, serta hapus bersih + auto-cleanup — **Lulus**.
- **Modul Tim `/api/groups` (`UC-1` s.d. `UC-4`):** Create group & join via invite code, milestone + tugas tim (auto-Fuzzy `HIGH`) + subtask + jadwal rapat, role guard `403` saat non-assignee mencoba menyelesaikan tugas & perhitungan `progressPercent`, serta leave & disband bebas orphan di seluruh 6 tabel — **Lulus**.

---

## 6. Rencana Pengembangan Berikutnya
1. **Prioritas 2B:** Endpoint `/api/notifications` (`notification`, dukungan `dedup_key` & integer flag `is_read = 0/1`) dan `/api/dashboard/summary` (agregasi beranda dalam 1 request).
2. **Prioritas 3:** Endpoint `/api/profile/preferences` (`user_preferences`), `/api/todos` (`todo_item`), `/api/tags` (`task_tags`), alur Forgot/Reset Password OTP, serta pembersihan endpoint legacy di `frontend/lib/core/network/api_endpoints.dart`.
