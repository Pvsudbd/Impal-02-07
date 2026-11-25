# 🤖 Agent Rules & Guidelines (Workspace Navigation & Feature Implementation)

Dokumen ini berisi instruksi dan batasan wajib bagi AI Agent saat bekerja di repositori ini.

---

## 1. 📂 Batasan Akses Direktori (Workspace Boundaries)

Saat bekerja di dalam direktori induk `D:\Telkom University\Semester 5`, Agent **HANYA** diperbolehkan mengakses, membaca, mencari, atau memodifikasi file pada dua folder berikut:
- ✅ `D:\Telkom University\Semester 5\TodoList` (Source code proyek aplikasi Frontend & Backend)
- ✅ `D:\Telkom University\Semester 5\Impal` (Dokumentasi Tugas Besar, Diagram UML, SKPL, ERD)

⚠️ **LARANGAN KERAS (STRICT RESTRICTION):**
- **DILARANG** mengakses, membaca, mencari (`search_dir`, `grep_search`, `list_dir`, `view_file`, dll.), ataupun memodifikasi folder dan file lain di luar folder `Impal` dan `TodoList` di direktori `D:\Telkom University\Semester 5` (misalnya folder mata kuliah lain atau berkas pribadi).

---

## 2. 📐 Aturan Wajib Sebelum Membuat Fitur Baru (New Feature Workflow)

Setiap kali Agent diminta untuk membuat, merancang, atau merefactor fitur baru (baik di sisi Frontend Flutter maupun Backend), Agent **WAJIB** membaca dan mematuhi dokumentasi arsitektur resmi terlebih dahulu:

### A. Rujukan Class Diagram (Struktur Kelas & OOP)
- **Lokasi File**: `D:\Telkom University\Semester 5\Impal\ImpalTB\Impal\Tubes\02_Diagram_dan_Model\Class_Diagram.md`
- **Fungsi & Kewajiban**:
  - Wajib memeriksa nama class, nama atribut (lengkap dengan tipe data & access modifier), dan signature method (parameter & return type).
  - Wajib mengikuti kaidah relasi antar-kelas (Inheritance/Generalization, Composition, Association, Dependency) sesuai diagram resmi.

### B. Rujukan ERD & Skema Database (Physical Schema & MySQL)
- **Lokasi File**: `D:\Telkom University\Semester 5\Impal\ImpalTB\Impal\Tubes\02_Diagram_dan_Model\Entity_Relationship_Diagram.md`
- **Fungsi & Kewajiban**:
  - Wajib memeriksa struktur nama tabel, nama kolom, tipe data SQL, Foreign Key, dan relasi fisik (misal: Class Table Inheritance pada `agenda`, `course_schedule`, `personal_schedule`).

---

## 3. 🎯 Prinsip Konsistensi & Integritas Dokumen

1. **Single Source of Truth**:
   - Selalu jadikan `Class_Diagram.md` dan `Entity_Relationship_Diagram.md` di folder `02_Diagram_dan_Model` sebagai satu-satunya rujukan utama.
   - **JANGAN PERNAH** menggunakan file usang / arsip lama (seperti `CDlama.md` di folder `vault/`).
2. **Validasi Desain Sebelum Implementasi**:
   - Pastikan entitas model, DTO, atau query database yang dibuat di kode selaras 100% dengan apa yang didefinisikan pada Class Diagram dan ERD.

---

## 4. 🛑 Batasan Operasi Git (Git Restrictions)

Demi menjaga keamanan dan riwayat version control proyek:
- ❌ **DILARANG KERAS (FORBIDDEN)**:
  - Melakukan `git commit` atau `git push` ke GitHub/remote repository secara mandiri/otomatis.
  - Memodifikasi riwayat commit atau melakukan operasi mutasi Git tanpa instruksi tegas dari pengguna.
- ✅ **DIPERBOLEHKAN (READ-ONLY INSPECTION)**:
  - Perintah git yang bersifat pemeriksaan status / observasi lokal, seperti `git status`, `git diff`, `git log`, `git branch`, dan sejenisnya.

---

## 5. 🏗️ Standar Framework Backend & Konvensi Struktur Folder (Dart Frog & Feature-Based Grouping)

### A. Mandat Framework Backend: Dart Frog
1. **Framework Standar Resmi**: Seluruh pengembangan endpoint REST API di backend **WAJIB** menggunakan atau mengikuti arsitektur **Dart Frog** (`dart_frog`).
2. **Koneksi Database**: Menggunakan driver resmi `package:postgres` (PostgreSQL 15+ remote server) dengan parameterized queries aman tanpa SQL Injection.
3. **Standar Response Envelope**: Semua response JSON wajib mengikuti format baku Dart Frog:
   ```json
   {
     "status": "success" | "error",
     "message": "Pesan informasi yang jelas",
     "data": {} // Objek hasil atau list data
   }
   ```
4. **Middleware & Context**: Menggunakan JWT Authentication Middleware untuk menginjeksi context user (`idUser`, `email`) ke setiap request handler, serta menerapkan proteksi BOLA/IDOR pada level middleware/controller.

### B. Konvensi Struktur Folder Berbasis Fitur (Feature-Based Grouping)
Ketika mengimplementasikan atau menambahkan fitur baru di backend (`backend/lib/`), Agent **WAJIB** mengorganisasi file ke dalam subfolder bernama fitur tersebut di setiap layernya agar terstruktur, rapi, dan mudah dirawat:
- `lib/controllers/<nama_fitur>/`
- `lib/models/<nama_fitur>/`
- `lib/routes/<nama_fitur>/`
- `lib/middleware/<nama_fitur>/` (jika fitur membutuhkan middleware khusus)
- `lib/config/<nama_fitur>/` (jika ada konfigurasi spesifik fitur)

**Contoh Implementasi:**
Jika membuat fitur bernama `makan` (sebagaimana pola yang sudah diterapkan pada `auth`, `agenda`, `kelompok`, `task`):
```text
backend/lib/
├── controllers/
│   └── makan/
│       └── makan_controller.dart
├── models/
│   └── makan/
│       └── makan_model.dart
├── routes/
│   └── makan/
│       └── makan_routes.dart
└── middleware/
    └── makan/ (opsional jika dibutuhkan)
```

⚠️ **LARANGAN:** Jangan pernah meletakkan file langsung di root `controllers/`, `models/`, atau `routes/` tanpa dibungkus subfolder nama fiturnya.

---

## 6. 👥 Pembagian Tugas & Kepemilikan Fitur Tim (Team Feature Ownership)

Untuk menjaga batas pengerjaan kode dan mencegah konflik antar-anggota tim saat berkolaborasi:

### ⚙️ Tim Backend (Dart Frog & PostgreSQL):
- **👤 Yoga (Pengguna / Lead Backend)**:
  - 🔑 **Autentikasi** (`auth`): Alur Login, Register, Forgot Password, Reset Password, JWT Auth Token, Auth Middleware.
  - 📅 **Jadwal** (`schedule` / `agenda`): Course Schedule, Personal Schedule, CRUD Agenda, API Sync, Deteksi Konflik Jadwal.
  - 👤 **User Profile** (`profile` / `student`): Profil Mahasiswa, Edit Data Diri, Ganti Password, Statistik Akun.
  - 🗄️ **Database & Sinkronisasi**: Koneksi PostgreSQL, Normalisasi Dialek SQL, Parameterized Query Security.
- **👤 Habindra**:
  - 📊 **Dashboard API**: Ringkasan statistik, kalkulasi agenda hari ini.
  - 👥 **Kelompok** (`team` / `kelompok`): Manajemen Kelompok Belajar/Tubes, Join Team via Invite Code, Create Team, Meeting Schedule.
  - 📝 **Task & ToDo** (`task` / `todo`): Manajemen Tugas Akademik, Bobot Nilai & Sisa Waktu, Smart Priority Rekomendasi, Todo Item.

### 📱 Tim Frontend (Flutter):
- **👤 Valen** & **👤 Kafi**:
  - Mengembangkan UI Flutter, komponen modular, State Management, Integrasi Isar DB lokal, dan navigasi aplikasi.

⚠️ **ATURAN AGENT KETIKA BEKERJA DENGAN YOGA:**
1. Fokus utama pekerjaan adalah pada layer **Backend (Dart Frog, PostgreSQL, Model/Controller/Routes)**.
2. Dilarang merombak antarmuka Frontend kecuali ada penyesuaian/integrasi eksplisit yang diperlukan untuk menyelaraskan dengan API Backend (misal: format DTO / API Client / sync endpoint).
3. Untuk modul backend, selalu prioritaskan fitur Yoga (Autentikasi, Jadwal, Profile, DB), dan hanya menyentuh modul Habindra jika diminta secara spesifik.

---

## 7. 📝 Pencatatan Riwayat Perubahan & Penambahan Fitur Wajib (`.agents/features/`)

Setiap kali Agent melakukan penambahan fitur baru, perbaikan kode (*bug fix*), *security hardening*, atau perubahan logika pada suatu fitur (baik di sisi Frontend maupun Backend):

1. **Lokasi Direktori & Penamaan Berkas Wajib:**
   - Agent **WAJIB** membuat atau memperbarui berkas dokumentasi di dalam folder:
     📂 `.agents/features/[nama_fitur].md`
   - Nama berkas **HARUS** berupa nama fitur yang baru saja diubah atau ditambahkan (misal: `user_profile.md`, `schedule.md`, `auth.md`, `cybersecurity_hardening.md`).

2. **Format & Isi Berkas Wajib Mencakup:**
   - 📌 **Nama Fitur & Tanggal Perubahan**.
   - 📂 **Daftar Berkas yang Dibuat / Dimodifikasi** (sertakan path lengkap).
   - ⚙️ **Rincian Teknis Perubahan** (apa fungsi baru yang ditambahkan, logika apa yang diubah).
   - 📐 **Rujukan Desain**: Keselarasan dengan `Class_Diagram.md` / `Entity_Relationship_Diagram.md`.
   - 🛡️ **Pengecekan Keamanan**: Verifikasi terhadap aturan `.agents/cybersecurity.md` (BOLA/IDOR, parameterized queries, auth context, sanitasi input/output).

3. **Kewajiban Otomatis:**
   - **DILARANG** menyelesaikan respon ke pengguna tanpa mencatat atau memperbarui berkas fitur terkait di folder `.agents/features/`.

---

## 8. 🛡️ Standar Integritas Data & Manajemen State Multi-Akun (Database Constraints & Multi-User State Isolation)

Demi menjaga integritas database dan mencegah kebocoran data antar-pengguna saat berganti akun di satu perangkat:

### A. Kepatuhan Batas Panjang Primary Key UUID (`VARCHAR(36)`) di Database
1. **Standar Ukuran UUID**: Seluruh kolom Primary Key dan Foreign Key bertipe UUID di database PostgreSQL (`id_user`, `id_group`, `id_member`, `id_agenda`, `id_task`, `id_item`, `id_meeting`, `id_group_task`, `id_sub_task`, `id_notification`) didefinisikan dengan tipe data **`VARCHAR(36)`**.
2. ❌ **LARANGAN KERAS (FORBIDDEN)**:
   - **DILARANG** menambahkan prefix string kustom pada UUID (misalnya: `'grp_' + _uuid.v4()`, `'mem_' + _uuid.v4()`, `'meet_' + _uuid.v4()`, `'gtask_' + _uuid.v4()`, `'todo_' + _uuid.v4()`).
   - Penambahan prefix tersebut menghasilkan panjang string 40–42 karakter yang pasti memicu error fatal basis data: `value too long for type character varying(36)`.
3. ✅ **MANDAT WAJIB**:
   - Selalu gunakan string UUID v4 murni berukuran tepat 36 karakter: `final id = _uuid.v4();`.
   - Untuk kolom kode unik pendek seperti `invite_code` pada tabel `groups` (`VARCHAR(10)`), panjang string yang di-generate tidak boleh melebihi 10 karakter.

### B. Isolasi Data Sesi & Pembersihan State Singleton (Multi-Account Session Cleanliness)
Di sisi Frontend Flutter, repository data yang menggunakan pola Singleton in-memory (`TeamRepository`, `ScheduleRepository`, `UserProfileRepository`, dll.) menyimpan state di RAM:
1. **Pembersihan Wajib saat Logout**: Setiap kali alur *Logout / Sign Out* dieksekusi (di `profile_page.dart` maupun `home_header.dart`), Agent **WAJIB** memanggil method `.clear()` atau `.reset()` pada seluruh singleton repository yang menyimpan data pengguna, selain menghapus token sesi di `SharedPreferences`.
2. **Sinkronisasi Tanpa Blocking Empty List**: Pada method sinkronisasi data API (seperti `fetchTeamsFromApi()`), **DILARANG** memblokir penimpaan data dengan kondisi `if (fetched.isNotEmpty) { _data = fetched; }`. Jika API mengembalikan array kosong `[]` (karena akun baru belum memiliki data di server), state lokal **WAJIB** diperbarui menjadi `[]` agar data akun sebelumnya tidak bocor ke layar akun yang baru login.
3. **Penyediaan Empty State UI**: Saat data lokal kosong (`_teams.isEmpty`), sediakan tampilan antarmuka *Empty State* yang ramah pengguna, alih-alih menampilkan data dummy atau data milik akun lain.

---

## 9. 🎨 Standar Komponen UI Task & Panduan Transisi Data Dummy (UI Integrity & Mock Cleanup)

Untuk menjaga konsistensi visual saat menghapus data dummy/mock dari proyek:

### A. Pengetahuan Komponen & Sumber Rujukan UI Resmi
Seluruh card dan badge tugas sudah diimplementasikan dalam komponen mandiri dan modular (karya Kafi / tim) yang menjadi rujukan baku desain:
1. **`HomeTaskCard`** (`frontend/lib/presentation/features/dashboard/widgets/home_task_card.dart`): Card tugas ringkas di beranda Dashboard dengan dukungan ekspansi.
2. **`TaskExpandableCard`** (`frontend/lib/presentation/features/task/widgets/task_expandable_card.dart`): Card tugas lengkap di halaman Tasks dengan detail defuzzifikasi, rubrik nilai, dan aksi edit/selesai.
3. **`TeamTaskCard`** (`frontend/lib/presentation/features/team/widgets/team_task_card.dart`): Card tugas kelompok dengan avatar anggota, badge prioritas, dan time range.
4. **`DesktopTaskGridCard`** (`frontend/lib/presentation/features/dashboard/widgets/desktop/desktop_task_grid_card.dart`): Card responsif 2-kolom untuk tampilan Desktop.

### B. Spesifikasi Baku Tingkat Prioritas (High, Medium, Low)
Penghapusan data dummy tidak boleh mengubah aturan pewarnaan dan styling prioritas berikut:
- 🔴 **High Priority**:
  - Background: `AppColors.primary` (`#FF7D65` / Coral Red-Orange)
  - Teks: `Colors.white`, Font: Inter 10.5dp Bold (`FontWeight.w700`), Label: `'High'` atau `'HIGH'`
- 🟡 **Medium Priority**:
  - Background: `#FBBF24` (Amber Gold)
  - Teks: `#1F2937` (Dark Gray), Font: Inter 10.5dp Bold (`FontWeight.w700`), Label: `'Medium'` atau `'MEDIUM'`
- 🟢 **Low Priority**:
  - Background: `#6EE7B7` (Mint Green)
  - Teks: `#064E3B` (Dark Green), Font: Inter 10.5dp Bold (`FontWeight.w700`), Label: `'Low'` atau `'LOW'`
- ⚪ **Completed Task**:
  - Background: `#363C48`, Teks: `#8E95A5`, Judul tugas dicoret (*lineThrough*).

### C. Aturan Pembersihan Data Dummy & Empty State
1. **Data Dummy Sebagai Placeholder Sementara**: Data statis seperti list task awal di `home_page.dart` (`_tasks`), `TaskItemModel.defaultTasks`, atau `TeamTaskRepository._teamTasks['7X29']` (yang memuat nama fiktif seperti *Andi Sukamoto*, *Rayya Gemintang*, dll. dari kelompok yang belum di-join) dapat dibersihkan dan diganti dengan data dinamis dari `TaskRepository().tasks`.
2. **Kewajiban Fallback Empty State**: Jika pengguna belum memiliki task atau belum bergabung dengan kelompok apapun, UI **WAJIB** menampilkan komponen *Empty State* yang sudah tersedia (ikon `Icons.assignment_turned_in_outlined` dengan pesan ramah pengguna), dan **DILARANG** menampilkan data kelompok atau anggota lain yang tidak relevan.
3. **Pemahaman Visual Tetap Terjaga**: Setiap Agent yang bekerja di masa mendatang diwajibkan membaca aturan ini sehingga tidak kehilangan pemahaman mengenai spesifikasi UI meskipun data dummy di kode telah dihapus sepenuhnya.






