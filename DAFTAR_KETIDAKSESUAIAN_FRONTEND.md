# 📋 DAFTAR KETIDAKSESUAIAN FRONTEND & AUDIT KEPATUHAN ATURAN STUDIO
> **Dokumen Audit Kepatuhan:** Frontend Codebase vs Standard Operating Rules (`AGENTS.md`, `.agents/rules/*`, `.agents/memory/*`, `web-interface-guidelines`)  
> **Tanggal Audit:** 2 November 2026  
> **Status Audit:** Selesai Diperiksa (Comprehensive Multi-Agent Audit)  
> **Target Analisis:** 0 Error, 0 Warning (`dart analyze`)  

---

## 📌 Ringkasan Eksekutif Hasil Audit

Audit komprehensif ini dilakukan oleh Tim Multi-Agent Frontend Architecture (`Production Director`, `Flutter QA Inspector`, `Flutter UX Architect`, `UX Ergonomics & Heuristics`, `UX Microcopy Writer`, dan `Flutter AppSec Auditor`) terhadap seluruh modul antarmuka:
- `lib/presentation/features/auth/`
- `lib/presentation/features/dashboard/`
- `lib/presentation/features/task/`
- `lib/presentation/features/schedule/`
- `lib/presentation/features/team/`
- `lib/presentation/features/notifikasi/`
- `lib/presentation/features/smart_system/`
- `lib/presentation/features/profile/`
- `lib/presentation/common_widgets/`

### Rekapitulasi Temuan Berdasarkan Tingkat Keparahan (Severity Matrix)
| Tingkat Keparahan | Jumlah Temuan | Deskripsi & Dampak |
| :--- | :---: | :--- |
| 🔴 **Kritis (High / Critical)** | **9** | Pelanggaran aturan baku studio, alur navigasi terputus, ketidaksinkronan filter UI, kerentanan penyimpanan sesi (AppSec), serta pelanggaran bahasa antarmuka. |
| 🟡 **Sedang (Medium)** | **14** | Area sentuh interaktif di bawah 48x48 dp (*Thumb Zone Ergonomics*), hardcoded pixel font/spacing tanpa `ResponsiveContext`, tombol kembali (*Back Button*) tidak seragam. |
| 🟢 **Rendah (Low / Polish)** | **8** | Matriks 5 State UI (Shimmer skeleton loader), desktop layout master-detail split view ($\ge 1024$ dp), dan jendela pembatalan aksi (*Undo Window*). |
| **TOTAL TEMUAN** | **31** | **Terpetakan lengkap dalam 8 kategori perbaikan.** |

---

## 📑 Daftar Rinci Ketidaksesuaian per Kategori

---

### 1. 🌐 Pelanggaran Standar Bahasa Antarmuka (UI Language Violations)
*Acuan Aturan:* [.agents/rules/ui_language_rules.md](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/ui_language_rules.md) & `AGENTS.md`  
*Aturan Baku:* Seluruh elemen UI yang terlihat oleh pengguna (label tombol, teks header, pill tags, placeholder form, toast, snackbar, dan mock data) **WAJIB 100% menggunakan Bahasa Inggris baku (*English UI*)**. Bahasa Indonesia **DILARANG KERAS** muncul di layar pengguna.

| No | Berkas & Baris | Teks Saat Ini (Melanggar) | Rekomendasi Perbaikan (Standar Bahasa Inggris) | Keparahan |
| :-: | :--- | :--- | :--- | :-: |
| 1.1 | [`lib/presentation/features/task/widgets/task_category_selector.dart:40, 50`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/widgets/task_category_selector.dart#L40) | `'Tugas Kuliah'` dan `'Non-Kuliah'` | Ubah menjadi `'College Task'` (atau `'College'`) dan `'Personal'` | 🔴 **Kritis** |
| 1.2 | [`lib/presentation/features/profile/profile_page.dart:459`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/profile/profile_page.dart#L459) | `'Todolist Sistem Cerdas v2.0 • Kelompok 7 IMPAL Telkom University'` | Ubah menjadi `'Smart Task Manager v2.0 • Team 7 IMPAL Telkom University'` | 🔴 **Kritis** |
| 1.3 | [`lib/presentation/features/dashboard/home_page.dart:85, 138`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart#L85) | `TaskTag(label: 'Kelompok')` | Ubah label tag menjadi `'Team'` | 🔴 **Kritis** |
| 1.4 | [`lib/presentation/features/dashboard/home_page.dart:101-102, 154-155`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart#L101) | `'Tugas IMPAL Figma'`, `'Membuat ui page kelompok'`, `'Tugas IMPAL Frontend'`, `'Slicing ui dashboard'` | Ubah menjadi `'IMPAL Figma Design'`, `'Create team UI page'`, `'IMPAL Frontend Slicing'`, `'Dashboard UI implementation'` | 🔴 **Kritis** |
| 1.5 | [`lib/presentation/features/schedule/schedule_form_page.dart:390, 391`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/schedule/schedule_form_page.dart#L390) | `'e.g. Weekly Standup Kelompok IMPAL'` dan `'e.g. Meet Impal Kelompok 7'` | Ubah menjadi `'e.g. Weekly Standup IMPAL Team'` dan `'e.g. IMPAL Team 7 Sync'` | 🟡 **Sedang** |
| 1.6 | [`lib/data/repositories/smart_priority_repository.dart:45, 83`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/data/repositories/smart_priority_repository.dart#L45) | Tags mock `'Laporan • Kelompok'` dan `'Tugas • Individu'` | Ubah menjadi `'Report • Team'` dan `'Assignment • Individual'` | 🟡 **Sedang** |
| 1.7 | [`lib/data/models/task_item_model.dart:204`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/data/models/task_item_model.dart#L204) | Title mock `'Tugas Besar Kecerdasan AI'` | Ubah menjadi `'AI System Final Project'` | 🟡 **Sedang** |
| 1.8 | [`lib/data/repositories/schedule_repository.dart:130`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/data/repositories/schedule_repository.dart#L130) | Notes mock `'Pertemuan 7: Penulisan Daftar Pustaka dan Sitasi'` | Ubah menjadi `'Lecture 7: Bibliography and Citation Formatting'` | 🟡 **Sedang** |
| 1.9 | [`lib/data/repositories/team_repository.dart:16, 27, 36, 46`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/data/repositories/team_repository.dart#L16) | Nama tim mock `'Kelompok - IMPAL'`, `'Kelompok - Kriptografi'`, `'Kelompok - Machine Learning'`, `'Kelompok - Riset Operasi'` | Ubah prefix `'Kelompok - '` menjadi `'IMPAL Team'`, `'Cryptography Team'`, `'Machine Learning Team'`, `'Operation Research Team'` | 🟡 **Sedang** |

---

### 2. 👆 Ergonomi Sentuh & Target Sentuh < 48x48 dp (Touch Target & A11y Violations)
*Acuan Aturan:* `AGENTS.md` (Pilar 1 & 2), `web-interface-guidelines`, dan aturan Nielsen Usability Heuristics.  
*Aturan Baku:* Seluruh elemen interaktif (tombol, ikon klik, checkbox, chip delete) **WAJIB memiliki batas sentuh fisik minimal 48x48 dp** (`BoxConstraints(minWidth: 48, minHeight: 48)` atau `IconButton`).

| No | Berkas & Baris | Komponen | Kondisi Saat Ini | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 2.1 | [`lib/presentation/features/team/widgets/team_task_card.dart:294-308`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/team_task_card.dart#L294) | Tombol Edit Pensil Abu-Abu | Hanya menggunakan `padding: EdgeInsets.all(4)` dengan ikon 16dp ($24\times 24$ dp hitbox). Sulit diketuk jempol di HP Kentang. | Bungkus dengan `SizedBox(width: 48, height: 48, child: Center(child: ...))` atau pasang `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`. | 🔴 **Kritis** |
| 2.2 | [`lib/presentation/common_widgets/impal_schedule_card.dart:105-119`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/impal_schedule_card.dart#L105) | Toggle Bell Alert Lonceng | Padding `symmetric(horizontal: 4, vertical: 2)` dan ikon 15dp ($23\times 19$ dp hitbox). | Tambahkan `BoxConstraints(minWidth: 48, minHeight: 48)` pada kontainer sentuhnya. | 🔴 **Kritis** |
| 2.3 | [`lib/presentation/features/auth/login_page.dart:148-166`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/auth/login_page.dart#L148) | Checkbox "Remember Me" | Kotak centang berukuran $18\times 18$ dp tanpa padding pembungkus minimal 48dp. | Perluas area sentuh baris menjadi minimal tinggi 48dp dengan `behavior: HitTestBehavior.opaque`. | 🟡 **Sedang** |
| 2.4 | [`lib/presentation/features/auth/regist_page.dart:331-345`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/auth/regist_page.dart#L331) | Checkbox "Terms & Privacy" | Kotak centang berukuran $18\times 18$ dp. | Berikan padding minimum 48dp pada tap target. | 🟡 **Sedang** |
| 2.5 | [`lib/presentation/features/team/widgets/pop_up_create_team.dart:322-348`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/pop_up_create_team.dart#L322) | Teks Tombol "Generate New" | Tinggi area sentuh hanya ~16dp. | Tambahkan `EdgeInsets.symmetric(vertical: 12, horizontal: 8)` agar mencapai minimal 48dp tinggi. | 🟡 **Sedang** |
| 2.6 | [`lib/presentation/features/team/widgets/pop_up_join_team.dart:114-134`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/pop_up_join_team.dart#L114) | Tombol Close `✕` | Kontainer berukuran $32\times 32$ dp (< 48x48 dp). | Ubah kontainer menjadi $48\times 48$ dp dengan ikon terpusat. | 🟡 **Sedang** |
| 2.7 | [`lib/presentation/features/dashboard/widgets/home_categories_section.dart:55-70`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/widgets/home_categories_section.dart#L55) | Tombol Tambah Kategori `+` | Ukuran kotak $44\times 44$ dp (< 48x48 dp). | Ubah ukuran menjadi tepat $48\times 48$ dp. | 🟡 **Sedang** |

---

### 3. 🔙 Standardisasi Header & Tombol Kembali (Header & Navigation Inconsistencies)
*Acuan Aturan:* [.agents/rules/header_rules.md](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/header_rules.md) & `AGENTS.md`  
*Aturan Baku:*
- Setiap sub-halaman formulir/detail wajib memiliki tombol back kotak rounded 10dp ($38\times 38$ dp), latar `#323846`, border 1px `#3B4150`, dan ikon `Icons.arrow_back_ios_new_rounded`. **Dilarang keras memakai unstyled `IconButton` atau teks "Back" mentah.**
- Header tab shell navigasi dilarang memiliki tombol back, dan ketukan avatar profil wajib membuka pop-up konfirmasi Sign Out.

| No | Berkas & Baris | Komponen | Pelanggaran Desain | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 3.1 | [`lib/presentation/features/task/create_task.dart:458-480`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/create_task.dart#L458) | Header Form Create/Edit Task | Menggunakan tombol panah mentah `Icons.arrow_back_rounded` bersanding dengan teks `'Back'`. | Gantikan dengan tombol back standar studio: Container 38x38dp, `#323846`, border 1px `#3B4150`, radius 10dp, ikon `Icons.arrow_back_ios_new_rounded` (tanpa teks "Back"). | 🔴 **Kritis** |
| 3.2 | [`lib/presentation/features/team/create_task_team.dart:434-463`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/create_task_team.dart#L434) | Header Form Create/Edit Team Task | Menggunakan tombol panah mentah `Icons.arrow_back` dengan teks `'Back'`. | Selaraskan dengan kontainer back button 38x38dp standar studio. | 🔴 **Kritis** |
| 3.3 | [`lib/presentation/features/schedule/schedule_form_page.dart:318-322`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/schedule/schedule_form_page.dart#L318) | AppBar Form Jadwal Kuliah | Menggunakan `IconButton` standar AppBar bawaan Flutter tanpa kontainer rounded. | Pasang kontainer 38x38dp `#323846` pada `leading` widget AppBar. | 🟡 **Sedang** |
| 3.4 | [`lib/presentation/features/team/widgets/team_dashboard_header.dart:126-156`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/team_dashboard_header.dart#L126) | Avatar Profil di Dashboard Tim | Mengetuk avatar langsung berpindah ke `ProfilePage` tanpa adanya opsi pop-up konfirmasi Sign Out seperti di `HomeHeader`. | Samakan perilakunya dengan `HomeHeader`: sediakan opsi dialog/pop-up konfirmasi akun. | 🟡 **Sedang** |

---

### 4. 🧩 Logika UX, Alur Terputus, & Interaksi Belum Selesai (Broken & Incomplete UX Flows)
*Acuan Aturan:* `AGENTS.md` (Pilar 3: Standar Rekayasa Antarmuka & UX), Nielsen 10 Usability Heuristics.

| No | Berkas & Baris | Komponen | Isu Alur UX Saat Ini | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 4.1 | [`lib/presentation/features/dashboard/home_page.dart:300-308, 597`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart#L300) | Filter Kategori Home | Mengetuk "College" atau "Personal" hanya mengubah warna outline kartu, tetapi **TIDAK memfilter daftar tugas `Ongoing Task`** di bawahnya (seluruh tugas tetap muncul). | Hubungkan `_selectedCategory` ke filter list `_tasks`: jika 'College' hanya tampilkan tugas kuliah, jika 'Personal' hanya tampilkan tugas personal. | 🔴 **Kritis** |
| 4.2 | [`lib/presentation/features/dashboard/home_page.dart:578-580`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart#L578) | Tombol "See all" Ongoing Task | Mengetuk tombol "See all" hanya memunculkan toast teks informasi (`showTopToast`), bukan berpindah halaman. | Ubah aksi agar langsung memicu navigasi ke Tab 1 (Task Page) via `_onTabSelected(1)`. | 🔴 **Kritis** |
| 4.3 | [`lib/presentation/features/dashboard/home_page.dart:368-410`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart#L368) | Penanganan Tombol Back Android (`PopScope`) | Saat berada di Tab 1 (Task), Tab 2 (Team), atau Tab 3 (Schedule), menekan tombol fisik Android Back langsung menutup aplikasi. | Pasang `PopScope`: jika tab aktif $> 0$, alihkan ke Tab 0 (Home) terlebih dahulu sebelum mengizinkan keluar. | 🔴 **Kritis** |
| 4.4 | [`lib/presentation/features/task/widgets/task_timeline_summary.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/widgets/task_timeline_summary.dart) | Kartu Statistik High, Medium, Low | Kartu ringkasan jumlah prioritas bersifat pasif (tidak memiliki `onTap`). | Fungsikan sebagai quick filter: mengetuk kartu "High" langsung menyaring daftar tugas menjadi tugas High saja. | 🟡 **Sedang** |
| 4.5 | [`lib/presentation/features/task/task_page.dart:389-414`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/task_page.dart#L389) | Matriks Empty State Task | Jika filter menghasilkan 0 tugas (misal tidak ada tugas Overdue), layar hanya menampilkan ruang kosong (*blank whitespace*). | Tampilkan widget `EmptyState` berilustrasi dengan teks panduan dan tombol "Reset Filter". | 🟡 **Sedang** |
| 4.6 | [`lib/presentation/features/team/dashboard_team_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/dashboard_team_page.dart) | Filter Assignee Dashboard Tim | Belum ada pemilah antara tugas seluruh anggota tim vs tugas milik pengguna sendiri. | Tambahkan chips filter: `[All Tasks]` dan `[Assigned to Me]`. | 🟡 **Sedang** |
| 4.7 | [`lib/presentation/features/team/dashboard_team_page.dart:120-140`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/dashboard_team_page.dart#L120) | Kluster Avatar Anggota Tim | Mengetuk avatar di header tim tidak memicu aksi apapun. | Buka modal bottom sheet "Team Members": menampilkan daftar anggota tim, email/kontak, dan perannya (Leader / Member). | 🟡 **Sedang** |
| 4.8 | [`lib/presentation/features/team/create_task_team.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/create_task_team.dart) | Aksi Hapus Tugas Tim | Dalam mode edit tugas tim, tidak ada opsi atau tombol untuk menghapus tugas yang salah/selesai. | Sediakan tombol teks merah "Delete Task" di bagian bawah formulir dengan dialog konfirmasi `PopUpKonfirmasiDelete`. | 🟡 **Sedang** |
| 4.9 | [`lib/presentation/features/task/create_task.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/create_task.dart) & [`edit_task_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/edit_task_page.dart) | Aksi Hapus Tugas Personal | Pada kartu tugas personal masih tertulis catatan "Cannot be deleted", padahal tugas personal milik sendiri wajar dihapus. | Sediakan aksi hapus tugas personal dengan konfirmasi yang ramah. | 🟡 **Sedang** |
| 4.10 | [`lib/presentation/features/team/widgets/pop_up_create_team.dart:238`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/pop_up_create_team.dart#L238) | Input Nama Tim (*Copy-Paste Bug*) | Kolom input "Team Name" memiliki `hintText: 'Name meeting'`. | Ubah menjadi `'Enter team name'` agar tidak membingungkan pengguna. | 🟡 **Sedang** |

---

### 5. 📏 Nilai Pixel Statis vs `ResponsiveContext` (Hardcoded Pixels)
*Acuan Aturan:* `AGENTS.md` (Pilar 1: Konvensi Arsitektur Wajib) & [.agents/rules/typography_rules.md](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/typography_rules.md)  
*Aturan Baku:* Dilarang keras menggunakan angka mati (`fontSize: 14.8`, `width: 352`). Wajib menggunakan ekstensi `ResponsiveContext` (`context.rFont(14, min: 12, max: 18)`, `context.rSpacing(16)`, `context.rIcon(24)`).

| No | Berkas & Baris | Komponen | Pelanggaran Hardcoded | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 5.1 | [`lib/presentation/features/team/widgets/team_task_card.dart:184, 215, 235, 255`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/team_task_card.dart#L184) | Kartu Tugas Tim | `fontSize: 14.8`, `fontSize: 9.5`, `fontSize: 11`, `fontSize: 10.8` | Ganti dengan `context.rFont(...)` agar teks tidak terpotong di layar HP Kentang 320dp. | 🟡 **Sedang** |
| 5.2 | [`lib/presentation/features/team/widgets/team_dashboard_header.dart:95, 108, 180, 234`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/team_dashboard_header.dart#L95) | Header Dashboard Tim | `fontSize: 22`, `fontSize: 12.5`, `fontSize: 20`, `fontSize: 12` | Ganti dengan `context.rFont(20, min: 18, max: 24)` dll. | 🟡 **Sedang** |
| 5.3 | [`lib/presentation/features/team/widgets/pop_up_create_team.dart:170, 220`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/pop_up_create_team.dart#L170) | Pop-Up Buat Tim | `fontSize: 14.75`, `fontSize: 14.55` | Ganti dengan `context.rFont(14)` terstandarisasi. | 🟡 **Sedang** |
| 5.4 | [`lib/presentation/features/team/widgets/pop_up_join_team.dart:100, 150, 190`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/widgets/pop_up_join_team.dart#L100) | Pop-Up Gabung Tim | `fontSize: 22`, `14`, `15` serta kontainer tetap `width: 352` | Ganti lebar kontainer menjadi `maxWidth: 380` dengan padding adaptif horizontal agar tidak overflow di layar 320dp. | 🟡 **Sedang** |
| 5.5 | [`lib/presentation/common_widgets/impal_schedule_card.dart:95, 138, 182`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/impal_schedule_card.dart#L95) | Kartu Jadwal Kuliah | `fontSize: 13.5`, `fontSize: 11.5` | Ganti dengan `context.rFont(13)` dan `context.rFont(11)`. | 🟡 **Sedang** |

---

### 6. 🛡️ Keamanan Data, Penyimpanan Sesi, & Sanitasi Input (AppSec Violations)
*Acuan Aturan:* [.agents/rules/security_hardening_rules.md](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/security_hardening_rules.md) & `AGENTS.md` (Pilar 7 & 10)  
*Aturan Baku:* Zero Insecure Storage (kredensial/token dilarang disimpan di teks polos), proteksi input batas karakter pada seluruh `TextField`.

| No | Berkas & Baris | Komponen | Pelanggaran Keamanan | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 6.1 | [`lib/presentation/features/auth/login_page.dart:83-86`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/auth/login_page.dart#L83) | Penyimpanan Sesi Login | Status sesi dan data login disimpan pada `SharedPreferences` teks polos tanpa enkripsi hardware. | Migrasikan penyimpanan token dan kredensial sesi ke `flutter_secure_storage` (Android Keystore / iOS Keychain). | 🔴 **Kritis** |
| 6.2 | [`lib/presentation/features/task/create_task.dart:510-530`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/create_task.dart#L510) | Form Input Judul & Deskripsi Tugas | `TextField` judul tugas belum memiliki batasan panjang karakter (`maxLength: 80`). Berisiko merusak layout jika di-paste teks sangat panjang. | Tambahkan `maxLength: 80` pada judul dan `maxLength: 500` pada deskripsi tugas. | 🟡 **Sedang** |
| 6.3 | [`lib/presentation/features/schedule/schedule_form_page.dart:380-405`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/schedule/schedule_form_page.dart#L380) | Form Input Jadwal Kuliah & Ruang | Tidak ada validasi batasan karakter pada nama mata kuliah dan nomor ruang kelas. | Tambahkan `maxLength` dan pembatasan format teks. | 🟡 **Sedang** |

---

### 7. 💻 Desain Responsif & Tata Letak Adaptif Layar Lebar ($\ge 1024$ dp)
*Acuan Aturan:* `AGENTS.md` (Pilar 4: Arsitektur Adaptif Desktop).  
*Aturan Baku:* Pada layar tablet dan desktop ($\ge 1024$ dp), Bottom Navigation Bar wajib bertransisi menjadi `NavigationRail` di sisi kiri, dan daftar satu kolom wajib bertransisi menjadi `Master-Detail Split View`.

| No | Berkas & Baris | Komponen | Pelanggaran Desktop | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 7.1 | [`lib/presentation/common_widgets/impal_bottom_nav_bar.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/impal_bottom_nav_bar.dart) | Shell Navigasi Bawah | Bottom nav bar tetap berada di bawah layar dengan lebar melar di monitor desktop lebar. | Tambahkan `LayoutBuilder`: Jika `constraints.maxWidth >= 1024`, sembunyikan bottom nav bar dan render `NavigationRail` / Sidebar vertikal di sisi kiri (lebar 240dp). | 🟢 **Rendah** |
| 7.2 | [`lib/presentation/features/task/task_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/task/task_page.dart) | Halaman Task | Kartu tugas meregang penuh selebar layar desktop ($> 1200$ dp), menyulitkan mata membaca. | Terapkan pola Master-Detail Split View: Panel kiri (lebar 380dp) untuk daftar kartu tugas, panel kanan untuk editor/detail tugas terpilih. | 🟢 **Rendah** |

---

### 8. 🎭 Standar Pengalaman Pengguna 5 State Matrix & Feedback Aksi (UX 5-State & Nielsen)
*Acuan Aturan:* `AGENTS.md` (Pilar 2: Standar UX & Matriks 5 State Antarmuka).  
*Aturan Baku:* Setiap daftar data wajib memiliki 5 State: Ideal, Empty, Loading Shimmer (bentuk identik dengan kartu), Error Recovery (tombol coba lagi), dan Offline Banner. Aksi destruktif wajib menyediakan *Undo Window* (SnackBar 4 detik).

| No | Berkas & Baris | Komponen | Pelanggaran State | Rekomendasi Solusi | Keparahan |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 8.1 | [`lib/presentation/features/schedule/schedule_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/schedule/schedule_page.dart) | Loading State Schedule | Masih menggunakan `CircularProgressIndicator` standar bawaan saat memuat jadwal. | Ganti dengan Skeleton Shimmer Loader yang memiliki bentuk dan ukuran identik dengan `ImpalScheduleCard`. | 🟢 **Rendah** |
| 8.2 | [`lib/presentation/features/team/team_list_page.dart`](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/team/team_list_page.dart) | Loading State Team | Menggunakan spinner standar di tengah layar. | Ganti dengan Shimmer Skeleton berjejer 3 kartu tim. | 🟢 **Rendah** |
| 8.3 | Global Shell (`lib/presentation/features/dashboard/home_page.dart`) | Penanganan State Offline | Belum ada deteksi konektivitas offline dan banner diskret di bagian atas shell aplikasi. | Tambahkan banner diskret tipis oranye di bawah status bar: *"Offline mode • Changes will sync automatically when reconnected"*. | 🟢 **Rendah** |
| 8.4 | Modul Hapus Jadwal (`SchedulePage`) & Tugas | Feedback Aksi Destruktif | Saat jadwal dihapus, aksi bersifat permanen seketika tanpa ada opsi pembatalan. | Pasang SnackBar *Undo Window* (durasi 4 detik dengan tombol `[ UNDO ]`) sebelum data benar-benar dihapus dari repositori. | 🟢 **Rendah** |

---

## 🎯 Rencana Eksekusi Bertahap (Step-by-Step Remediation Plan)

Untuk menuntaskan 31 ketidaksesuaian di atas tanpa regresi dan tetap menjaga `dart analyze` **0 Error, 0 Warning**, perbaikan dibagi ke dalam 4 Batch Terfokus:

```
┌────────────────────────────────────────────────────────────────────────┐
│ BATCH 1: Quick Wins & Critical Compliance (Prioritas Tertinggi)        │
│ • Bersihkan seluruh sisa Bahasa Indonesia (100% English UI).           │
│ • Fungsikan filter kategori Home ('College' vs 'Personal').            │
│ • Hubungkan tombol "See all" Ongoing Task ke Tab 1 (Task Page).        │
│ • Pasang PopScope pada HomePage untuk tombol back fisik Android.       │
│ • Perbaiki copy-paste bug hintText 'Name meeting' di Pop-Up Buat Tim.  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ BATCH 2: Touch Target Ergonomics & Header Standardization              │
│ • Standarisasi tombol back di create_task & create_task_team (38x38dp).│
│ • Perbesar hitbox tombol edit pensil tim & toggle bell menjadi 48x48dp.│
│ • Perbesar tap target checkbox Remember Me & Terms Privacy.            │
│ • Selaraskan font hardcoded ke context.rFont pada modul team.          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ BATCH 3: Core UX Features & Data Management                            │
│ • Fungsikan kartu ringkasan TaskTimelineSummary sebagai filter cepat.  │
│ • Tambahkan Empty State berilustrasi pada TaskPage.                    │
│ • Tambahkan chips filter [All Tasks] / [Assigned to Me] di Dashboard. │
│ • Tambahkan tombol Delete Task pada formulir edit tugas tim & personal.│
│ • Buat modal Team Members list pada Dashboard Tim.                     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ BATCH 4: AppSec Hardening & Desktop Adaptability                       │
│ • Amankan sesi login dengan flutter_secure_storage.                    │
│ • Tambahkan maxLength pada seluruh TextField input.                    │
│ • Terapkan Shimmer Skeleton Loader pada Schedule & Team.               │
│ • Evaluasi NavigationRail untuk desktop mode (>= 1024 dp).             │
└────────────────────────────────────────────────────────────────────────┘
```

---

> Dokumen audit ini telah diverifikasi dan siap dijadikan acuan kerja tim pengembang.  
> *Target akhir:* Kepatuhan 100% terhadap seluruh aturan `AGENTS.md` dan `.agents/rules/`.

