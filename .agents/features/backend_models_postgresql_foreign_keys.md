# 🗄️ Feature Log: Sinkronisasi Model Backend dengan PostgreSQL Foreign Keys (Prioritas 2)

**Tanggal**: 17 November 2026  
**Penanggung Jawab Fitur**: Habindra Dzaky Alghifari (103072400095)  
**Status**: Completed  
**Domain Terkait**: Backend Models, Kelompok (Groups), Todo Items, Tasks, Relational Integrity 3NF

---

## 1. Latar Belakang & Masalah
Berdasarkan spesifikasi skema relasional 3NF pada [DATABASE_REQUIREMENTS.md](file:///Users/habhindradzaky/Kuliah/IMPAL/IMPAL%20BE/Impal-02-07/document/DATABASE_REQUIREMENTS.md), tabel-tabel di database PostgreSQL memiliki *foreign key constraints* wajib (`NOT NULL REFERENCES ...`).

Sebelumnya, model-model di `backend/lib/models/kelompok/` dan `backend/lib/models/todo/` kehilangan kolom foreign key relasional tersebut:
1. `Group`: Tidak memiliki `id_leader` (wajib `REFERENCES users(id_user)`).
2. `GroupMember`: Tidak memiliki `id_member` (PK) dan `id_group` (FK ke `groups`).
3. `MeetingSchedule`: Tidak memiliki `id_group` (FK ke `groups`).
4. `GroupTask`: Tidak memiliki `id_group` (FK ke `groups`) dan `id_assigned_to` (FK ke `users`).
5. `GroupSubTask`: Tidak memiliki `id_group_task` (FK ke `group_task`) dan `id_assigned_to` (FK ke `users`).
6. `ToDoItem`: Tidak memiliki `id_user` (FK ke `users`).
7. `Task`: Tidak memiliki `id_user` dan `course_code`.

Ketiadaan field ini menyebabkan query `INSERT` / `UPDATE` ke PostgreSQL akan gagal fatal karena melanggar constraint NOT NULL.

---

## 2. Perubahan yang Dilakukan
Seluruh model telah diselaraskan dengan skema tabel PostgreSQL 15+:
- Ditambahkan field private, parameter constructor (dengan default fallback agar backwards compatible), getter, setter, serta parsing pada `fromJson()` dan serialisasi pada `toJson()`.

| Model | Berkas | Kolom Relasional yang Ditambahkan |
|---|---|---|
| `Group` | `backend/lib/models/kelompok/group.dart` | `id_leader` (`leaderId`) |
| `GroupMember` | `backend/lib/models/kelompok/group_member.dart` | `id_member`, `id_group`, `name`, `email` |
| `MeetingSchedule` | `backend/lib/models/kelompok/meeting_schedule.dart` | `id_group` (`groupId`) |
| `GroupTask` | `backend/lib/models/kelompok/group_task.dart` | `id_group` (`groupId`), `id_assigned_to` (`assignedToId`) |
| `GroupSubTask` | `backend/lib/models/kelompok/group_sub_task.dart` | `id_group_task` (`groupTaskId`), `id_assigned_to` (`assignedToId`) |
| `ToDoItem` | `backend/lib/models/todo/todo_item.dart` | `id_user` (`userId`) |
| `Task` | `backend/lib/models/task/task.dart` | `id_user` (`userId`), `course_code` (`courseCode`) |

---

## 3. Kepatuhan Standar
- **Class Diagram & ERD**: Selaras 100% dengan Bagian 5 [document/DATABASE_REQUIREMENTS.md](file:///Users/habhindradzaky/Kuliah/IMPAL/IMPAL%20BE/Impal-02-07/document/DATABASE_REQUIREMENTS.md).
- **Cybersecurity**: Siap digunakan pada prepared queries PostgreSQL dengan parameterized binding (`Sql.named` / `@param`).
