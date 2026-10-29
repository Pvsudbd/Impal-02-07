# 📑 Dokumen Audit & Roadmap Peningkatan Aplikasi: IMPAL Smart Task Manager
> **Status:** Analisis Komprehensif Seluruh Halaman & Alur Pengguna  
> **Tanggal Rilis:** 29 Oktober 2026  
> **Arsitektur:** Flutter Feature-First, Single-Shell Navigation, ResponsiveContext, 60 FPS HP Kentang Compliance  

---

## 📌 1. Ringkasan Eksekutif & Status Sistem Saat Ini

Aplikasi **IMPAL Smart Task Manager** telah memiliki fondasi antarmuka yang sangat solid dengan estetika modern dark theme (`#282D37`, `#323846`), tipografi Inter terstandarisasi, responsivitas dinamis (`ResponsiveContext`), animasi navigasi meluncur (*sliding scooped notch bottom nav*), serta kepatuhan penuh terhadap pedoman **`AGENTS.md`** (0 Error & 0 Warning pada static analysis).

Meskipun komponen visual utama telah selesai dan terhubung, masih terdapat **fitur-fitur fungsional yang belum tuntas (incomplete/mock)**, **peluang optimalisasi alur navigasi**, serta **penyempurnaan mikro-interaksi** agar aplikasi terasa seperti produk produksi kelas enterprise.

Dokumen ini membedah secara mendalam seluruh halaman aplikasi, memetakan apa saja yang **belum ada**, serta merumuskan rekomendasi konkret peningkatan dari sisi **Desain Visual (UI)** dan **Kemudahan Navigasi Pengguna (UX)**.

---

## 🔍 2. Audit Detail Halaman per Halaman (Page-by-Page Inspection)

---

### A. Modul Autentikasi (`lib/presentation/features/auth/`)
Halaman: `Login`, `Register`, `ForgotPassword`, `VerificationCode`, `ResetPassword`, `TermsPrivacy`.

| Halaman | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Login (`login_page.dart`)** | Validasi input, toggle visibilitas password, status loading dengan proteksi double-submit, popup notifikasi sukses. | 1. **Remember Me Tidak Persisten**: Checkbox "Remember me" hanya menyimpan state lokal variabel, belum menyimpan username/token ke SharedPreferences.<br>2. **Integrasi SSO Kampus**: Belum ada login menggunakan Google atau SSO Telkom University.<br>3. **Biometrik**: Belum mendukung Fingerprint/FaceID. | • Pasang `AutofillHints.username` & `AutofillHints.password` agar iOS Keychain & Android Password Manager bisa autofill.<br>• Set `textInputAction: TextInputAction.next` pada email dan `done` pada password yang memicu `_handleSignIn` saat tombol Enter keyboard ditekan. |
| **Register (`regist_page.dart`)** | Indikator kekuatan password 4 kriteria interaktif, konfirmasi password realtime, checkbox Terms & Privacy. | 1. **Penyimpanan Akun Baru**: Data register belum disimpan ke database lokal/backend sehingga akun baru tidak bisa langsung dipakai login kembali setelah restart. | • Berikan tombol pratinjau cepat (modal bottom sheet) untuk membaca ringkasan Terms & Privacy tanpa harus berpindah halaman penuh.<br>• Tampilkan helper text format email kampus (`@student.telkomuniversity.ac.id`). |
| **Forgot Password & OTP (`forgot_password_page.dart`, `verification_code_page.dart`)** | Pilihan pemulihan (Email vs SMS), kotak OTP 4 digit responsif dengan auto-focus, popup panduan bantuan. | 1. **Timer Resend OTP**: Belum ada countdown mundur aktif (misal: "Kirim ulang dalam 59 detik") sebelum tombol resend diizinkan aktif kembali.<br>2. **SMS Gateway / Email Delivery**: Masih mock simulasi delay lokal. | • Tambahkan fitur *Auto-paste OTP* dari clipboard/SMS Retriever API.<br>• Animasi shake pada kotak OTP jika kode yang dimasukkan keliru. |
| **Reset Password (`reset_password_page.dart`)** | Form password baru dengan checklist keamanan dan konfirmasi password. | 1. **Invalidasi Sesi Lama**: Belum ada mekanisme untuk logout dari perangkat lain setelah reset password berhasil. | • Tambahkan indikator progress langkah (Step 1: Request -> Step 2: Verify -> Step 3: Reset Password) di bagian atas kartu. |

---

### B. Halaman Dashboard / Home (`lib/presentation/features/dashboard/`)
Halaman: `HomePage`, `HomeHeader`, `HomeCategoriesSection`, `HomeScheduleSection`, `HomeTaskCard`.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Header (`HomeHeader`)** | Salam dinamis `Hi $userName`, subtitle tabular figures `$count task pending`, avatar inisial dengan popup konfirmasi Sign Out. | 1. **Pengaturan Profil**: Mengetuk avatar hanya menampilkan opsi Sign Out, belum ada halaman untuk mengedit nama, foto profil, atau NIM mahasiswa. | • Tambahkan badge notifikasi kecil (lonceng/titik merah) di samping avatar jika ada tugas yang mendekati deadline (< 12 jam). |
| **Kategori (`HomeCategoriesSection`)** | Kartu kategori "College" & "Personal" dengan hitungan tugas dan ikon yang serasi. | 1. **Filter Kategori Tidak Berfungsi**: Mengetuk "College" atau "Personal" hanya mengubah warna outline kartu, **namun belum menyaring daftar tugas Ongoing Task di bawahnya**.<br>2. **Tombol Tambah Kategori (+)**: Hanya memunculkan toast "Add category coming soon!", belum ada dialog/form untuk membuat kategori kustom baru. | • Hubungkan state `_selectedCategory` ke filter daftar kartu `_tasks` di bawahnya.<br>• Sediakan popup tambah kategori baru (Nama kategori + pilihan ikon + warna aksen). |
| **Jadwal Hari Ini (`HomeScheduleSection`)** | Preview jadwal kuliah yang sedang berlangsung (Ongoing) dengan status badge, jam, dan lokasi. Tombol "See all" mulus mengarahkan ke Tab Schedule. | 1. **Status Dinamis**: Status 'Ongoing' masih statis, belum menyesuaikan dengan jam perangkat saat ini (misal berubah otomatis menjadi 'Completed' jika jam kelas telah lewat). | • Berikan indikator visual garis waktu (progress bar) berapa persen jam kelas yang sudah berjalan hari ini. |
| **Ongoing Task (`HomeTaskCard`)** | Expandable card on tap, dual badge pill ([High]/[Medium] + [6d]/[4d]), circular clock coral, circular ring 98% untuk tugas tim, tombol coral Edit. | 1. **Tombol "See all" Hanya Toast**: Tombol "See all" di samping judul Ongoing Task saat ini hanya menampilkan toast, **belum mengarahkan pengguna ke Tab Task (Tab 1)**.<br>2. **Penyelesaian Tugas Cepat**: Belum ada checkbox atau tombol cepat untuk menandai tugas sebagai 'Selesai' langsung dari kartu Home tanpa harus membuka edit form.<br>3. **Pull-to-Refresh**: Belum ada `RefreshIndicator` untuk memperbarui data tugas dengan menarik layar ke bawah. | • Ubah aksi "See all" agar memanggil `_onTabSelected(1)` untuk meluncur ke tab Task.<br>• Tambahkan gesture swipe-to-complete atau icon centang lingkaran untuk menyelesaikan tugas personal. |

---

### C. Halaman Task / Manajemen Tugas (`lib/presentation/features/task/`)
Halaman: `TaskPage`, `TaskContentView`, `TaskExpandableCard`, `CreateTaskPage`, `EditTaskPage`.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Timeline Summary (`TaskTimelineSummary`)** | Kartu ringkasan jumlah prioritas (3 High, 1 Medium, 2 Low) dengan warna kontras dan tabular numbers. | 1. **Kartu Summary Tidak Dapat Diketuk**: Mengklik kartu High, Medium, atau Low tidak memfilter daftar tugas di bawahnya (hanya berupa statistik pasif). | • Jadikan kartu ringkasan interaktif: Mengetuk kartu "High" langsung menyaring daftar tugas hanya menampilkan tugas berprioritas tinggi. |
| **Filter Bar (`TaskFilterBar`)** | Chips ringkas (All, Today, Next 7 Days, Overdue) dengan tinggi ramping 28dp. | 1. **Pencarian Kata Kunci**: Tidak ada kolom pencarian (*search bar*) untuk mencari tugas berdasarkan judul atau nama mata kuliah.<br>2. **Pilihan Urutan (Sorting)**: Belum ada opsi sortir berdasarkan deadline terdekat, prioritas tertinggi, atau tanggal dibuat. | • Tambahkan icon/tombol search lipat (*collapsible search bar*) di atas filter bar.<br>• Tambahkan tombol filter sorting (Deadlines, Priority, A-Z). |
| **Kartu Detail (`TaskExpandableCard`)** | Expandable dengan animasi halus, detail anggota tim, mata kuliah, tanggal pembuatan, Centroid Defuzzification (`z* = 28.6`), tombol coral Edit. Routing otomatis ke Dashboard Team jika tugas kelompok. | 1. **Hapus Tugas Personal**: Pada detail kartu tertulis peringatan "*This task is asigned to you, and you can’t delete" bahkan untuk tugas personal, sehingga pengguna tidak dapat menghapus tugas yang sudah usang atau salah dibuat.<br>2. **Perhitungan Fuzzy Realtime**: Nilai centroid `z* = 28.6` masih berupa string teks statis, belum dihitung oleh kalkulator fuzzy inference nyata. | • Sediakan opsi "Delete Task" dengan konfirmasi dialog `PopUpKonfirmasiDelete` khusus untuk tugas berlabel Personal.<br>• Integrasikan rumus fuzzy Mamdani sederhana untuk menghitung bobot nilai tugas berdasarkan SKS dan sisa deadline. |
| **Form Tambah & Edit (`CreateTaskPage`, `EditTaskPage`)** | Formulir terpadu dual-mode, selektor kategori kuliah vs non-kuliah (form course dinamis muncul/sembunyi), opsi Automatic pada Course Grade Weight dengan animasi lipat, pemilih tanggal & waktu, proteksi anti-double submit. | 1. **Pilihan Mata Kuliah Dropdown**: Form isian `Course` masih berupa TextField biasa, belum berupa dropdown daftar mata kuliah yang sedang diambil semester ini.<br>2. **Lampiran Berkas / Tautan**: Belum ada kolom untuk melampirkan link Google Drive, GitHub, atau file PDF panduan tugas. | • Sediakan auto-complete atau dropdown daftar mata kuliah terdaftar.<br>• Tambahkan field tautan eksternal (*Assignment URL / Drive Link*) yang bisa diklik langsung dari detail kartu. |

---

### D. Halaman Jadwal Kuliah & Meeting (`lib/presentation/features/schedule/`)
Halaman: `SchedulePage`, `ScheduleContentView`, `ScheduleFormPage`, Pop-up Edit & Delete.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Daftar Jadwal (`SchedulePage`)** | Pengelompokan tanggal otomatis (Today, Yesterday, Tomorrow, Nama Hari), auto-scroll fokus ke jadwal ongoing hari ini, filter bar (All, Today, Upcoming, Completed), kartu seragam `ImpalScheduleCard`. | 1. **Tampilan Kalender Bulanan (Month View)**: Jadwal hanya disajikan dalam bentuk daftar list vertikal. Pengguna tidak bisa melihat kalender matriks bulanan untuk melihat hari apa saja yang padat jadwal kuliah.<br>2. **Deteksi Bentrok Jadwal (*Schedule Conflict*)**: Tidak ada peringatan bentrok waktu jika pengguna membuat jadwal baru pada jam dan hari yang sama dengan jadwal lain. | • Tambahkan slider strip 7 hari (*horizontal weekly calendar strip*) di bawah header agar pengguna bisa melompat ke hari tertentu dengan 1 ketukan.<br>• Tambahkan validasi bentrok waktu saat form disimpan dengan modal peringatan konfirmasi. |
| **Form Jadwal (`ScheduleFormPage`)** | Pemilih tipe jadwal (Lecture, Meeting, External), toggle meeting kelompok dengan autocomplete nama tim, pemilihan jam mulai & selesai via dialog jam analog custom, pengulangan mingguan (*repeat weekly*). | 1. **Lokasi Virtual (Link Zoom / GMeet)**: Belum ada input khusus untuk tautan meeting daring yang bisa dibuka langsung dari aplikasi.<br>2. **Notifikasi Alarm / Pengingat**: Belum ada pengingat lokal 15 atau 30 menit sebelum kelas dimulai. | • Tambahkan opsi "Online / Offline". Jika Online, munculkan field URL meeting dengan tombol "Join Call".<br>• Integrasikan notifikasi sistem perangkat (*Local Notification*). |

---

### E. Halaman Tim & Dashboard Kelompok (`lib/presentation/features/team/`)
Halaman: `TeamListPage`, `DashboardTeamPage`, `CreateTaskTeamPage`, Pop-up Team.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Daftar Tim (`TeamListPage`)** | Kartu tim dengan nama kelompok, kluster avatar anggota berwarna, preview jadwal meeting tim, tombol Gabung Tim (kode) dan Buat Tim baru dengan pop-up notifikasi terpadu. | 1. **Keluar Tim (*Leave Team*) / Hapus Tim**: Belum ada aksi bagi pengguna untuk keluar dari kelompok yang sudah selesai atau membubarkan kelompok.<br>2. **Pencarian Tim**: Belum ada filter pencarian nama tim jika pengguna memiliki banyak kelompok kuliah. | • Tambahkan menu aksi (titik tiga) pada setiap kartu tim untuk "Leave Team" atau "Team Settings".<br>• Tampilkan status progress kelompok (misal: "3 Tugas Tersisa"). |
| **Dashboard Kelompok (`DashboardTeamPage`)** | Header tim dengan tombol back, pill kode tim dengan fitur copy satu ketukan (`7X29`), bagian jadwal meeting tim, daftar tugas kelompok `TeamTaskCard`. | 1. **Manajemen Anggota Tim**: Mengklik avatar di header belum membuka daftar anggota tim lengkap beserta nomor telepon/email atau peran (Ketua / Anggota).<br>2. **Filter Tugas Menurut Anggota**: Belum ada tombol filter "Tugas Saya" vs "Semua Tugas Tim" sehingga anggota tim harus membaca satu-satu untuk mencari tugasnya. | • Buat modal "Team Members": menampilkan daftar anggota, peran (Leader/Member), dan tombol "Share Invite Link".<br>• Tambahkan chips filter assignee: `[All] [Assigned to Me] [Ahmad] [Kafi]` di atas daftar task team. |
| **Kartu Tugas Tim (`TeamTaskCard`)** | Badge prioritas sesuai standar tim, **penanda sisa waktu deadline (due badge)** di kanan atas, avatar anggota bertumpuk rapi, **tombol edit logo pensil abu-abu** di sudut kanan bawah. | 1. **Subtask / Checklist**: Tugas kelompok saat ini hanya memiliki judul dan penanggung jawab, belum ada daftar checklist sub-pekerjaan yang dapat dicentang saat selesai. | • Tambahkan indikator checklist mini (contoh: `2/4 subtask done`) di bawah nama penanggung jawab.<br>• Berikan feedback visual (opacity redup & centang hijau) jika tugas tim telah selesai dikerjakan. |
| **Form Tugas Tim (`CreateTaskTeamPage`)** | Form terpadu create & edit, dropdown multi-assignee dengan chip avatar yang bisa dipilih lebih dari 1 orang, pemilih tanggal & jam deadline, pop-up konfirmasi. | 1. **Hapus Tugas Tim**: Tidak ada tombol "Delete Task" di dalam form edit tugas tim, sehingga tugas tim yang dibatalkan tidak bisa dihapus. | • Tambahkan tombol teks merah "Delete Task" di bagian paling bawah form edit tugas tim yang memicu dialog konfirmasi hapus. |

---

### F. Shell Navigasi Bawah & Komponen Global (`common_widgets/`)
Halaman: `ImpalBottomNavBar`, `HomeHeader`, Dialog & Pop-up.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Navbar Bawah (`ImpalBottomNavBar`)** | Kurva cutout melengkung eksklusif, tombol bulat oranye melayang yang meluncur (*slide*) secara horizontal mulus antar 4 tab, persistent shell tanpa reload. | 1. **Halaman Saat Ini di History**: Tombol fisik Android Back saat berada di Tab 1, 2, atau 3 langsung menutup aplikasi alih-alih kembali ke Tab 0 (Home).<br>2. **Badge Hitungan Notifikasi**: Ikon pada navbar belum memiliki badge angka (misal ada angka merah kecil di ikon Task jika ada 3 tugas mendesak). | • Bungkus shell dengan `PopScope` / `WillPopScope` agar jika pengguna menekan back di Tab lain, aplikasi otomatis beralih ke Tab 0 terlebih dahulu sebelum keluar.<br>• Tambahkan dot indikator notifikasi kecil di atas ikon Task atau Schedule. |
| **Sistem Pop-Up (`PopUpPemberitahuan`)** | Dialog dark container (`#282D37`), animasi scale masuk, badge icon berwarna tematik, tombol "Dismiss" jelas, auto-dismiss responsif. | 1. **Opsi Undo pada Aksi Hapus**: Saat jadwal atau tugas dihapus, aksi bersifat permanen tanpa adanya jendela waktu pembatalan (*Undo snackbar*). | • Tambahkan "Undo Window" (SnackBar melayang 4 detik dengan tombol "Undo") sesaat setelah jadwal/tugas dihapus sesuai aturan `AGENTS.md`. |

---

## 🚀 3. Matriks Rekomendasi Peningkatan (Prioritas Aksi)

```
        Dampak UX Tinggi
               ▲
               │  [P1] Kategori Filter Aktif di Home
               │  [P1] PopScope Android Back ke Tab 0
               │  [P1] "See all" Ongoing Task -> Tab 1
               │  [P2] Filter "Tugas Saya" di Tim Dashboard
               │  [P2] Hapus Tugas Personal & Tim
               │  [P2] Modal Daftar Anggota Tim
               │
               │  [P3] Strip Kalender Mingguan di Schedule
               │  [P3] Indikator Selesai (Checkmark) di Kartu
               │  [P3] Kolom Pencarian Tugas & Tim
               │  [P4] Persistensi Database Lokal (Hive/Sqflite)
               │  [P4] Mode Terang / Gelap (Theme Toggle)
               │
───────────────┼────────────────────────────────────────►
               │                               Tingkat Kompleksitas
          Rendah                              Tinggi
```

### 🔴 Prioritas 1 — Kemenangan Cepat & Perbaikan UX Kritis (*Quick Wins*)
1. **Fungsikan Filter Kategori di Home**:
   - Filter `_tasks` di `HomePage` berdasarkan nilai `_selectedCategory` ('College' -> hanya tampilkan yang `isCollegeTask == true`, 'Personal' -> hanya yang `isCollegeTask == false`, 'All' -> tampilkan semua).
2. **Koneksikan Tombol "See all" Ongoing Task**:
   - Ganti aksi toast pada `home_page.dart` (line 429) menjadi `_onTabSelected(1);` agar pengguna langsung dibawa ke halaman Task lengkap.
3. **Penyempurnaan Navigasi Tombol Back Android (`PopScope`)**:
   - Bungkus `HomePage` dengan `PopScope` agar ketika pengguna berada di Tab 1 (Task), Tab 2 (Team), atau Tab 3 (Schedule) dan menekan tombol kembali Android, aplikasi kembali ke Tab 0 (Home), bukan langsung keluar dari aplikasi.
4. **Opsi Hapus pada Form Edit Tugas Tim**:
   - Sediakan tombol "Delete Task" berwarna merah di bagian bawah [`CreateTaskTeamPage`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/create_task_team.dart) saat dalam mode edit, dilengkapi dialog konfirmasi `PopUpKonfirmasiDelete`.

---

### 🟡 Prioritas 2 — Peningkatan Ergonomi & Kelengkapan Alur (*Core Features*)
1. **Filter "Tugas Saya" pada Dashboard Kelompok**:
   - Tambahkan toggle/chips filter di `DashboardTeamPage`: `[Semua Tugas Tim]` dan `[Tugas Saya]`, sehingga mahasiswa dapat langsung memilah apa tanggung jawab pribadinya di dalam kelompok.
2. **Modal Rincian Anggota Kelompok (*Team Members Modal*)**:
   - Ketika avatar tim di header `DashboardTeamPage` diketuk, munculkan bottom sheet yang merinci daftar seluruh anggota, nomor kontak, serta status perannya (Ketua / Anggota).
3. **Checkmark Penyelesaian Tugas Langsung (*Quick Complete*)**:
   - Sediakan lingkaran centang di sisi kiri atau aksi cepat pada kartu tugas untuk menandai tugas telah selesai tanpa harus masuk ke form edit. Tugas yang selesai ditandai teks tercoret rapi.
4. **Hapus Tugas Personal yang Sudah Tidak Relevan**:
   - Buka izin hapus untuk tugas personal pada kartu detail atau form edit tugas personal, hilangkan pesan larangan hapus jika tugas bukan merupakan tugas kelompok yang di-assign oleh ketua.

---

### 🟢 Prioritas 3 — Penyempurnaan Visual & Estetika Lanjutan (*Taste & Visual Polish*)
1. **Horizontal Weekly Calendar Strip pada Schedule Page**:
   - Letakkan slider 7 hari (Senin s/d Minggu) dengan tanggal aktif tepat di bawah header halaman Schedule, sehingga pengguna bisa melihat jadwal kuliah hari tertentu dengan cepat.
2. **Indikator Visual Bentrok Jadwal (*Conflict Warning*)**:
   - Berikan banner peringatan oranye pada `ScheduleFormPage` jika jam kuliah yang dipilih beririsan dengan jadwal lain yang sudah tersimpan di `ScheduleRepository`.
3. **Pencarian Cepat (*Search Bar*)**:
   - Sediakan kolom pencarian dengan debounce 300ms pada `TaskPage` dan `SchedulePage` untuk menyaring tugas berdasarkan kata kunci judul mata kuliah.
4. **Penyimpanan Lokal Persisten (*Local Storage Persistence*)**:
   - Migrasi penyimpanan in-memory saat ini ke penyimpanan lokal persisten (`shared_preferences` / `hive`) agar data tugas dan jadwal baru tidak hilang saat aplikasi ditutup dan dibuka kembali.

---

## 📋 4. Rekapitulasi Berkas yang Direkomendasikan untuk Ditingkatkan

1. [`frontend/lib/presentation/features/dashboard/home_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart):
   - Hubungkan `_selectedCategory` ke filter daftar `_tasks`.
   - Hubungkan tombol "See all" ke `_onTabSelected(1)`.
   - Pasang `PopScope` untuk navigasi kembali ke Tab 0.
2. [`frontend/lib/presentation/features/team/dashboard_team_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/dashboard_team_page.dart):
   - Tambahkan filter chip `[All Tasks]` dan `[Assigned to Me]`.
   - Tambahkan interaksi ketuk avatar untuk melihat daftar anggota kelompok.
3. [`frontend/lib/presentation/features/team/create_task_team.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/create_task_team.dart):
   - Tambahkan opsi hapus tugas tim pada mode edit.
4. [`frontend/lib/presentation/features/task/task_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/task_page.dart):
   - Fungsikan ketukan pada kartu `TaskTimelineSummary` (High, Medium, Low) agar menjadi filter instan.
   - Tambahkan aksi centang selesai (*toggle isDone*).
5. [`frontend/lib/presentation/features/schedule/schedule_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/schedule/schedule_page.dart):
   - Tambahkan strip kalender mingguan mini untuk navigasi hari cepat.

