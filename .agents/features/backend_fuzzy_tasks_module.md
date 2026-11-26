# Feature Log: Modul Fuzzy Mamdani XAI (`/api/smart-priority`) & CRUD Tugas (`/api/tasks`)

**Tanggal**: 26 November 2026  
**Penulis**: Antigravity Assistant & Yoga Perkasa Didik  
**Status**: Completed  
**Domain Terkait**: Fuzzy Mamdani Inference Engine (`FuzzyMamdaniService`), Task CRUD (`/api/tasks`), Smart Priority XAI (`/api/smart-priority`)

---

## 1. Daftar Berkas yang Dibuat / Dimodifikasi

### Backend (`Impal-02-07/backend/`)
- `lib/services/fuzzy_mamdani_service.dart` — Engine Mamdani Min-Max murni (*pure Dart*) dengan 2 input (`hoursRemaining` 0–336 jam dan `gradeWeight` 0–100%), 9 aturan Mamdani ($3 \times 3$), agregasi trapezoid/segitiga, dan defuzzifikasi Centroid (*Center of Gravity*) pada domain $0 \dots 100$ lengkap dengan payload Explainable AI (`reasonExplanation`, `deadlineParam`, `courseWeightParam`, `aggregationAreaText`, `firedRules`).
- `lib/models/task/task.dart` — Peningkatan model `Task` dengan query PostgreSQL terparametrisasi (`id_user`, `id_course`, integer flag `0`/`1`, `tags` `::jsonb`), integrasi auto-Fuzzy pada `create`/`update`, `setCompleted`, `recalculateAllForUser`, dan pembersihan otomatis matkul kustom tak terpakai via `CourseModel.cleanupUnusedCustomCourse`.
- `lib/controllers/task/task_controller.dart` & `lib/routes/task/task_routes.dart` — Endpoint CRUD `/api/tasks` (`GET /`, `GET /<idTask>`, `POST /`, `PUT /<idTask>`, `PATCH /<idTask>/complete`, `DELETE /<idTask>`) terlindungi JWT dengan validasi ketat & BOLA.
- `lib/controllers/smart_priority/smart_priority_controller.dart` & `lib/routes/smart_priority/smart_priority_routes.dart` — Endpoint `/api/smart-priority` (`GET /` ranking aktif + ringkasan + pembacaan `user_preferences`, `POST /evaluate` simulasi tanpa simpan, `POST /recalculate` hitung ulang massal ke DB).
- `bin/server.dart` & `routes/index.dart` — Mounting `/api/tasks` & `/api/smart-priority`.
- `test/fuzzy_and_tasks_test.dart` — Unit test matematis `FuzzyMamdaniService` + integration test `/api/tasks` & `/api/smart-priority` langsung ke live PostgreSQL.

---

## 2. Verifikasi Keamanan & Mutu
- Semua endpoint dilindungi `checkAuthMiddleware()` dan memakai `idUser` dari JWT context (anti-BOLA).
- Flag DB `task.is_completed` dan `task.is_fuzzy_auto` memakai integer `0`/`1`; `task.priority` selalu dibatasi `HIGH`, `MEDIUM`, atau `LOW` (`VARCHAR(6)`).
- `dart analyze`: `No issues found!`, seluruh integration & unit test lulus.
