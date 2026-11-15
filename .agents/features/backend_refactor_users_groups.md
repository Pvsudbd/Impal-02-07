# Feature Log: Refactoring Penamaan Tabel Users dan Groups di Backend

**Tanggal**: 12 November 2026  
**Penulis**: Antigravity Assistant & Tim Pengembang Impal-02-07  
**Status**: Completed  
**Domain Terkait**: Authentication, User Profile, Kelompok (Group), Agenda, Database Persistence

---

## 1. Latar Belakang & Tujuan
Berdasarkan generalisasi sistem dari ranah spesifik mahasiswa menjadi platform manajemen tugas dan kolaborasi umum (Multi-persona / General Users), entitas utama domain dan database diselaraskan:
1. `student` $\rightarrow$ `users` (Primary Key: `id_user`)
2. `study_group` $\rightarrow$ `` `groups` `` (Primary Key: `id_group`, di-escape dengan backticks karena reserved keyword di MySQL 8.0+)

Perubahan pada database MySQL (Laragon) telah dieksekusi oleh pengguna. Fitur ini bertujuan untuk merefaktor seluruh layer backend (Dart Shelf) agar sinkron dengan struktur tabel baru sekaligus menjaga **Zero-Downtime / Backwards Compatibility** dengan antarmuka frontend yang sedang berjalan.

---

## 2. Rincian Modifikasi File Backend

### A. Model Layer (`backend/lib/models/`)
1. **`auth/user_model.dart` (Baru)**:
   - Merepresentasikan entitas `UserModel` dengan kolom `idUser`, `name`, `email`, `passwordHash`.
   - Menggunakan query tabel `users` (`SELECT id_user ... FROM users`, `INSERT INTO users ...`).
   - Menyediakan getter kompatibilitas `idStudent => idUser` dan payload JSON mencakup `idUser` & `idStudent`.
   - Menghadirkan typedef: `typedef User = UserModel; typedef StudentModel = UserModel; typedef Student = UserModel;`.
2. **`auth/student_model.dart`**:
   - Re-export `user_model.dart` agar import lama tidak mengalami compile break.
3. **`kelompok/group.dart` (Baru)**:
   - Merepresentasikan entitas `Group` dengan atribut `groupId`, `groupName`, `description`, `inviteCode`.
   - Typedef alias: `typedef StudyGroup = Group; typedef GroupModel = Group;`.
4. **`kelompok/study_group.dart`**:
   - Re-export `group.dart` untuk kompatibilitas ke belakang.
5. **`kelompok/group_member.dart`**:
   - Mendukung parsing `id_user` (dengan fallback `id_student` dan `id_member`).
   - Serialisasi `toJson()` menyertakan `id_user` dan `id_student`.
6. **`kelompok/group_task.dart`**:
   - Menggunakan tipe `User? _pic` dan method `assignPIC(User user)`.
7. **`profile/profile_model.dart`**:
   - Seluruh query database dialihkan dari tabel `student` ke `users` (`WHERE id_user = :idUser`).
   - Query join grup dialihkan dari `study_group` ke `` `groups` `` (dengan backtick pelindung reserved word MySQL).
   - Menambahkan mekanisme fallback otomatis pada kolom anak (`task`, `agenda`, `group_member`) jika kolom foreign key di database masih bertransisi antara `id_user` dan `id_student`.
8. **`agenda/course_schedule.dart` & `agenda/personal_schedule.dart`**:
   - Parameter dan query diarahkan ke `a.id_user = :idUser`.
   - Disediakan fallback otomatis menangani kemungkinan kolom `id_student` di database.
   - Menyediakan alias static method `findByStudent(idStudent) => findByUser(idStudent)`.

---

### B. Middleware & Controller Layer (`backend/lib/controllers/` & `backend/lib/middleware/`)
1. **`middleware/auth/auth_middleware.dart`**:
   - Menginjeksi JWT payload ke context `user` dan context `student` (`request.change(context: {'user': payload, 'student': payload})`).
2. **`controllers/auth/auth_controller.dart`**:
   - Register dan Login menggunakan `UserModel`.
   - Token JWT ditandatangani dengan payload ganda `idUser` & `idStudent` agar kompatibel dengan frontend lama maupun baru.
3. **`controllers/profile/profile_controller.dart`**:
   - Mengambil ID autentikasi dari `context['user'] ?? context['student']`.
   - Method `getProfile`, `updateProfile`, `changePassword`, `viewDailyAgenda`, `viewCourseSchedule`, `viewRemainingTasks`, dan `joinGroup` sepenuhnya mendukung `idUser`.
4. **`controllers/agenda/agenda_controller.dart`**:
   - Helper `_getUserId(req)` mengambil identitas user secara aman dari JWT payload.
   - Seluruh endpoint `getAllSchedules`, `getCourseSchedules`, `createCourseSchedule`, `updateCourseSchedule`, `deleteCourseSchedule`, dan varian `personal` dialihkan menggunakan ID user.
5. **`controllers/dashboard/dashboard_controller.dart`**:
   - Menggunakan model `Group` dan parameter `userId`.

---

### C. Server & Routing (`backend/bin/server.dart` & `backend/lib/routes/`)
1. **`routes/profile/profile_routes.dart`**:
   - Deskripsi dan dokumentasi diselaraskan dengan domain User.
2. **`bin/server.dart`**:
   - Endpoint cek database `/test-db` menguji `SELECT COUNT(*) FROM users` dan mengembalikan `totalUsers` serta `totalStudents`.
   - Mounting rute menambahkan `/api/user` di samping rute lama `/api/student` dan `/api/profile`:
     ```dart
     app.mount('/api/profile', profileRoutes);
     app.mount('/api/user', profileRoutes);
     app.mount('/api/student', profileRoutes);
     ```

---

## 3. Strategi Keamanan & Kompatibilitas
- **MySQL Reserved Keyword Protection**: Tabel `` `groups` `` wajib dibungkus karakter backtick (`` ` ``) agar tidak memicu `SQL Error (1064)`.
- **BOLA / IDOR Protection**: Hak akses update dan delete data tetap diverifikasi terhadap kepemilikan JWT pemanggil.
- **Backwards Compatibility**: Setiap model dan controller mempertahankan alias penamaan (`idStudent`, `student`, `/api/student`) sehingga aplikasi Flutter client tidak akan error selama proses adaptasi kode client berlangsung.

