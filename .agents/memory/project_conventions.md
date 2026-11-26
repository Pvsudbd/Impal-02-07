# 🏷️ Memory: Konvensi Khusus Proyek (Proyek IMPAL)
<!-- Berkas ini merekam konvensi baku, format data, dan token khusus untuk proyek IMPAL -->

### 1. Standar Header Terpadu (Unified Home Header)
- Format sapaan: `Hi $userName`, avatar profil inisial di sisi kanan atas dengan popup konfirmasi Sign Out saat diketuk.
- Subtitle adaptif berwarna `AppColors.primaryAccent`:
  - Tab Home: `$count task pending` (dengan tabular numbers)
  - Tab Task: `Task`
  - Tab Team List: `Team List`
  - Tab Schedule: `Schedule`
- Dilarang menampilkan tombol panah kembali (*back button*) saat berada di dalam tab navigasi utama shell.

### 2. Standar Alur Edit Kartu Tugas (Task Edit Routing)
- Tugas Kelompok (`isTeamTask == true`, memiliki anggota/kelompok): Langsung diarahkan ke `DashboardTeamPage`.
- Tugas Personal/Pribadi: Diarahkan ke formulir `EditTaskPage`.

### 3. Standar Penanda Deadline & Durasi (Due Badge)
- Bentuk kapsul pill melingkar penuh (`BorderRadius.circular(999)`).
- Warna: Sky Blue `Color(0xFF5B93FF)` (normal/non-urgent) & Coral `Color(0xFFFF7D65)` (urgent/overdue) dengan teks putih.
- Tipografi: Tabular figures (`FontFeature.tabularFigures()`), font 10.5sp bold.
- Ikon batas waktu: Wajib ikon jam bulat coral sebelum teks deadline (`Sat 11 Oct 2026, 23:59 WIB`).
- Posisi: Pinned di sudut kanan atas kartu tugas.

### 4. Standar Token Warna Prioritas Tugas
- **High**: Background `AppColors.primary` (`Color(0xFFFF5E4D)`), teks `Colors.white`.
- **Medium**: Background `Color(0xFFFBBF24)` (Warm Amber), teks `Color(0xFF1F2937)` (Dark Slate).
- **Low**: Background `Color(0xFF6EE7B7)` (Mint Green), teks `Color(0xFF064E3B)` (Dark Green).

### 5. Kartu Tugas Tim (`TeamTaskCard`)
- Due Badge di sudut kanan atas bersebelahan dengan Priority Badge.
- Tombol edit di sudut kanan bawah berupa **ikon pensil abu-abu murni** (`Icons.edit_rounded`, warna `AppColors.textMuted`) tanpa teks.

### 6. Arsitektur Adaptif Desktop (Layar $\ge 1024$ dp)
- **Bottom Navigation Bar** $\to$ **Navigation Rail / Left Sidebar**.
- **Single Column List** $\to$ **Master-Detail Split View** (panel kiri 380 dp daftar tugas, panel kanan detail & editor).
- **Modal Bottom Sheet** $\to$ **Centered Dialog Box**.

### 7. Pop-Up Pemberitahuan, Dialog & Aksi (100% English UI Mandate & Strict Sentiment Color Law)
- **ATURAN MUTLAK BAHASA INGGRIS:** Seluruh teks notifikasi (`PopUpPemberitahuan`), judul, pesan, dialog konfirmasi (`PopUpKonfirmasiDelete`), toast SnackBar, validasi form, dan alert sistem **WAJIB 100% MENGGUNAKAN BAHASA INGGRIS** tanpa terkecuali.
- **HUKUM BAKU WARNA SENTIMEN NOTIFIKASI:**
  - **HAL POSITIF MUTLAK HIJAU (`#10B981`):** Create, Update, Completed, Verify Success.
  - **HAL NEGATIF / PERINGATAN MUTLAK ORANYE (`#FA6144`):** Delete, Form Warning, Access Denied.
- Setiap aksi mutasi data wajib memicu `PopUpPemberitahuan` / `PopUpPemberitahuanTeam`.

### 8. Paritas Wording Modal Formulir Desktop (Desktop Form Modal Parity)
- Mengacu lengkap pada [desktop_form_modal_rules.md](../rules/desktop_form_modal_rules.md): tanpa subtitle tambahan di header modal bila mobile tidak menampilkannya, Title Case konsisten mobile, tutup via `[✕]` kanan atas tanpa tombol `Cancel` redundan.

### 9. Dokumentasi, Roadmap & Sinkronisasi Skill Wajib
- Selesai mengerjakan fitur, bugfix, atau refactoring, **WAJIB** memperbarui [ROADMAP_AUDIT_DAN_PENINGKATAN.md](../../ROADMAP_AUDIT_DAN_PENINGKATAN.md), `.agents/features/<fitur>.md`, dan menjalankan `.agents/skills/sync-project-skills/SKILL.md`.

### 10. Standar Teknologi & Konvensi Live Backend (Dart Frog & PostgreSQL)
- **Framework REST API**: **Dart Frog** (`dart_frog`) + Shelf sub-routers pada `PORT=3000`.
- **Koneksi Database**: **PostgreSQL** (`db_manajemen_tugas`) via `Database.getPool()` (`Pool.withEndpoints`) dan `Database.transaction((tx) async { ... })` di `backend/lib/config/db.dart`. Kredensial wajib dari `.env` (tanpa hardcoded fallback).
- **Format Envelope JSON**: `{ "status": "success" | "error", "message": "...", "data": ... }`.
- **Kontrak `GET /api/agenda`**: Mengembalikan `data` berupa `List` gabungan (`CourseSchedule` + `PersonalSchedule`) agar kompatibel dengan `ScheduleRepository` di frontend.
- **Konvensi Skema Live DB (`db_manajemen_tugas`)**:
  - Semua tabel kepemilikan user memakai `id_user` (bukan `id_student`).
  - Kolom flag legacy (`task.is_completed`, `task.is_fuzzy_auto`, `group_task.is_completed`, `group_task.is_fuzzy_auto`, `group_sub_task.is_completed`, `notification.is_read`, `todo_item.is_done`) bertipe **`integer` (`0`/`1`)** — query wajib memakai `= 1` / `= 0`.
  - Kolom `task.priority` dan `group_task.priority` bertipe `VARCHAR(6)` (`HIGH`, `MEDIUM`, `LOW`).
  - Tabel legacy tidak memiliki FK `ON DELETE CASCADE` di DB live, sehingga `delete` wajib menghapus tabel anak lalu tabel induk dalam `Database.transaction`.
  - Tabel `users` dan `agenda` tidak memiliki default timestamp di DB live, sehingga `INSERT`/`UPDATE` wajib menyertakan `NOW()`.
- **Dokumentasi Arsitektur**: [backend_dart_frog_architecture.md](../features/backend_dart_frog_architecture.md), [DART_FROG_ARCHITECTURE.md](../../document/DART_FROG_ARCHITECTURE.md), dan [live_schema_snapshot.md](../skills/impal-backend-engineer/references/live_schema_snapshot.md).
