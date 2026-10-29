# 📑 Dokumen Audit & Roadmap Peningkatan Aplikasi: IMPAL Smart Task Manager
> **Status Dokumen:** Master Roadmap & Living Audit Document  
> **Terakhir Diperbarui:** 29 Oktober 2026 (Sinkronisasi Penuh Pasca-Implementasi Profil & Settings)  
> **Arsitektur:** Flutter Feature-First, Single-Shell Navigation, ResponsiveContext, 60 FPS HP Kentang Compliance  
> **Kepatuhan Mutu:** `dart analyze` — 0 Error, 0 Warning, 0 Deprecations  

---

## 📝 Log Eksekusi & Riwayat Perubahan Terkini (Execution & Changelog)

Setiap perubahan arsitektur, penambahan fitur, perbaikan bug, atau penyesuaian UI/UX **wajib dicatat secara kronologis** di bagian ini sesuai standar aturan agen (`AGENTS.md`):

| ID Log | Tanggal | Modul / Komponen | Ringkasan Pekerjaan & Implementasi | Status |
| :--- | :--- | :--- | :--- | :--- |
| **LOG-011** | 29 Okt 2026 | **Auth & UX Notification** | **Penempatan Presisi Pop-Up Notifikasi Pengiriman Kode Pemulihan:**<br>• Menghilangkan pemunculan notifikasi prematur saat menekan "Continue to Reset Password" pada bottom sheet di `ProfilePage` (modal hanya mengarahkan ke halaman pemulihan).<br>• Memastikan pop-up notifikasi hijau `PopUpPemberitahuan.recoveryCodeSent` hanya muncul tepat setelah pengguna menentukan pilihan (Email / SMS) dan menekan tombol **"Send Recovery Code"** di `ForgotPasswordPage`.<br>• Menjaga pemanggilan pop-up saat aksi "Resend Code" pada `VerificationCodePage`.<br>• Lolos uji menyeluruh `terms_privacy_page_test.dart` (3/3 passed, 0 error). | ✅ **SELESAI (100%)** |
| **LOG-010** | 29 Okt 2026 | **Auth & Profile Terms** | **Penyatuan Komprehensif Halaman `TermsPrivacyPage` & Alur Change Password:**<br>• Menyatukan `TermsPrivacyPage` menjadi single source of truth dengan 2 mode adaptif:<br>  - Mode Register (`isFromRegister: true`): Tombol close `✕`, kotak centang persetujuan, tombol `[Decline]` dan `[Accept & Continue →]`.<br>  - Mode Profile (`isFromRegister: false`): Tombol kembali `←`, murni pratinjau dokumen tanpa kotak centang atau tombol aksi bawah.<br>• Container kartu terpadu memuat 6 pasal resmi, kotak *Academic Advisory Note* beraksen coral, dan lencana `v1.2 Active`.<br>• Menghubungkan tombol modal bottom sheet *Change Password* di Profile agar langsung mengarahkan pengguna ke alur `ForgotPasswordPage` dengan pre-filled email akun terdaftar (`initialEmail`).<br>• Lolos uji menyeluruh `terms_privacy_page_test.dart` (3/3 passed, 0 error, 0 overflow). | ✅ **SELESAI (100%)** |
| **LOG-009** | 29 Okt 2026 | **Profile & Settings** | **Penyempurnaan Profil Penuh Sesuai Tangkapan Layar Lengkap & Arahan Pengguna:**<br>• Menghilangkan NIM, Major & Campus, dan Group Role dari `ProfileHeroCard` dan `EditProfilePage`.<br>• Mengubah label formulir dari "OFFICIAL CAMPUS EMAIL" menjadi "EMAIL" dengan pill *Verified* tetap aktif.<br>• Menambahkan sub-item `Score Explainability (XAI)` dengan toggle switch di seksi `INTELLIGENT SYSTEM (AI FUZZY)`.<br>• Mengimplementasikan seksi baru `ACCOUNT & INTEGRATION` (`ProfileAccountIntegrationGroup`): Email tile, Change Password tile dengan modal kirim tautan reset, dan Terms & Privacy Policy tile yang terhubung ke `TermsPrivacyPage`.<br>• Menyesuaikan tombol `Log Out Account` berbingkai coral (`#FA6144`) dan berlatar flat dark coral sesuai tangkapan layar Figma.<br>• Menambahkan footer teks `Todolist Sistem Cerdas v2.0 • Kelompok 7 IMPAL Telkom University`.<br>• Seluruh widget test pada `profile_page_test.dart` lolos pengujian (0 Error, 0 Overflow). | ✅ **SELESAI (100%)** |
| **LOG-008** | 29 Okt 2026 | **Governance / Rules** | Penguncian aturan permanen pada `AGENTS.md` (root proyek & plugin): Agen **WAJIB** memperbarui `ROADMAP_AUDIT_DAN_PENINGKATAN.md` secara berkelanjutan setiap kali selesai melakukan tindakan/pekerjaan. | ✅ **LOCKED** |
| **LOG-007** | 29 Okt 2026 | **Profile & Settings** | **Refactoring Lengkap Figma Export ke Pure UI Modular:**<br>• Dibuat `UserProfileModel` & `UserProfileRepository` (singleton ChangeNotifier).<br>• Dibuat `ProfileHeroCard` (avatar concentric coral ring, student NIM, `ACTIVE STUDENT` pill, info akademik).<br>• Dibuat `ProfileStatsRow` (4 kartu ringkasan DONE, PENDING, MK/SKS, ON-TIME dengan tabular numbers).<br>• Dibuat `ProfileSettingsGroup` (switch Deadline Alerts, jam briefing via `showImpalTimePicker`, switch Sound & Vibration).<br>• Dibuat `ProfileFuzzyCard` (status sistem AI Fuzzy Mamdani Min-Max).<br>• Dibuat `ProfileTextField` & `EditProfilePage` (form lengkap, photo modal, SSO banner, pop-up notifikasi).<br>• Dihubungkan ke avatar inisial `HomeHeader`.<br>• Dibuat dan lolos pengujian widget `profile_page_test.dart`. | ✅ **SELESAI (100%)** |
| **LOG-006** | 29 Okt 2026 | **Team Module** | **Standarisasi Kartu Tugas Tim (`TeamTaskCard`):**<br>• Ditambahkan penanda sisa waktu deadline (due badge) di sudut kanan atas bersanding dengan badge prioritas.<br>• Tombol edit diposisikan di sudut kanan bawah berupa **logo pensil abu-abu murni** (`Icons.edit_rounded`, `AppColors.textMuted`) tanpa teks. | ✅ **SELESAI (100%)** |
| **LOG-005** | 29 Okt 2026 | **Task Routing** | **Alur Cerdas Routing Tombol Edit Kartu Tugas:**<br>• Tombol edit pada tugas personal (`HomeTaskCard`, `TaskExpandableCard`) mengarah ke form `EditTaskPage`.<br>• Tombol edit pada tugas kelompok/tim (`isTeamTask: true`) otomatis mengarah ke `DashboardTeamPage` dari kelompok terkait. | ✅ **SELESAI (100%)** |
| **LOG-004** | 29 Okt 2026 | **Design System** | **Penyelarasan Token Warna Prioritas Tugas:**<br>• High: Coral `AppColors.primary` (`#FFFF5E4D`), Teks Putih.<br>• Medium: Warm Amber (`#FBBF24`), Teks Dark Slate (`#1F2937`).<br>• Low: Mint Green (`#6EE7B7`), Teks Dark Green (`#064E3B`). | ✅ **SELESAI (100%)** |
| **LOG-003** | 29 Okt 2026 | **Task Cards** | **Pinned Top-Right Badge Anti-Clustering:**<br>• Seluruh kartu tugas (`HomeTaskCard`, `TaskExpandableCard`, `TeamTaskCard`) menggunakan `SizedBox(width: double.infinity)` pada `Stack` induk agar badge tetap di pojok kanan atas.<br>• Diberi margin kanan minimal 110dp pada judul tugas untuk mencegah teks menimpa badge. | ✅ **SELESAI (100%)** |
| **LOG-002** | 29 Okt 2026 | **Design System** | **Standarisasi Penanda Sisa Deadline (Due Badge):**<br>• Format kapsul pill penuh (`BorderRadius.circular(999)`).<br>• Normal: Sky Blue (`#5B93FF`), Mendesak/Overdue: Coral (`#FF7D65`).<br>• Ikon jam bulat coral disematkan tepat di samping teks deadline. | ✅ **SELESAI (100%)** |
| **LOG-001** | 29 Okt 2026 | **Navigation Shell** | **Penyatuan Header Antar-Tab (Unified Shell Header):**<br>• `HomePage`, `TaskPage`, `TeamListPage`, dan `SchedulePage` menggunakan komponen `HomeHeader` yang seragam.<br>• Dihapus tombol back pada tab utama shell.<br>• Subtitle adaptif berwarna oranye (`$count task pending`, `Task`, `Team List`, `Schedule`). | ✅ **SELESAI (100%)** |

---

## 📌 1. Ringkasan Eksekutif & Status Sistem Saat Ini

Aplikasi **IMPAL Smart Task Manager** telah memiliki fondasi antarmuka yang sangat solid dengan estetika modern dark theme (`#282D37`, `#323846`), tipografi Inter terstandarisasi, responsivitas dinamis (`ResponsiveContext`), animasi navigasi meluncur (*sliding scooped notch bottom nav*), serta kepatuhan penuh terhadap pedoman **`AGENTS.md`** (0 Error & 0 Warning pada static analysis).

Modul profil mahasiswa (`ProfilePage` & `EditProfilePage`) telah selesai diintegrasikan secara penuh dari desain Figma, melengkapi kebutuhan manajemen identitas pengguna, status akademik, preferensi pengingat, dan status AI fuzzy logic engine.

Dokumen ini memetakan secara komprehensif apa saja yang **sudah selesai**, apa yang **masih belum ada (incomplete/mock)**, serta **rencana aksi prioritas berikutnya**.

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

### B. Halaman Dashboard / Home (`lib/presentation/features/dashboard/`) & Profil
Halaman: `HomePage`, `HomeHeader`, `HomeCategoriesSection`, `HomeScheduleSection`, `HomeTaskCard`, `ProfilePage`, `EditProfilePage`.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Header (`HomeHeader`) & Profile (`ProfilePage`, `EditProfilePage`)** | ✅ **SELESAI 100% (FULL SPEC):** Salam dinamis `Hi $userName`, subtitle adaptif, avatar inisial dengan concentric coral ring & green verified badge, navigasi ke `ProfilePage`. Hero card bersih tanpa NIM/Major/Group Role, menampilkan nama & email. 4 stats row, toggle pengingat, AI fuzzy card dengan toggle `Score Explainability (XAI)`, seksi `ACCOUNT & INTEGRATION` (Email, Change Password, Terms & Privacy Policy), tombol `Log Out Account` coral pill, footer branding, form edit profil tersaring (`EditProfilePage`) tanpa NIM/Kampus/Role dan label EMAIL verified. | 1. **Upload Berkas Foto Nyata**: Menggunakan modal kamera/galeri simulasi dengan inisial avatar dinamis. | • Integrasikan package `image_picker` atau file storage nyata jika backend Dart Frog storage service telah siap.<br>• Tambahkan badge titik merah notifikasi jika ada tugas deadline mendesak di dekat avatar. |
| **Kategori (`HomeCategoriesSection`)** | Kartu kategori "College" & "Personal" dengan hitungan tugas dan ikon yang serasi. | 1. **Filter Kategori Belum Menyaring Daftar**: Mengetuk "College" atau "Personal" hanya mengubah warna outline kartu, belum memfilter daftar tugas `Ongoing Task` di bawahnya.<br>2. **Tombol Tambah Kategori (+)**: Hanya menampilkan toast, belum membuka modal pembuatan kategori kustom. | • Hubungkan variabel `_selectedCategory` ke filter list `_tasks` di `HomePage`.<br>• Sediakan popup tambah kategori baru (Nama + Ikon + Warna). |
| **Jadwal Hari Ini (`HomeScheduleSection`)** | Preview jadwal kuliah ongoing dengan status badge, jam, lokasi, dan tombol "See all" mulus mengarahkan ke Tab Schedule. | 1. **Status Dinamis Otomatis**: Status 'Ongoing' masih statis dari repository, belum otomatis beralih menjadi 'Completed' jika jam kelas telah terlewati. | • Tambahkan progress bar garis waktu berapa persen jam sesi kelas yang sudah berjalan hari ini. |
| **Ongoing Task (`HomeTaskCard`)** | ✅ Expandable card on tap, dual badge pill ([High]/[Medium] + [6d]/[4d]), circular clock coral, circular ring 98% tugas tim, tombol coral Edit, routing cerdas ke Dashboard Team untuk tugas kelompok. | 1. **Tombol "See all" Masih Toast**: Tombol "See all" di samping judul Ongoing Task belum mengarahkan pengguna ke Tab Task (Tab 1).<br>2. **Checkbox Quick Complete**: Belum ada centang instan untuk menandai tugas selesai langsung dari kartu. | • Ubah aksi tombol "See all" agar memanggil callback navigasi ke Tab 1 (`_onTabSelected(1)`).<br>• Tambahkan gesture swipe-to-complete atau icon centang lingkaran untuk menyelesaikan tugas personal. |

---

### C. Halaman Task / Manajemen Tugas (`lib/presentation/features/task/`)
Halaman: `TaskPage`, `TaskContentView`, `TaskExpandableCard`, `CreateTaskPage`, `EditTaskPage`.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Header & Timeline Summary (`TaskTimelineSummary`)** | Header seragam tanpa tombol back dengan subtitle oranye `Task`. Kartu ringkasan jumlah prioritas (3 High, 1 Medium, 2 Low) dengan warna kontras dan tabular numbers. | 1. **Kartu Summary Belum Interaktif**: Mengklik kartu High, Medium, atau Low belum memfilter daftar tugas di bawahnya (masih berupa statistik pasif). | • Fungsikan kartu ringkasan sebagai filter cepat: Mengetuk kartu "High" langsung menyaring daftar tugas menjadi hanya tugas prioritas tinggi. |
| **Filter Bar (`TaskFilterBar`)** | Chips ringkas (All, Today, Next 7 Days, Overdue) dengan tinggi ramping 28dp. | 1. **Pencarian Kata Kunci**: Tidak ada search bar untuk mencari tugas berdasarkan nama atau mata kuliah.<br>2. **Sorting Dropdown**: Belum ada opsi sortir berdasarkan deadline terdekat vs prioritas tertinggi. | • Tambahkan search bar lipat (*collapsible search bar*) di atas filter bar.<br>• Tambahkan tombol filter sorting (Deadlines, Priority, A-Z). |
| **Kartu Detail (`TaskExpandableCard`)** | ✅ Pinned top-right badge anti-clustering, detail anggota tim, mata kuliah, tanggal pembuatan, Centroid Defuzzification (`z* = 28.6`), tombol coral Edit dengan routing cerdas. | 1. **Hapus Tugas Personal**: Pada detail kartu masih tertulis larangan delete bahkan untuk tugas personal.<br>2. **Kalkulasi Fuzzy Realtime**: Nilai centroid masih berupa data statis model, belum dihitung oleh fungsi fuzzy evaluator dinamis. | • Sediakan opsi "Delete Task" dengan konfirmasi dialog `PopUpKonfirmasiDelete` khusus untuk tugas berlabel Personal.<br>• Integrasikan kalkulator fuzzy Mamdani untuk menghitung bobot nilai tugas dari SKS dan sisa deadline. |
| **Form Tambah & Edit (`CreateTaskPage`, `EditTaskPage`)** | Formulir terpadu dual-mode, selektor kategori kuliah vs non-kuliah (form course dinamis), opsi Automatic pada Task Grade Weight dengan animasi lipat, pemilih tanggal & waktu, proteksi anti-double submit. | 1. **Pilihan Mata Kuliah Dropdown**: Form isian `Course` masih berupa TextField bebas, belum berupa dropdown daftar mata kuliah terdaftar semester ini. | • Sediakan auto-complete atau dropdown daftar mata kuliah terdaftar.<br>• Tambahkan field tautan eksternal (*Assignment URL / Drive Link*) yang bisa diklik langsung dari detail kartu. |

---

### D. Halaman Jadwal Kuliah & Meeting (`lib/presentation/features/schedule/`)
Halaman: `SchedulePage`, `ScheduleContentView`, `ScheduleFormPage`, Pop-up Edit & Delete.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Daftar Jadwal (`SchedulePage`)** | Header seragam tanpa tombol back dengan subtitle oranye `Schedule`. Pengelompokan tanggal otomatis (Today, Yesterday, Tomorrow, Hari), auto-scroll fokus ke jadwal ongoing, filter bar (All, Today, Upcoming, Completed), kartu `ImpalScheduleCard`. | 1. **Tampilan Kalender Bulanan**: Jadwal hanya disajikan dalam list vertikal, belum ada kalender matriks bulanan.<br>2. **Deteksi Bentrok Jadwal (*Schedule Conflict*)**: Tidak ada peringatan bentrok waktu jika pengguna membuat jadwal baru pada jam dan hari yang sama dengan jadwal lain. | • Tambahkan slider strip 7 hari (*horizontal weekly calendar strip*) di bawah header agar pengguna bisa melompat ke hari tertentu dengan 1 ketukan.<br>• Tambahkan validasi bentrok waktu saat form disimpan dengan modal peringatan konfirmasi. |
| **Form Jadwal (`ScheduleFormPage`)** | Pemilih tipe jadwal (Lecture, Meeting, External), toggle meeting kelompok dengan autocomplete nama tim, pemilihan jam via dialog custom, pengulangan mingguan. | 1. **Lokasi Virtual (Link Zoom / GMeet)**: Belum ada input khusus untuk tautan meeting daring.<br>2. **Notifikasi Alarm / Pengingat**: Belum ada alarm lokal sebelum kelas dimulai. | • Tambahkan opsi "Online / Offline". Jika Online, munculkan field URL meeting dengan tombol "Join Call".<br>• Integrasikan notifikasi sistem perangkat (*Local Notification*). |

---

### E. Halaman Tim & Dashboard Kelompok (`lib/presentation/features/team/`)
Halaman: `TeamListPage`, `DashboardTeamPage`, `CreateTaskTeamPage`, `TeamTaskCard`, Pop-up Team.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Daftar Tim (`TeamListPage`)** | Header seragam tanpa tombol back dengan subtitle oranye `Team List`. Kartu tim dengan nama kelompok, kluster avatar berwarna, preview jadwal meeting tim, tombol Gabung Tim (kode) dan Buat Tim baru dengan pop-up notifikasi terpadu. | 1. **Keluar Tim (*Leave Team*) / Hapus Tim**: Belum ada aksi bagi pengguna untuk keluar dari kelompok yang sudah selesai atau membubarkan kelompok.<br>2. **Pencarian Tim**: Belum ada filter pencarian nama tim. | • Tambahkan menu aksi (titik tiga) pada setiap kartu tim untuk "Leave Team" atau "Team Settings".<br>• Tampilkan status progress kelompok (misal: "3 Tugas Tersisa"). |
| **Dashboard Kelompok (`DashboardTeamPage`)** | Header tim dengan tombol back, pill kode tim dengan fitur copy satu ketukan (`7X29`), bagian jadwal meeting tim, daftar tugas kelompok `TeamTaskCard`. | 1. **Manajemen Anggota Tim**: Mengklik avatar di header belum membuka modal daftar anggota tim lengkap beserta nomor telepon/email dan perannya.<br>2. **Filter Tugas Menurut Anggota**: Belum ada tombol filter "Tugas Saya" vs "Semua Tugas Tim". | • Buat modal "Team Members": menampilkan daftar anggota, peran (Leader/Member), dan tombol "Share Invite Link".<br>• Tambahkan chips filter assignee: `[All] [Assigned to Me]` di atas daftar task team. |
| **Kartu Tugas Tim (`TeamTaskCard`)** | ✅ **SELESAI 100%:** Badge prioritas sesuai standar tim, penanda sisa waktu deadline (due badge) di kanan atas, avatar anggota bertumpuk rapi, tombol edit logo pensil abu-abu di sudut kanan bawah. | 1. **Subtask / Checklist**: Belum ada daftar checklist sub-pekerjaan yang dapat dicentang saat selesai. | • Tambahkan indikator checklist mini (contoh: `2/4 subtask done`) di bawah nama penanggung jawab.<br>• Berikan feedback visual jika tugas tim telah selesai dikerjakan. |
| **Form Tugas Tim (`CreateTaskTeamPage`)** | Form terpadu create & edit, dropdown multi-assignee dengan chip avatar yang bisa dipilih lebih dari 1 orang, pemilih tanggal & jam deadline, pop-up konfirmasi. | 1. **Hapus Tugas Tim**: Belum ada tombol "Delete Task" di dalam form edit tugas tim. | • Tambahkan tombol teks merah "Delete Task" di bagian paling bawah form edit tugas tim yang memicu dialog konfirmasi hapus. |

---

### F. Shell Navigasi Bawah & Komponen Global (`common_widgets/`)
Halaman: `ImpalBottomNavBar`, `HomeHeader`, Dialog & Pop-up.

| Komponen | Fitur yang Sudah Ada & Bagus | Apa yang Masih Belum Ada (Incomplete) | Peluang Peningkatan Desain & UX |
| :--- | :--- | :--- | :--- |
| **Navbar Bawah (`ImpalBottomNavBar`)** | Kurva cutout melengkung eksklusif, tombol bulat oranye melayang yang meluncur (*slide*) secara horizontal mulus antar 4 tab, persistent shell tanpa reload. | 1. **Android Physical Back Handler**: Tombol fisik Android Back saat berada di Tab 1, 2, atau 3 langsung menutup aplikasi alih-alih kembali ke Tab 0 (Home).<br>2. **Badge Hitungan Notifikasi**: Ikon pada navbar belum memiliki badge angka penanda notifikasi. | • Bungkus shell dengan `PopScope` agar jika pengguna menekan back di Tab lain, aplikasi otomatis beralih ke Tab 0 terlebih dahulu sebelum keluar.<br>• Tambahkan dot indikator notifikasi kecil di atas ikon Task atau Schedule. |
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

## 📋 4. Rekapitulasi Berkas & Status Pengerjaan

| Berkas Target | Rencana Tindakan | Status |
| :--- | :--- | :--- |
| [`frontend/lib/presentation/features/profile/profile_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/profile/profile_page.dart) | Modul profil & settings lengkap dengan 5 sub-widget modular & domain model | ✅ **SELESAI (100%)** |
| [`frontend/lib/presentation/features/profile/edit_profile_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/profile/edit_profile_page.dart) | Form edit profil mahasiswa, modal ubah foto, validasi, dan pop-up sukses | ✅ **SELESAI (100%)** |
| [`frontend/lib/presentation/features/auth/terms_privacy_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/auth/terms_privacy_page.dart) | Halaman terpadu Terms & Privacy (mode Register dengan checkbox & buttons, mode Profile murni baca) | ✅ **SELESAI (100%)** |
| [`frontend/lib/presentation/features/team/widgets/team_task_card.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/team_task_card.dart) | Due badge sisa deadline di kanan atas dan tombol edit pensil abu-abu di kanan bawah | ✅ **SELESAI (100%)** |
| [`frontend/lib/presentation/features/dashboard/widgets/home_header.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/widgets/home_header.dart) | Subtitle adaptif oranye per tab shell dan navigasi ketukan avatar ke ProfilePage | ✅ **SELESAI (100%)** |
| [`frontend/lib/presentation/features/dashboard/home_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart) | Hubungkan `_selectedCategory` ke filter `_tasks`, tombol "See all" ke Tab 1, dan pasang `PopScope` | ⏳ **SIAP DIKERJAKAN (P1)** |
| [`frontend/lib/presentation/features/team/dashboard_team_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/dashboard_team_page.dart) | Filter chip `[All Tasks]` / `[Assigned to Me]` dan modal daftar anggota kelompok | ⏳ **SIAP DIKERJAKAN (P2)** |
| [`frontend/lib/presentation/features/team/create_task_team.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/create_task_team.dart) | Tambahkan tombol "Delete Task" dengan konfirmasi pada mode edit tugas tim | ⏳ **SIAP DIKERJAKAN (P1)** |
| [`frontend/lib/presentation/features/task/task_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/task_page.dart) | Fungsikan kartu `TaskTimelineSummary` sebagai filter cepat & aksi toggle selesai | ⏳ **SIAP DIKERJAKAN (P2)** |
| [`frontend/lib/presentation/features/schedule/schedule_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/schedule/schedule_page.dart) | Strip kalender mingguan horizontal mini untuk navigasi cepat | ⏳ **SIAP DIKERJAKAN (P3)** |
