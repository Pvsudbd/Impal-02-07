# 🛠️ Bug Fix: Presistensi Tugas Tim & Milestone di Team Dashboard (Grup CihuyOtomotif)
<!-- Lokasi Resmi: .agents/features/team_task_persistence_milestone_fix.md -->

Dokumentasi investigasi, perbaikan akar masalah (*root cause*), dan verifikasi end-to-end atas kegagalan persistensi penyimpanan tugas tim (*team task*) saat menggunakan fitur milestone di database remote PostgreSQL.

---

## 📅 Tanggal & Status
- **Tanggal**: 22 November 2026
- **Penanggung Jawab**: Tim Backend (Yoga & Habindra)
- **Status**: **RESOLVED & VERIFIED 100%**
- **Domain Terkait**: Kelompok (`groups`), Tugas Kelompok (`group_task`), Milestone Kelompok (`group_milestone`), Dart Frog REST API, PostgreSQL Constraints.

---

## 🔍 1. Investigasi Gejala & Laporan Masalah
**Gejala:**
Pada halaman `TeamDashboard` (khususnya grup *"CihuyOtomotif"*), ketika pengguna membuat tugas baru menggunakan fitur *Milestone* (`Create Task` $\to$ pilih Milestone $\to$ Simpan):
1. Tugas muncul sementara di antarmuka tim (*optimistic UI* di memori RAM).
2. Data tugas tidak tersimpan ke database remote PostgreSQL.
3. Saat halaman di-refresh, tugas menghilang karena `fetchTasksFromApi()` memuat ulang data kosong dari server.

---

## 🧩 2. Akar Masalah Teknis (Root Causes)

1. **Akar Masalah 1: Error Fatal PostgreSQL 42P10 (`ON CONFLICT`)**
   - Di `backend/lib/controllers/kelompok/group_controller.dart`, query insert `createGroupTask` sebelumnya menggunakan:
     ```sql
     INSERT INTO group_task (...) VALUES (...)
     ON CONFLICT (id_group_task) DO NOTHING
     ```
   - Namun pada tabel fisik PostgreSQL `group_task`, kolom `id_group_task` **tidak memiliki `PRIMARY KEY` maupun `UNIQUE` constraint**.
   - PostgreSQL secara ketat menolak klausa `ON CONFLICT` tanpa constraint unik dengan error:
     `Severity.error 42P10: there is no unique or exclusion constraint matching the ON CONFLICT specification`.
   - Hal ini memicu exception 500 *Internal Server Error* setiap kali endpoint `POST /api/groups/<idGroup>/tasks` dipanggil.

2. **Akar Masalah 2: Foreign Key Violation `group_task_id_milestone_fkey` (Error 23503)**
   - Kolom `id_milestone` pada tabel `group_task` memiliki Foreign Key yang mengarah ke `group_milestone(id_milestone)`.
   - Jika `id_milestone` dikirim sebagai string kosong `""` atau ID yang belum tersinkron di PostgreSQL, PostgreSQL melempar error:
     `Severity.error 23503: insert or update on table "group_task" violates foreign key constraint "group_task_id_milestone_fkey"`.

3. **Akar Masalah 3: Batasan Panjang Karakter Kolom Priority `VARCHAR(6)`**
   - Kolom `priority` di tabel `group_task` memiliki tipe data `VARCHAR(6)` (`HIGH`, `MEDIUM`, `LOW`).
   - Jika ada nilai seperti `'VERY HIGH'` (9 karakter), query akan gagal akibat `value too long for type character varying(6)`.

4. **Akar Masalah 4: Ketiadaan Endpoint CRUD Lengkap untuk Tugas Tim**
   - Di `group_routes.dart` dan `group_controller.dart`, sebelumnya belum tersedia endpoint `PUT` (update tugas), `DELETE` (hapus tugas), dan `PATCH` (toggle selesai tugas), serta di `team_task_repository.dart` mutasi lokal belum mem-push perubahan update/delete/toggle ke API.

5. **Akar Masalah 5: Case-Sensitivity User Database PostgreSQL di `db.dart`**
   - Username fallback di `db.dart` sebelumnya tertulis `'Todolist_Dev'` (huruf besar `T`), sedangkan PostgreSQL user resmi adalah `'todolist_dev'` (huruf kecil).

---

## 🛠️ 3. Solusi & Perbaikan Bedah (*Surgical Changes*)

### A. Backend (`backend/lib/controllers/kelompok/group_controller.dart`)
1. **Pola Check-Then-Insert/Update Aman 42P10**:
   - Menghapus klausa `ON CONFLICT (id_group_task) DO NOTHING`.
   - Menggantinya dengan pemeriksaan eksistensi:
     ```dart
     final existingTask = await Database.query(
       'SELECT id_group_task FROM group_task WHERE id_group_task::text = @id LIMIT 1',
       {'id': idGroupTask},
     );
     ```
   - Jika sudah ada, jalankan `UPDATE group_task`; jika belum ada, jalankan `INSERT INTO group_task`.
2. **Validasi & Sanitasi `id_milestone`**:
   - Memeriksa keberadaan milestone di `group_milestone` terlebih dahulu. Jika tidak ditemukan atau bernilai kosong, `id_milestone` disetel ke `null` (bukan string kosong `""`) agar tidak memicu pelanggaran Foreign Key 23503.
3. **Sanitasi Kolom `priority`**:
   - Menjaga panjang karakter string prioritas selalu $\le 6$ karakter (`HIGH`, `MEDIUM`, `LOW`).
4. **Implementasi Endpoint CRUD Lengkap**:
   - `PUT /api/groups/<idGroup>/tasks/<idTask>`: Memperbarui detail tugas kelompok.
   - `DELETE /api/groups/<idGroup>/tasks/<idTask>`: Menghapus tugas kelompok.
   - `PATCH /api/groups/<idGroup>/tasks/<idTask>/toggle`: Toggle status selesai (`is_completed`).

### B. Routing Backend (`backend/lib/routes/kelompok/group_routes.dart`)
- Mendaftarkan rute `router.put`, `router.delete`, dan `router.patch` di bawah `/api/groups/<idGroup>/tasks/<idTask>` lengkap dengan `checkAuthMiddleware()`.

### C. Konfigurasi Koneksi Basis Data (`backend/lib/config/db.dart`)
- Memperbaiki username fallback menjadi `todolist_dev` dan menambahkan kandidat pencarian file `.env` multi-direktori.

### D. Sinkronisasi Frontend (`frontend/lib/presentation/features/team/models/team_task_repository.dart`)
- Menambahkan method sinkronisasi API:
  - `_pushUpdateTask(teamCode, task)`
  - `_pushDeleteTask(teamCode, taskId)`
  - `_pushToggleTask(teamCode, taskId)`
  - `_pushSetTaskMilestone(teamCode, taskId, milestoneId)`
- Memanggil method push tersebut saat `updateTask`, `deleteTask`, `toggleTaskCompletion`, dan `setTaskMilestone` dieksekusi di aplikasi klien.

---

## 🧪 4. Hasil Pengujian & Verifikasi
Pengujian end-to-end dilakukan langsung terhadap server PostgreSQL:
1. **Pembuatan Tugas dengan Milestone**:
   - Request `POST /api/groups/CihuyOtomotif/tasks` dengan parameter `id_milestone: milestone_1795319898865`.
   - **Hasil**: HTTP 201 Created. Data berhasil tersimpan di tabel `group_task`.
2. **Pengambilan Tugas Kelompok**:
   - Request `GET /api/groups/CihuyOtomotif/tasks`.
   - **Hasil**: HTTP 200 OK. Tugas ditemukan lengkap dengan `id_milestone`.
3. **Pengambilan Milestone Kelompok**:
   - Request `GET /api/groups/CihuyOtomotif/milestones`.
   - **Hasil**: HTTP 200 OK. Array `task_ids` pada milestone memuat ID tugas yang baru dibuat.
4. **Pembaruan & Penghapusan**:
   - Request `PUT` dan `DELETE` berhasil dieksekusi dengan status 200 OK.
5. **Anti-42P10 & Anti-FK Crash**:
   - Uji coba insert ulang berhasil tanpa error 42P10 maupun 23503.

---

## 👥 5. Bug Fix Lanjutan: Presistensi Penugasan Anggota (`id_assigned_to`) & Status Unassigned

### A. Gejala & Masalah yang Dilaporkan
- Di database remote PostgreSQL, kolom `id_assigned_to` pada tabel `group_task` selalu bernilai `NULL`.
- Akibatnya, ketika salah satu anggota kelompok (misalnya akun **Habindra**) melakukan login, tugas kelompok yang telah ditugaskan kepadanya menampilkan status **"Unassigned"**, dan task tersebut tidak terhubung ke akun Habindra.

### B. Akar Masalah Teknis
1. **Omission pada DTO Frontend**:
   - `TeamTaskModel.toApiMap()` sebelumnya tidak menyertakan key `'id_assigned_to'` maupun `'assigned_to'` ke payload request backend.
   - Properti `assignedMemberId` belum ada di `TeamTaskModel` sehingga ID pengguna yang dipilih dari dropdown assignee hilang sebelum sampai ke repository.
2. **Keterbatasan Resolver Assignee Backend**:
   - Helper `_findUserById` di `group_controller.dart` hanya mencari user via perbandingan `id_user::text = @uid` dan `id_student::text = @uid`.
   - Jika payload mengirimkan nama pengguna (seperti `"Habindra Dzaky"`) atau multi-nama `"Habindra Dzaky, Yoga Perkasa"`, pencarian gagal dan mengembalikan `null`.
   - Tidak ada mekanisme fallback pencarian anggota melalui tabel relasi `group_member`.

### C. Solusi & Perbaikan
1. **Frontend Integration Layer**:
   - **`TeamTaskModel`**: Menambahkan field `final String? assignedMemberId;`, membaca `id_assigned_to` di `fromMap()`, dan menyertakan `id_assigned_to` serta `assigned_to` di `toApiMap()`.
   - **`TeamTaskRepository`**: Memastikan `_pushCreateTask` dan `_pushUpdateTask` mengirimkan `id_assigned_to` dan `assigned_to`. Memperkuat `isTaskAssignedToUser` dengan pencocokan multi-token nama.
   - **`CreateTaskTeamPage` & `DesktopTeamTaskModal`**: Meneruskan ID anggota penanggung jawab utama (`_selectedMembers.first.id`) ke `assignedMemberId` saat membuat atau mengedit task.
2. **Backend Robust Assignee Resolver**:
   - Di `group_controller.dart`, menambahkan helper `_resolveAssignedUser(input, {idGroup})`:
     1. Menangani multi-assignee (memisahkan tanda koma dan mengambil PIC utama).
     2. Menghapus prefix umum (`member_`, `leader_`, `mem_`, `user_`).
     3. Mencari user via ID (`id_user` / `id_student`).
     4. Mencari via `group_member.id_member`.
     5. Mencari nama anggota di kelompok aktif (`group_member` JOIN `users`).
     6. Fallback pencarian di tabel `users` via nama (`LOWER(name)`, `ILIKE`) atau email.
   - Menerapkan `_resolveAssignedUser` pada `createGroupTask` dan `updateGroupTask`.
   - Menambahkan `'id_assigned_to': effectiveAssignedTo` pada response payload `POST /api/groups/<idGroup>/tasks`.

### D. Verifikasi
- Pengujian end-to-end langsung ke remote DB:
  1. `Case A (UUID Habindra)`: `id_assigned_to` tersimpan `2b70a86a-60ec-44cf-8966-1e1bff2882e2`, `pic_name` keluar `Habindra Dzaky`.
  2. `Case B (Nama string 'Habindra Dzaky')`: Backend me-resolve nama ke UUID `2b70a86a-60ec-44cf-8966-1e1bff2882e2`, `pic_name` keluar `Habindra Dzaky`.
  3. `Case C (Multi assignee 'Habindra Dzaky, Yoga Perkasa')`: Backend me-resolve PIC utama ke UUID `2b70a86a-60ec-44cf-8966-1e1bff2882e2`, `pic_name` keluar `Habindra Dzaky`.
- Static analysis: `dart analyze` di backend & frontend mencatat **0 issues found**.

