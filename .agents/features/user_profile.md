# 👤 Fitur: User Profile (Profil Mahasiswa)
<!-- Lokasi File: .agents/features/user_profile.md -->

Dokumentasi riwayat implementasi dan modifikasi fitur **User Profile** pada proyek Smart System Todolist.

---

## 📅 Tanggal & Waktu Terakhir Diperbarui
- **Waktu**: 2026-11-08 (Sprint 2 - IMPAL)
- **Penanggung Jawab Fitur**: Pengguna (Yoga / User Lead)
- **Status**: Selesai diimplementasikan & Terintegrasi Frontend-Backend

---

## 📐 Rujukan Desain & Arsitektur
- **Class Diagram**: Kelas `Student` di [Class_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Class_Diagram.md)
  - Atribut: `-studentId: String`, `-name: String`, `-email: String`.
  - Method:
    - `+login(): Boolean` (Auth Module)
    - `+viewDailyAgenda(date: Date): List<Agenda>`
    - `+viewCourseSchedule(): List<CourseSchedule>`
    - `+viewRemainingTasks(): List<Task>`
    - `+joinGroup(inviteCode: String): Boolean`
- **Entity Relationship Diagram (ERD)**: Tabel `student` di [Entity_Relationship_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Entity_Relationship_Diagram.md)
  - Kolom: `id_student (PK, UUID)`, `name`, `email (UK)`, `password_hash`, `created_at`, `updated_at`.

---

## 📂 Daftar Berkas yang Dibuat / Dimodifikasi

| Lapisan | Berkas | Status | Deskripsi |
| :--- | :--- | :---: | :--- |
| **Backend Model** | `backend/lib/models/profile/profile_model.dart` | **Baru** | Query data profil, agregasi statistik akademis (tugas selesai, tugas pending, total jadwal, mata kuliah), update nama & email, ganti password (BCrypt), dan method Class Diagram (`viewDailyAgenda`, `viewCourseSchedule`, `viewRemainingTasks`, `joinGroup`). |
| **Backend Controller** | `backend/lib/controllers/profile/profile_controller.dart` | **Baru** | Menangani request HTTP, ekstraksi `idStudent` dari JWT auth context, validasi body input, dan sanitasi response error (tanpa leak stack trace). |
| **Backend Route** | `backend/lib/routes/profile/profile_routes.dart` | **Baru** | Router endpoint profil yang dilindungi oleh `checkAuthMiddleware()`. |
| **Backend Server** | `backend/bin/server.dart` | **Modifikasi** | Registrasi dan mounting rute di `/api/profile` dan `/api/student`. |
| **Frontend Model** | `frontend/lib/presentation/features/profile/models/user_profile_model.dart` | **Modifikasi** | Penambahan sinkronisasi riil dari API (`fetchProfileFromApi()` dan `_syncToBackend()`) menggunakan `ApiClient`. |
| **Frontend UI** | `frontend/lib/presentation/features/profile/profile_page.dart` | **Modifikasi** | Pembersihan sesi total saat tombol Sign Out ditekan (`auth_token`, `jwt_token`, `auth_user`). |

---

## 🌐 Endpoint API yang Tersedia

Seluruh endpoint berikut berada di bawah path `/api/profile` (alias: `/api/student`) dan wajib menyertakan header `Authorization: Bearer <jwt_token>`:

1. `GET /api/profile`  
   Mengambil profil akun mahasiswa beserta ringkasan statistik akademis.
2. `PUT /api/profile`  
   Memperbarui nama dan email mahasiswa (dengan validasi anti-duplikasi email).
3. `PUT /api/profile/password`  
   Memvalidasi password lama dan memperbarui hash password baru dengan BCrypt.
4. `GET /api/profile/daily-agenda?date=YYYY-MM-DD`  
   Implementasi `+viewDailyAgenda(date: Date)` untuk kalender harian.
5. `GET /api/profile/course-schedules`  
   Implementasi `+viewCourseSchedule()` untuk daftar kuliah mingguan.
6. `GET /api/profile/remaining-tasks`  
   Implementasi `+viewRemainingTasks()` untuk sisa tugas yang belum selesai.
7. `POST /api/profile/join-group`  
   Implementasi `+joinGroup(inviteCode: String)` untuk bergabung ke kelompok belajar.

---

## 🛡️ Kepatuhan Keamanan (.agents/cybersecurity.md)
- [x] **Anti BOLA/IDOR**: `id_student` hanya diekstraksi dari verified JWT payload.
- [x] **Anti Mass Assignment**: Hanya field `name` dan `email` yang diperbolehkan di-update.
- [x] **Password Protection**: Password baru wajib minimal 6 karakter, tidak boleh sama dengan password lama, dan di-hash menggunakan BCrypt + Salt.
- [x] **Sanitasi Error**: Tidak membocorkan stack trace atau query SQL mentah ke klien.
- [x] **Session Hardening**: Token sesi dihapus total saat logout.

