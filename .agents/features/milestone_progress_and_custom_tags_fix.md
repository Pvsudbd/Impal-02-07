# 🛠️ Feature Log: Perbaikan Progress Milestone Team Task & Persistensi Custom Task Tags

**Tanggal**: 25 November 2026  
**Penanggung Jawab**: Yoga Perkasa Didik (Lead Backend)  
**Status**: Implemented (Menunggu eksekusi query SQL PostgreSQL oleh user)  
**Domain Terkait**: `groups`, `group_milestone`, `group_task`, `task`, `task_tags`, Isar DB (`TagCollection`)

---

## 1. Perbaikan Bug 1 — Progress Milestone Tidak Bertambah Saat Team Task Di-Slide
- **Akar Masalah:**
  1. `DashboardTeamPage` memuat & merender task serta milestone dengan `_teamLookupKey` (`widget.teamId`), namun `_handleTaskToggleCompletion` dan `_openEditTaskPage` sebelumnya mengirim `widget.teamCode` ke `TeamTaskRepository`.
  2. `initState` & `didUpdateWidget` memanggil fetch dua kali untuk `_teamLookupKey` dan `widget.teamCode`, memecah state in-memory.
  3. `GroupController.createGroupMilestone` memakai `ON CONFLICT (id_milestone)` yang rentan `42P10`, dan `updateGroupTask`/`toggleGroupTask` belum menangani fallback tipe `BOOLEAN` vs `INT` pada `is_completed`.
- **Perbaikan:**
  - Menyeragamkan pemakaian `_teamLookupKey` di [dashboard_team_page.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/team/dashboard_team_page.dart).
  - Menambahkan fallback pencarian lintas key di `TeamTaskRepository.toggleTaskCompletion` dan sinkronisasi `id_milestone` saat `fetchTasksFromApi` di [team_task_repository.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/team/models/team_task_repository.dart).
  - Mengganti `ON CONFLICT` di `GroupController.createGroupMilestone` dengan pola check-then-insert/update dan menambahkan fallback `BOOLEAN` pada `updateGroupTask` & `toggleGroupTask` di [group_controller.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/controllers/kelompok/group_controller.dart).

---

## 2. Perbaikan Bug 2 — Custom Task Tags (`Add Tag`) Hilang Saat Refresh
- **Akar Masalah:** Belum ada tabel `task_tags` di PostgreSQL, belum ada endpoint `/api/tags` di backend, dan belum ada `TagCollection` di Isar DB.
- **Perbaikan:**
  - **Backend Dart Frog:** Membuat `backend/lib/models/tags/tag_model.dart`, `backend/lib/controllers/tags/tag_controller.dart`, `backend/lib/routes/tags/tag_routes.dart`, dan mounting `/api/tags` + `/api/v1/tags` di `backend/bin/server.dart`. Menambahkan dukungan kolom `tags` pada `Task` / `TaskController` dan `GroupController`.
  - **Isar DB:** Membuat `frontend/lib/data/local/collections/tag_collection.dart` dan mendaftarkannya di `frontend/lib/data/local/isar_service.dart`.
  - **Frontend Repository:** Memperbarui `frontend/lib/presentation/features/task/models/tag_repository.dart` agar `init()`, `addTag()`, dan `deleteTag()` tersinkronisasi dengan `/api/tags` (PostgreSQL), `TagCollection` (Isar DB), serta `SharedPreferences` fallback.
  - **Dokumentasi:** Memperbarui `document/DATABASE_REQUIREMENTS.md` dan `Entity_Relationship_Diagram.md`.

---

## 3. Kepatuhan Keamanan (`.agents/cybersecurity.md`)
- Seluruh endpoint `/api/tags` dilindungi `checkAuthMiddleware()`, mengambil `idUser` eksklusif dari JWT, dan menggunakan parameterized query `@param` (zero SQLi & zero BOLA/IDOR).

