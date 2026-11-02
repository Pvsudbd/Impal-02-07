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

### 7. Pop-Up Pemberitahuan, Dialog & Aksi (100% English UI Mandate)
- **ATURAN MUTLAK BAHASA INGGRIS:** Seluruh teks notifikasi (`PopUpPemberitahuan`), judul, pesan, dialog konfirmasi (`PopUpKonfirmasiDelete`), toast SnackBar, validasi form, dan alert sistem **WAJIB 100% MENGGUNAKAN BAHASA INGGRIS** tanpa terkecuali. Dilarang keras menggunakan bahasa Indonesia pada string UI / pop-up.
- Setiap aksi mutasi data (Create, Update, Delete, Submit Form) wajib memicu `PopUpPemberitahuan` / `PopUpPemberitahuanTeam`.
- Desain: Dark container (`#323846` / `#282D37`), icon badge berwarna (Hijau untuk positif, Orange/Coral untuk peringatan/negatif, Sky Blue untuk info/netral), auto-dismiss.

### 8. Dokumentasi & Roadmap Wajib
- Selesai mengerjakan fitur, bugfix, atau refactoring, **WAJIB** memperbarui [ROADMAP_AUDIT_DAN_PENINGKATAN.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/ROADMAP_AUDIT_DAN_PENINGKATAN.md).
