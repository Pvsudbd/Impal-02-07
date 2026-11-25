# 🛠️ Feature Log: Reminder & Schedule Persistence, Notification Feed & Engine (Option B)

**Tanggal**: 25 November 2026  
**Penanggung Jawab**: Yoga Perkasa Didik (Lead Backend)  
**Domain Terkait**: `profile` (`user_preferences`), `notifications` (`notification`), Isar (`UserCollection`), Flutter `ReminderNotificationService`

---

## 1. Masalah Awal
1. Seluruh toggle & modal di **Profile & Setting → Reminder & Schedule** (`Task Deadlines`, `Schedule Alerts`, `Team Alerts`, `Daily Morning Briefing`, `AI & Priority` toggles) sebelumnya hanya memperbarui state di RAM (`UserProfileRepository`) dan langsung hilang saat refresh/restart.
2. `UserProfileRepository.toggleCategoryAlert` untuk `schedule` & `team` hanya memperbarui satu sub-kategori (`lectureScheduleAlerts` / `teamMeetingAlerts`), menyebabkan switch Desktop gagal dimatikan bila `externalScheduleAlerts` / `teamTaskAlerts` aktif.
3. Belum ada tabel `user_preferences`, belum ada endpoint `/api/profile/preferences` maupun `/api/notifications`, `flutter_local_notifications` belum di-wire, dan logout belum mereset `UserProfileRepository` + `NotificationRepository`.

---

## 2. Implementasi (Option B)
### A. Database & Backend (Dart Frog)
- **PostgreSQL:** Menambahkan tabel `user_preferences` dan melengkapi kolom feed + deduplikasi pada `notification` (`category`, `category_label`, `status_tag`, `action_label`, `action_type`, `target_id`, `dedup_key`, index `uq_notification_user_dedup`).
- **Profile Preferences API ([profile_routes.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/routes/profile/profile_routes.dart), [profile_controller.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/controllers/profile/profile_controller.dart), [profile_model.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/models/profile/profile_model.dart)):**
  - `GET /api/profile` menyertakan field `preferences`.
  - `GET /api/profile/preferences` dan `PUT /api/profile/preferences` memakai JWT `idUser`, field whitelisting, dan parameterized query `INSERT ... ON CONFLICT (id_user) DO UPDATE`.
- **Notifications API ([notification_routes.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/routes/notifications/notification_routes.dart), [notification_controller.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/controllers/notifications/notification_controller.dart), [notification_model.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/backend/lib/models/notifications/notification_model.dart)):**
  - Mounted di `/api/notifications` dan `/api/v1/notifications` (`server.dart`).
  - Mendukung `GET /`, `POST /`, `POST /sync`, `PATCH /read-all`, `PATCH /:id/read` dengan UUID v4 36 karakter dan isolasi ownership `id_user`.

### B. Local Cache (Isar IO + SharedPreferences) & Frontend
- **Isar DB ([user_collection.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/data/local/collections/user_collection.dart), [isar_service_io.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/data/local/isar_service_io.dart), [isar_service_stub.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/data/local/isar_service_stub.dart)):** Menambah `preferencesJson` serta helper Map lintas platform (`getUserPreferencesMap`, `saveUserPreferencesMap`).
- **Profile Repository & Logout ([user_profile_model.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/profile/models/user_profile_model.dart), [profile_page.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/profile/profile_page.dart), [desktop_profile_settings_view.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/profile/widgets/desktop/desktop_profile_settings_view.dart), [home_header.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/dashboard/widgets/home_header.dart)):**
  - Semua update/toggle preferensi kini otomatis tersimpan ke `SharedPreferences`, Isar (native IO), dan disinkronkan via `PUT /api/profile/preferences`.
  - Bug `toggleCategoryAlert` diperbaiki agar mematikan/menyalakan kedua sub-kategori `Schedule` (`lecture` & `external`) dan `Team` (`teamTask` & `teamMeeting`).
  - Logout membersihkan token JWT, cache `UserProfileRepository`, `NotificationRepository`, dan `ReminderNotificationService`.
- **Reminder Engine & Notification Feed ([reminder_notification_service.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/core/services/reminder_notification_service.dart), [notification_repository.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/notifikasi/models/notification_repository.dart), [home_page.dart](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/frontend/lib/presentation/features/dashboard/home_page.dart)):**
  - Mengevaluasi deadline personal task, jadwal kuliah, jadwal eksternal, tugas tim, rapat tim, dan Daily Morning Briefing (Compact / Detailed) setiap 45 detik dan saat data/preferensi berubah, dengan deduplikasi `dedup_key` dan notifikasi OS lokal di platform native yang didukung.

