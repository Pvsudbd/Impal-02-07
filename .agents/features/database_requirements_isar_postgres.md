# 🗄️ Fitur: Database Requirements & Hybrid Storage (Isar DB & PostgreSQL)
<!-- Lokasi File: .agents/features/database_requirements_isar_postgres.md -->

Dokumentasi spesifikasi kebutuhan basis data dan arsitektur penyimpanan hybrid (*Offline-First*) yang memetakan tabel lokal (**Isar DB**) dan database online (**PostgreSQL**) melalui middleware **Dart Frog**.

---

## 📅 Tanggal & Waktu Terakhir Diperbarui
- **Waktu**: 2026-11-12
- **Penanggung Jawab Fitur**: Pengguna (Yoga / User Lead)
- **Status**: Spesifikasi Dokumen Selesai Disusun & Disetujui (Nama Tabel: `users` & `groups`)

---

## 📐 Rujukan Desain & Arsitektur
- **Skrip Migrasi Rename MySQL**: [migration_rename_users_groups.sql](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/migration_rename_users_groups.sql)
- **Dokumen Spesifikasi Lengkap**: [DATABASE_REQUIREMENTS.md](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/document/DATABASE_REQUIREMENTS.md)
- **Class Diagram**: [Class_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Class_Diagram.md)
- **Entity Relationship Diagram (ERD)**: [Entity_Relationship_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Entity_Relationship_Diagram.md)
- **Activity Diagram**: [Activity_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Activity_Diagram.md)
- **Use Case Diagram**: [Use_Case_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Use_Case_Diagram.md)
- **Data Flow Diagram (DFD)**: [Data_Flow_Diagram_DFD.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Data_Flow_Diagram_DFD.md)
- **Kamus Istilah**: [kamus.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/kamus.md)

---

## 🧱 Pembagian Lapisan Penyimpanan (Hybrid Storage Mapping)

| Lapisan | Teknologi | Peran & Entitas yang Dikelola |
| :--- | :--- | :--- |
| **Local Storage (Frontend)** | **Isar DB** (Flutter Embedded NoSQL) | Cache lokal offline-first: `TaskCollection`, `AgendaCollection`, `CourseScheduleCollection`, `PersonalScheduleCollection`, `CourseCollection`, `ToDoItemCollection`, `NotificationCollection`, serta cache `GroupCollection` & `GroupTaskCollection`. |
| **API Middleware (Backend)** | **Dart Frog** (HTTP REST & Routes) | Orkestrasi sinkronisasi data delta (`/api/sync`), otentikasi JWT, validasi input, dan penanganan aturan bisnis. |
| **Remote Database (Cloud/Server)** | **PostgreSQL** (Relational 3NF) | *Single Source of Truth* (SSOT): Menyimpan seluruh 13 entitas database relasional (`users`, `course`, `agenda`, `course_schedule`, `personal_schedule`, `task`, `todo_item`, `notification`, `groups`, `group_member`, `meeting_schedule`, `group_task`, `group_sub_task`) lengkap dengan referential integrity dan constraint. |

---

## 🔒 Aturan Keamanan & Batasan Data
1. `password_hash` **HANYA** disimpan pada tabel `users` di database server. Local Isar DB tidak pernah menyimpan hash kata sandi.
2. Frontend hanya menyimpan JWT token pada secure storage.
3. Seluruh koleksi Isar DB dilengkapi metadata pelacakan sinkronisasi: `remoteId`, `updatedAt`, `isSynced`, dan `syncAction`.

---

## 🐸 Mandat Framework Backend: Dart Frog
1. **Framework REST API**: Seluruh arsitektur backend dikembangkan menggunakan atau mengikuti standar **Dart Frog** (`dart_frog`).
2. **Konektor PostgreSQL**: Dart Frog berkomunikasi dengan PostgreSQL remote (`172.22.245.175:5432`) menggunakan driver resmi `package:postgres`.
3. **Format Standar Response**: Seluruh response API wajib dibungkus dalam format standar JSON Envelope Dart Frog:
   ```json
   {
     "status": "success" | "error",
     "message": "Deskripsi hasil operasi",
     "data": {} // atau []
   }
   ```
4. **Middleware Injection**:
   - `RequestContext` menyuntikkan sesi autentikasi pengguna (`idUser`, `email`, `role`).
   - Proteksi keamanan BOLA/IDOR dan validasi kepemilikan data sebelum melakukan mutasi data relasional.
