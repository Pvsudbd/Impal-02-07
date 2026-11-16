# 🗃️ Feature Log: Implementasi Isar DB Local Storage & Offline-First Sync

**Tanggal**: 16 November 2026  
**Penanggung Jawab Fitur**: Habindra Dzaky Alghifari (103072400095)  
**Status**: Completed (Skema, Service, & Sync Manager Ready)  
**Domain Terkait**: Frontend Local Storage, Offline-First Architecture, Task & Agenda Caching, Sync Manager

---

## 1. Latar Belakang & Tujuan
Berdasarkan spesifikasi arsitektur data **Offline-First Hybrid Architecture** pada [DATABASE_REQUIREMENTS.md](file:///Users/habhindradzaky/Kuliah/IMPAL/IMPAL%20BE/Impal-02-07/document/DATABASE_REQUIREMENTS.md), sisi klien Flutter memerlukan penyimpanan lokal berkecepatan tinggi (0ms latency) agar pengguna tetap dapat mengelola tugas, melihat agenda harian, dan menggunakan aplikasi saat perangkat tidak memiliki akses internet.

Sistem local database menggunakan **Isar DB** (NoSQL embedded engine).

---

## 2. Berkas yang Dibuat & Dimodifikasi

| Lapisan | Berkas | Deskripsi Operasional |
|---|---|---|
| **Config** | `frontend/pubspec.yaml` | Menambahkan dependensi `isar: ^3.1.0+1`, `isar_flutter_libs: ^3.1.0+1`, `path_provider`, `uuid`, serta dev dependencies `isar_generator` & `build_runner`. |
| **Koleksi** | `frontend/lib/data/local/collections/task_collection.dart` | Skema Isar untuk Tugas Personal & Skor Prioritas Fuzzy Mamdani dengan metadata sinkronisasi (`isSynced`, `syncAction`). |
| **Koleksi** | `frontend/lib/data/local/collections/agenda_collection.dart` | Skema Isar untuk Agenda Kuliah (*CourseSchedule*) & Kegiatan Pribadi (*PersonalSchedule*). |
| **Koleksi** | `frontend/lib/data/local/collections/user_collection.dart` | Skema Isar untuk Cache Profil Sesi Pengguna Aktif (Zero Insecure Storage: Password hash tidak disimpan). |
| **Koleksi** | `frontend/lib/data/local/collections/course_collection.dart` | Skema Isar untuk Cache Master Mata Kuliah (dropdown pembuatan tugas/jadwal offline). |
| **Koleksi** | `frontend/lib/data/local/collections/todo_item_collection.dart` | Skema Isar untuk Item Checklist Harian (To-Do). |
| **Service** | `frontend/lib/data/local/isar_service.dart` | Singleton Service pengelola instance Isar DB, operasi CRUD, reactive stream watchers, dan pembersihan sesi. |
| **Sync** | `frontend/lib/data/local/sync/offline_sync_manager.dart` | Manager sinkronisasi dua arah: Push Delta (`isSynced == false`) ke Dart Frog server dan Pull Latest dengan resolusi konflik *Last-Write-Wins* (LWW). |

---

## 3. Keselarasan Class Diagram & ERD
- **Tabel `task`**: Dipetakan ke `TaskCollection` dengan `remoteId` (UUID) bersesuaian dengan Primary Key `id_task` di PostgreSQL.
- **Tabel `agenda` (Class Table Inheritance)**: Dipetakan ke `AgendaCollection` yang menampung atribut gabungan `course_schedule` dan `personal_schedule`.
- **Tabel `users`**: Dipetakan ke `UserCollection` untuk subset profil publik pengguna aktif.
- **Tabel `course`**: Dipetakan ke `CourseCollection` untuk lookup offline cepat.

---

## 4. Kepatuhan Keamanan Siber (`.agents/cybersecurity.md`)
1. **Zero Insecure Storage**: Password hash atau kredensial autentikasi **TIDAK PERNAH** disimpan di koleksi `UserCollection` Isar DB. Token JWT disimpan terpisah pada Secure Storage.
2. **Metadata Pelacakan**: Setiap koleksi dilengkapi `updatedAt` untuk mencegah tabrakan data dan menjaga integritas audit saat data di-push ke server PostgreSQL.
