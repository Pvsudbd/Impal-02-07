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
| **Frontend Task Merge** | `frontend/lib/presentation/features/task/create_task.dart` | **Modifikasi** | Resolusi merge conflict: integrasi UI rubrik penilaian (*course rubrics*), dialog custom weight %, dan tag picker dengan REST API `TaskRepository().createTaskApi()` & `updateTaskApi()`. |
| **Frontend Desktop Task** | `frontend/lib/presentation/features/task/widgets/desktop/desktop_personal_task_modal.dart` | **Modifikasi** | Menghubungkan modal desktop ke API riil (`createTaskApi`, `updateTaskApi`, `deleteTaskApi`) dengan penanganan error. |
| **Frontend Model** | `frontend/lib/presentation/features/task/models/task_item_model.dart` | **Modifikasi** | Pemetaan field `gradeWeightPercent` ke kolom `grade_weight` di payload `toBackendJson` dan `fromBackendJson`. |

---

## 6. Resolusi Merge Branch `frontend` & Penyelarasan Input Bobot Nilai (21 November 2026)
Pada 21 November 2026, branch `frontend` (berisi penambahan 26 commit UI dari Habhindra: layout desktop, rubrik penilaian Mamdani, tag kustom, dan dialog input bobot nilai manual) digabungkan ke branch `backend`:
1. **Resolusi Konflik 7 Berkas**:
   - `forgot_password_page.dart`: Menggunakan layout responsif desktop terbaru dari frontend (`if (isDesktop) dynamicInput ... else methodCards`).
   - `reset_password_page.dart`: Menghapus blok duplikasi field password pada HEAD.
   - `home_page.dart`: Menggabungkan inisialisasi lokal (`TaskTagRepository`, `CourseRubricRepository`) dengan pemanggilan API backend (`TeamRepository().fetchTeamsFromApi()`, `TaskRepository().fetchTasksFromApi()`).
   - `team_list_page.dart`: Menggabungkan import `AppColors` dan `ResponsiveContext`.
   - `task_page.dart`: Menggabungkan `TaskTagRepository().init()` dengan `_repository.fetchTasksFromApi()`.
   - `create_task_team.dart`: Mempertahankan validasi overdue `isPastDeadline` sembari mengintegrasikan `CourseRubricRepository` dan tags.
   - `create_task.dart`: Menggabungkan selector rubrik & dialog *Custom Weight %* (1–100%) milik Habhindra dengan pipeline REST API `TaskRepository().createTaskApi()`.
2. **Koneksi Bobot Nilai ke Database PostgreSQL**:
   - `TaskItemModel.toBackendJson()` sekarang mengirimkan nilai `grade_weight: (gradeWeightPercent?.toDouble() ?? 0.0)` sehingga nilai bobot tugas akademik tersimpan langsung ke kolom `grade_weight` di PostgreSQL `task` table.
3. **Verifikasi Kualitas**:
   - `flutter analyze` pada frontend: **0 issues found** (No issues found).
   - `dart analyze` pada backend: **0 issues found** (No issues found).

---

## 7. Penanganan Bobot Otomatis Tugas Personal & Standar Desain Kartu Prioritas (21 November 2026)

### A. Perbaikan Selector Bobot Nilai Personal Task
1. **Masalah**: Pada saat membuat task bertipe Personal (`_isCollegeTask == false`), jika toggle "Automatic" dicentang, UI sebelumnya hanya mengembalikan `SizedBox(height: 0)` karena `RubricAssessmentSelector` hanya aktif untuk tugas perkuliahan (`isCollegeTask == true`). Akibatnya pengguna tidak bisa memilih atau memasukkan bobot tugas pribadi.
2. **Solusi Rekayasa**:
   - Menambahkan komponen `PersonalTaskWeightSelector` pada `course_grade_weight_chips.dart` yang menyediakan preset nilai bobot kepentingan (`Light 15%`, `Normal 30%`, `Important 50%`, `Urgent 80%`) serta opsi interaktif `Custom %` dengan dialog input angka manual (1–100%).
   - Mengintegrasikan `PersonalTaskWeightSelector` ke form mobile (`create_task.dart`) dan modal desktop (`desktop_personal_task_modal.dart`).
   - Menyimpan bobot tersebut ke dalam `TaskTagModel` berlabel `Weight: X%` serta resolusi `gradeWeightPercent`.

### B. Standardisasi Integritas Desain UI Task & Pembersihan Mock Data
1. Menambahkan **Bab 9 pada `.agents/rules/Agents.md`** mengenai:
   - Sumber rujukan resmi komponen task: `HomeTaskCard`, `TaskExpandableCard`, `TeamTaskCard`, dan `DesktopTaskGridCard`.
   - Spesifikasi warna dan teks baku untuk tingkat prioritas:
     - 🔴 **High**: `#FF7D65`, teks putih `'High'`.
     - 🟡 **Medium**: `#FBBF24`, teks `#1F2937` `'Medium'`.
     - 🟢 **Low**: `#6EE7B7`, teks `#064E3B` `'Low'`.
     - ⚪ **Completed**: `#363C48`, teks `#8E95A5`.
   - Pedoman transisi pembersihan data dummy/mock dari `home_page.dart` (`_tasks`) dan repositori ke data dinamis `TaskRepository().tasks` dengan kewajiban fallback antarmuka *Empty State*.



---

## 8. Pembersihan Data Template Task di Dashboard & Isolasi Multi-Akun (21 November 2026)

### A. Latar Belakang & Kebutuhan
Sebelumnya pada Dashboard (`home_page.dart`) dan halaman Tasks (`task_page.dart`):
1. Variabel `_tasks` di `home_page.dart` memuat 4 kartu tugas dummy ("Wallet App Design", "IMPAL Figma Design", "Dashboard & Mobile App", "IMPAL Frontend Slicing") yang berisi anggota kelompok fiktif (*Andi Sukamoto*, *Rayya Gemintang*, dll.). Tugas-tugas ini selalu muncul terlepas dari akun siapa yang login.
2. Pada `TaskRepository.init()`, state awal di-seed menggunakan `TaskItemModel.defaultTasks`, sehingga tugas mock otomatis tampil di bagian "Today Task" untuk semua akun.
3. Pada `TeamTaskRepository.init()`, kode tim `7X29` di-seed dengan tugas fiktif yang di-assign ke "Yoga Perkasa Didik", sehingga tugas kelompok tersebut bocor ke akun pengguna baru.

### B. Solusi Rekayasa yang Diterapkan
1. **Dinamisasi Dashboard Tasks (`home_page.dart`)**:
   - Menghapus list hardcoded `_tasks` dan menginisialisasinya sebagai `List<TaskItem> _tasks = [];`.
   - Menghubungkan `home_page.dart` ke `TaskRepository` dengan mendengarkan perubahan via `TaskRepository().addListener(_syncTasksFromRepo)` dan memanggil `_syncTasksFromRepo()` saat `initState`.
   - Pada layout desktop, jika tidak ada tugas aktif (`activeTasks.isEmpty`), kartu `DesktopHeroFocusCard` tidak lagi menampilkan fallback palsu 'Wallet App Design', melainkan menampilkan antarmuka bersih *Empty State* bawaan (`DesktopOngoingTasksSection`).
2. **Pembersihan State Awal Repository (`task_repository.dart` & `team_task_repository.dart`)**:
   - `TaskRepository().init()` dan `TeamTaskRepository().init()` sekarang murni mengosongkan state lokal (`_tasks.clear()`).
   - Seeding data fixture (`defaultTasks` dan fixture tim `7X29`) dipindahkan secara eksklusif ke method `resetToDefaults()`, sehingga hanya dijalankan pada saat pengujian unit/widget test.
   - Di lingkungan runtime, data tugas murni ditarik dari backend melalui `TaskRepository().fetchTasksFromApi()`.
3. **Penyempurnaan Filter "Today Task" (`task_page.dart`)**:
   - Memperbaiki filter tab `Today` agar memeriksa kecocokan tanggal `deadlineDate` dengan `DateTime.now()` atau sisa jam badge (`endsWith('h')`, `<1h`, `0d`).
   - Judul section secara dinamis menyesuaikan filter aktif (`Today Task` saat filter Today, dan `[Filter] Tasks` saat filter lain aktif).
   - Memperbarui label tanggal dinamis pada `DesktopTasksManagementView`.

## 9. Pembersihan Template Anggota Assignee & Integrasi Dinamis Anggota Tim (21 November 2026)

### A. Latar Belakang & Kebutuhan Pengguna
Pada fitur pembuatan tugas kelompok (**Create Team Task** baik di mobile `create_task_team.dart` maupun desktop `desktop_team_task_modal.dart`), sebelumnya terdapat template nama anggota fiktif seperti:
- "Ahmad Sahroni"
- "Muhammad Kafi Rijal"
- "Yoga Perkakas"

Kebutuhan pengguna:
1. Template fiktif tersebut dihapus sepenuhnya.
2. Anggota yang dapat dipilih / di-assign tugas **hanya anggota yang benar-benar telah bergabung (*join*) di grup/tim tersebut**.
3. Jika grup tersebut baru dibuat dan belum ada anggota lain yang bergabung, maka dropdown hanya memuat akun pengguna yang sedang login.
4. Desain dan styling frontend (UI/UX) tetap dipertahankan 100% tanpa ada pergeseran tata letak maupun komponen visual.

### B. Solusi Rekayasa yang Diterapkan
1. **Penyempurnaan `TeamRepository` (`team_repository.dart`)**:
   - Menambahkan method `Future<List<TeamMemberModel>> fetchGroupMembers(String teamCodeOrId, {String? fallbackUserName})` yang memanggil endpoint backend `GET /api/groups/<idGroup>`.
   - Endpoint backend mengembalikan `data.members` yang berisi `id_user`, `name`, `email`, dan `role`.
   - Menambahkan caching lokal di `_cachedMembers` dan method sinkron `getCachedMembers(teamCodeOrId)`.
   - Jika belum ada data anggota lain di API, sistem otomatis menetapkan akun pengguna saat ini sebagai anggota tunggal dalam tim.

2. **Dinamisasi Assignee di Modal & Form Create Task**:
   - `create_task_team.dart`: Menerima parameter opsional `groupMembers` dan melakukan sinkronisasi dengan `TeamRepository().fetchGroupMembers()`. List `_availableMembers` dan `_selectedMembers` diinisialisasi berdasarkan anggota aktual grup, bukan `TeamMemberModel.defaultMembers`.
   - `desktop_team_task_modal.dart`: Menambahkan parameter `groupMembers` pada constructor dan method statis `show()`. Dropdown multi-select assignee (`_buildAssigneeSection`) sekarang secara dinamis menampilkan anggota tim aktual.

3. **Integrasi di Team Dashboard & Team Members Modal (`dashboard_team_page.dart` & `desktop_team_workspace_panel.dart`)**:
   - Mengambil data anggota grup di `initState()` dan menyimpannya di state `_teamMembers`.
   - Meneruskan `_teamMembers` ke `CreateTaskTeamPage` dan `DesktopTeamTaskModal`.
   - Memperbarui pop-up **Team Members** (`_showTeamMembersModal`) dan sidebar overview desktop (`DesktopTeamWorkspacePanel`) agar menampilkan data anggota riil dari grup yang dipilih, menggantikan hardcoded template anggota fiktif (Andi Sukamoto, Rayya Gemintang, dkk).

## 10. Perbaikan Sinkronisasi Multi-Member (Yoga Perkasa & Habindra) & Resolusi ID Kelompok (21 November 2026)

### A. Gejala Masalah
Pada grup "cihuyotomotif" yang beranggotakan dua orang (Yoga Perkasa dan Habindra):
- Ketika login sebagai Yoga Perkasa, dropdown task assignee dan modal Team Members hanya memunculkan nama Yoga Perkasa.
- Ketika login sebagai Habindra, hanya memunculkan nama Habindra.
- Anggota lain yang sudah join tidak nampak sama sekali di antarmuka masing-masing.

### B. Akar Penyebab (Root Cause Analysis)
1. **Penerusan Hardcoded `'7X29'` di Navigasi Dashboard**:
   - Pada `home_page.dart` (mobile tab & desktop), `task_page.dart`, dan `desktop_tasks_management_view.dart`, parameter `teamCode` yang dikirim ke `DashboardTeamPage` sebelumnya di-hardcode ke `'7X29'`. Akibatnya, API dipanggil dengan target grup `'7X29'` yang bukan ID dari grup "cihuyotomotif".
2. **Kueri Backend Hanya Mencari `WHERE id_group = @idGroup`**:
   - Pada endpoint backend `GET /api/groups/<idGroup>`, kueri SQL hanya memeriksa `id_group` (yang bertipe UUID). Jika client mengirimkan `invite_code` (misalnya kode invite huruf/angka) atau nama grup, PostgreSQL mengembalikan 404 (Group not found).
   - Akibat status 404, frontend fallback ke single-user lokal (`fallbackUserName`), sehingga hanya pengguna yang sedang login yang muncul.
3. **Pencarian Leader & Relasi Member**:
   - Jika leader grup (`id_leader`) belum tercatat di baris `group_member`, leader tidak terambil dalam kueri join `group_member`.

### C. Solusi Rekayasa yang Diterapkan
1. **Fleksibilitas Identifikasi Grup di Backend (`group_controller.dart`)**:
   - Menambahkan fungsi pembantu `_findGroupRecord` yang mencari grup secara cerdas melalui `id_group = @val OR UPPER(invite_code) = UPPER(@val) OR LOWER(group_name) = LOWER(@val) LIMIT 1`.
   - Menyelesaikan `realIdGroup` (UUID riil di database) sebelum menjalankan kueri anggota, rapat, dan tugas.
   - Menjamin bahwa leader pencipta kelompok (`id_leader`) dan seluruh anggota `group_member` selalu digabungkan dan dikembalikan secara lengkap ke client.
2. **Propagasi `teamId` dan `inviteCode` Riil di Frontend**:
   - Menambahkan parameter opsional `teamId` pada `DashboardTeamPage` serta getter dinamis `_teamLookupKey`.
   - Mengganti seluruh pemanggilan hardcode `'7X29'` di `home_page.dart`, `task_page.dart`, `team_list_page.dart`, dan `desktop_tasks_management_view.dart` dengan ID riil (`team.id`) dan invite code riil.
3. **Penyempurnaan `fetchGroupMembers` dan `getCachedMembers` (`team_repository.dart`)**:
   - Memastikan `fetchTeamsFromApi()` dipanggil jika daftar tim masih kosong.
   - Melakukan pencocokan case-insensitive berdasarkan `id`, `inviteCode`, maupun `name`.
   - Menyimpan cache anggota di bawah seluruh alias pengenal grup (`targetId`, `teamCode`, `teamName`).
   - `create_task_team.dart` dan `desktop_team_task_modal.dart` secara reaktif menyegarkan daftar anggota jika data multi-anggota dari API telah selesai dimuat.

## 11. Eliminasi Template "Jarvis S." dan Resolusi Skema Member Database (`id_student` vs `id_user`)

### A. Gejala Masalah
1. Pada antarmuka Desktop Group Workspace aside panel (`DesktopTeamWorkspacePanel`), muncul anggota fiktif bernama **"Jarvis S."** bukannya Habindra.
2. Modal daftar anggota hanya menampilkan 1 orang (Yoga Perkasa) dan tidak memunculkan Habindra.

### B. Akar Masalah
1. **Data Template Mock di Desktop Workspace Panel**:
   - `DesktopTeamWorkspacePanel` memiliki static list mock `_members` dengan elemen teratas bernama `"Jarvis S."`. Ketika cache anggota grup belum siap atau belum tersinkronisasi, komponen ini langsung me-render `_members`.
   - `DesktopGroupWorkspaceView` sebelumnya tidak meneruskan `groupMembers` ke `DesktopTeamWorkspacePanel`, sehingga panel desktop selalu jatuh ke fallback template mock.
2. **Ketidaksesuaian Kolom Primary Key di Tabel Users (`id_user` vs `id_student`)**:
   - Tabel `users` pada basis data PostgreSQL menggunakan kolom `id_student`, sedangkan kueri join di `group_controller.dart` mengasumsikan kolom `id_user`.
   - Ketika kueri anggota berjalan, kesalahan sintaks PostgreSQL menyebabkan kueri anggota gagal mengekstrak data anggota selain leader (yang memiliki blok fallback tersendiri).
3. **Modal Dialog Statis Tanpa Reaktivitas**:
   - `_showTeamMembersModal()` membuka dialog/bottomsheet secara sinkron sebelum panggilan asinkron `fetchGroupMembers()` selesai, sehingga modal tidak diperbarui ketika data respons tiba.

### C. Solusi Rekayasa
1. **Helper Toleran Skema `_findUserById` di Backend (`group_controller.dart`)**:
   - Mengambil seluruh anggota terdaftar dari tabel `group_member` menggunakan `WHERE id_group::text = @idGroup`.
   - Melakukan resolusi profil pengguna via helper `_findUserById()` yang mencoba secara bertahap kombinasi `id_user` / `id_student` dan `name` / `nama`.
   - Menggabungkan leader dan anggota secara utuh tanpa risiko terpotong atau duplikasi.
2. **Penerusan `groupMembers` ke Desktop Panel**:
   - Menghubungkan `_teamMembers` dari `DashboardTeamPage` ke `DesktopGroupWorkspaceView` dan `DesktopTeamWorkspacePanel`.
   - Mengisolasi data mock FigCraft `7X29` hanya untuk test environment dan menghilangkannya dari tampilan riil tim.
3. **Modal Reaktif `StatefulBuilder`**:
   - Membungkus `_showTeamMembersModal()` dengan `StatefulBuilder` sehingga saat `fetchGroupMembers()` berhasil mengambil seluruh anggota, tampilan modal langsung di-re-render seketika.

---

## 4. Perbaikan Sinkronisasi Multi-User Tim & Fitur Join Kode Undangan (Yoga Perkasa & Habindra)

### A. Gejala Permasalahan
1. **Modal Join Team Menolak Kode Undangan Tim Riil**:
   Ketika pengguna (Habindra) memasukkan kode tim riil (misal dari kelompok "cihuyotomotif" yang dibuat oleh Yoga), modal menampilkan peringatan `No study team matches code "...". Double-check with your team leader.` dan tombol join diblokir.
2. **Jumlah Anggota di Direktori vs Ruang Kerja Tidak Sinkron**:
   Pada direktori luar/dashboard tim tertulis `2 member`, namun saat masuk ke ruang kerja tim hanya tampil 1 orang.
3. **Akun yang Login Selalu Menjadi Leader**:
   Saat Yoga login, Yoga tampil sebagai Leader tunggal. Saat Habindra login, Habindra tampil sebagai Leader tunggal, padahal kelompok diciptakan oleh Yoga dan seharusnya Yoga tetap sebagai Leader sedangkan Habindra sebagai Member.

### B. Analisis Akar Masalah (Root Cause Analysis)
1. **Modal `PopUpJoinTeam` Menggunakan Pemeriksaan Fixture Statis**:
   Fungsi `_findTeamByCode(String code)` di `pop_up_join_team.dart` hanya mencari di dalam `DesktopTeamDirectoryFixtures.defaultTeams`. Tim yang dibuat dinamis di PostgreSQL tentu tidak berada di daftar statis tersebut. Akibatnya `canSubmit` bernilai `false` dan fungsi `_handleJoin()` mengembalikan return lebih awal tanpa pernah menembak endpoint `POST /api/groups/join`.
2. **Kegagalan Ekstraksi Anggota di Backend `getGroupDetails`**:
   Di `group_controller.dart`, kueri anggota dieksekusi dengan `ORDER BY role DESC, joined_at ASC`. Apabila nama kolom tanggal bervariasi (`joined_date` vs `joined_at`), kueri tersebut melemparkan exception ke blok `catch`, menghasilkan `memberList = []`.
3. **Fallback Lokal Frontend yang Menimpa Identitas**:
   Ketika API detail grup gagal, `TeamRepository.fetchGroupMembers()` mengembalikan fallback berisi 1 orang berdasarkan `widget.userName` dengan role hardcoded `'Team Leader'`. Hal ini menyebabkan Yoga melihat dirinya sebagai Leader, dan Habindra melihat dirinya sebagai Leader.

### C. Solusi Rekayasa
1. **Dukungan Penuh Kode Tim di `PopUpJoinTeam`**:
   - Memeriksa tim di `TeamRepository().teams` selain `DesktopTeamDirectoryFixtures.defaultTeams`.
   - Mengizinkan kode undangan valid (panjang >= 4 karakter) untuk diproses ke backend API.
   - Banner modal menampilkan status siap gabung tanpa memblokir tombol join.
2. **Penanganan Respons Gabung Tim**:
   - Menghubungkan pemanggilan API `TeamRepository().joinTeamApi(code)` di `home_page.dart` dan `team_list_page.dart`.
   - Menangkap pesan backend `You are already a member of this team.` dan menampilkan pop-up ramah `Already Joined: You have already joined this team.`.
3. **Kueri Tangguh & Sorting di Memori Backend (`group_controller.dart`)**:
   - Menghapus klausa SQL `ORDER BY` yang rawan crash: `SELECT * FROM group_member WHERE id_group::text = @idGroup`.
   - Memastikan status leader selalu valid sesuai `id_leader` di tabel `groups`, sementara member lainnya berstatus `MEMBER`.
   - Melakukan pengurutan aman di memori Dart (Leader di urutan teratas, diikuti anggota lainnya).
4. **URL Encoding & Sinkronisasi Direktori**:
   - Menggunakan `Uri.encodeComponent(targetId)` di `TeamRepository.fetchGroupMembers` agar aman terhadap spasi atau nama tim.
   - Menyinkronkan daftar tim di desktop melalui listener `teamsNotifier` di `home_page.dart`.
