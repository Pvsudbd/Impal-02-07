# 📝 Feature Log: End-to-End Task Management Integration (CRUD, Dart Frog API & Multi-User State Isolation)

**Tanggal**: 17 November 2026  
**Penanggung Jawab Fitur**: Habindra Dzaky Alghifari (Frontend / Task) & Yoga Perkasa Didik (Lead Architect / Backend)  
**Status**: Completed & Verified  
**Domain Terkait**: Task Management, Dart Frog REST API, PostgreSQL 15+ Schema, Multi-User Isolation, UI Feedback

---

## 1. Latar Belakang & Masalah
Sebelumnya, fitur **Add Task** dan manajemen tugas (`task`) di aplikasi masih bersifat mock UI lokal:
1. Pada form pembuatan & pengeditan tugas (`create_task.dart`), operasi simpan hanya meniru latensi jaringan dengan `await Future.delayed(Duration(milliseconds: 350))` dan menghasilkan ID acak `task_${DateTime.now().millisecondsSinceEpoch}`.
2. Di backend Dart Frog, belum tersedia controller (`task_controller.dart`) maupun rute (`task_routes.dart`), sehingga endpoint `/api/task` belum terdaftar di `server.dart`.
3. Model `TaskItemModel` di Flutter belum memiliki serialisasi/deserialisasi (`fromBackendJson` & `toBackendJson`) untuk berkomunikasi dengan skema tabel PostgreSQL `task`.
4. State `TaskRepository` belum terkoneksi dengan alur autentikasi dan logout, berpotensi membocorkan data tugas antar-pengguna yang login bergantian di perangkat yang sama.

---

## 2. Solusi Rekayasa yang Diterapkan

### A. Backend Dart Frog REST API (`/api/task`)
1. **Controller (`backend/lib/controllers/task/task_controller.dart`)**:
   - `getTasks(Request req)`: Mengambil seluruh tugas milik user (`WHERE id_user = @idUser ORDER BY is_completed ASC, deadline ASC`) dengan fallback kompatibilitas skema `id_student`.
   - `getTaskById(Request req, String idTask)`: Mengambil detail satu tugas dengan validasi kepemilikan ketat (BOLA/IDOR Guard).
   - `createTask(Request req)`: Memvalidasi judul tugas dan deadline, melakukan sanitasi `course_code` ($\le 20$ karakter, ekstraksi kode sebelum bullet `•`), memastikan master data `course` terdaftar dengan safe fallback (mencegah error FK `fk_task_course`), melakukan type casting eksplisit PostgreSQL `@deadline::timestamptz` untuk mencegah error *datatype mismatch*, menghasilkan ID berbasis pure UUID v4 36-karakter tanpa prefix (mematuhi Section 8A `Agents.md`), dan mengembalikan response `201 Created`.
   - `updateTask(Request req, String idTask)`: Memperbarui judul, deskripsi/notes, mata kuliah, deadline (`@deadline::timestamptz`), prioritas, bobot nilai, dan status fuzzy dengan proteksi BOLA/IDOR.
   - `toggleComplete(Request req, String idTask)`: Melakukan toggle instan `is_completed = NOT is_completed` dan mengembalikan status terbaru.
   - `deleteTask(Request req, String idTask)`: Menghapus tugas dengan verifikasi kepemilikan pengguna.
2. **Routes (`backend/lib/routes/task/task_routes.dart`)**:
   - Seluruh rute dilindungi oleh `checkAuthMiddleware()`.
   - Rute: `GET /`, `POST /`, `GET /<idTask>`, `PUT /<idTask>`, `PUT /<idTask>/toggle`, `DELETE /<idTask>`.
3. **Mounting Server (`backend/bin/server.dart`)**:
   - Mendaftarkan sub-router ke path `/api/task` dan `/api/tasks`.
   - Menambahkan metadata endpoint pada response root `/` dan log konsol startup.

### B. Frontend Flutter Integration
1. **Serialization (`TaskItemModel`)**:
   - Menambahkan factory `TaskItemModel.fromBackendJson(Map<String, dynamic> json)` untuk memetakan kolom basis data PostgreSQL ke UI model (termasuk kalkulasi sisa jam, badge overdue, parsing prioritas, dan formatting tanggal).
   - Menambahkan method `toBackendJson()` untuk payload HTTP POST/PUT.
   - Menambahkan static method `formatDeadlineDateTime(DateTime dt)` untuk standarisasi format teks UI (`Sat 11 Oct 2026, 23: 59 WIB`).
2. **Repository Backend Synchronization (`TaskRepository`)**:
   - Menambahkan method `fetchTasksFromApi()` yang mengambil tugas riil via `ApiClient.get('/api/task')`.
   - Menambahkan method `createTaskApi()`, `updateTaskApi()`, `deleteTaskApi()`, dan `toggleTaskCompletion()`.
   - Menambahkan method `clear()` untuk membersihkan state memori saat logout.
3. **Refactoring Form (`create_task.dart`)**:
   - Menghapus mock `Future.delayed(350ms)` dan menggantinya dengan pemanggilan langsung ke `TaskRepository().createTaskApi()` atau `updateTaskApi()`.
   - Mengintegrasikan aksi hapus tugas dengan `TaskRepository().deleteTaskApi()`.
4. **Halaman Task (`task_page.dart`)**:
   - Memanggil `_repository.fetchTasksFromApi()` pada `initState`.
   - Membungkus scroll view dengan `RefreshIndicator` untuk sinkronisasi pull-to-refresh.
5. **Dashboard Home Page (`home_page.dart`)**:
   - Memanggil `TaskRepository().fetchTasksFromApi()` pada `initState` agar tugas sinkron sejak layar beranda dibuka.
6. **Multi-User State Isolation (`profile_page.dart` & `home_header.dart`)**:
   - Menambahkan pemanggilan `TaskRepository().clear()` bersamaan dengan `TeamRepository().clear()` pada dialog konfirmasi Sign Out / Logout.

---

## 3. Keselarasan Desain (Class Diagram & ERD)
- **Rujukan Class Diagram**: `D:\Telkom University\Semester 5\Impal\ImpalTB\Impal\Tubes\02_Diagram_dan_Model\Class_Diagram.md`
  - Atribut entitas `Task`: `taskId`, `userId`, `courseCode`, `taskTitle`, `description`, `deadline`, `gradeWeight`, `priorityScore`, `priority`, `isFuzzyAuto`, `isCompleted`.
  - Signature method: `calculateRemainingTime()`, `setCompletionStatus()`, `updateFuzzyPriority()`.
- **Rujukan Physical ERD**: `D:\Telkom University\Semester 5\Impal\ImpalTB\Impal\Tubes\02_Diagram_dan_Model\Entity_Relationship_Diagram.md`
  - Tabel `task`: Relasi `1:N` dari `users(id_user)` dan `1:N` dari `course(course_code)`.
  - Primary Key `id_task VARCHAR(36)`, Foreign Key `id_user VARCHAR(36)` dan `course_code VARCHAR(20)`.

---

## 4. Pengecekan Keamanan Siber (Cybersecurity Compliance)
- 🛡️ **BOLA / IDOR Protection**: Setiap operasi `GET /api/task/<id>`, `PUT /api/task/<id>`, `PUT /api/task/<id>/toggle`, dan `DELETE /api/task/<id>` memverifikasi klausa `id_user = @idUser` yang diekstrak dari JWT token terverifikasi. Pengguna tidak dapat membaca, mengubah, atau menghapus tugas milik pengguna lain.
- 🛡️ **Parameterized SQL Queries**: Seluruh query menggunakan parameter bernama `@idUser`, `@idTask`, `@courseCode`, dll. Bebas dari risiko SQL Injection.
- 🛡️ **Input Sanitization**: Panjang string `course_code` dibatasi maksimal 20 karakter sesuai DDL basis data. Judul tugas (`task_title`) divalidasi tidak boleh kosong.
- 🛡️ **Multi-User State Isolation**: State singleton `TaskRepository` dikosongkan secara eksplisit saat logout (`TaskRepository().clear()`), mencegah kebocoran data tugas antar-akun.

---

## 5. Berkas yang Dibuat & Dimodifikasi

| Lapisan | Berkas | Status | Ringkasan Modifikasi |
|---|---|---|---|
| **Backend Controller** | `backend/lib/controllers/task/task_controller.dart` | **Baru** | REST Controller lengkap untuk CRUD task dengan proteksi BOLA/IDOR dan fallback schema. |
| **Backend Routes** | `backend/lib/routes/task/task_routes.dart` | **Baru** | Rute `/api/task` terlindungi middleware JWT. |
| **Backend Server** | `backend/bin/server.dart` | **Modifikasi** | Pemasangan rute `/api/task` & `/api/tasks` ke dalam pipeline server Dart Frog. |
| **Backend Model** | `backend/lib/models/task/task.dart` | **Modifikasi** | Harmonisasi `fromJson` dan `toJson` dengan penanganan berbagai varian alias kolom basis data. |
| **Frontend Model** | `frontend/lib/presentation/features/task/models/task_item_model.dart` | **Modifikasi** | Penambahan method deserialisasi `fromBackendJson()`, serialisasi `toBackendJson()`, dan format tanggal. |
| **Frontend Repository** | `frontend/lib/presentation/features/task/models/task_repository.dart` | **Modifikasi** | Integrasi API call (`fetchTasksFromApi`, `createTaskApi`, `updateTaskApi`, `deleteTaskApi`, `toggleTaskCompletion`, `clear`). |
| **Frontend Form** | `frontend/lib/presentation/features/task/create_task.dart` | **Modifikasi** | Menghubungkan form Add Task & Edit Task ke API backend riil (menggantikan mock timer 350ms). |
| **Frontend UI** | `frontend/lib/presentation/features/task/task_page.dart` | **Modifikasi** | Sinkronisasi data awal API pada `initState` dan penambahan `RefreshIndicator`. |
| **Frontend Dashboard** | `frontend/lib/presentation/features/dashboard/home_page.dart` | **Modifikasi** | Sinkronisasi data tugas pada `initState`. |
| **Frontend Profile** | `frontend/lib/presentation/features/profile/profile_page.dart` | **Modifikasi** | Pembersihan state memori `TaskRepository().clear()` saat Sign Out. |
| **Frontend Header** | `frontend/lib/presentation/features/dashboard/widgets/home_header.dart` | **Modifikasi** | Pembersihan state memori `TaskRepository().clear()` saat dialog logout disetujui. |
| **Frontend Team** | `frontend/lib/presentation/features/team/team_list_page.dart` | **Modifikasi** | Penambahan import `app_colors.dart` pada empty state UI. |
| **Frontend Dashboard** | `frontend/lib/presentation/features/dashboard/home_page.dart` | **Modifikasi** | Pembersihan duplicate export import `team_repository.dart`. |

