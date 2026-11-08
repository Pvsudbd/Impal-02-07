# 📅 Fitur: Schedule & Agenda (Jadwal Terpadu Mahasiswa)
<!-- Lokasi File: .agents/features/schedule_agenda.md -->

Dokumentasi riwayat implementasi fitur **Schedule & Agenda** (Jadwal Kuliah & Kegiatan Personal) pada proyek Smart System Todolist.

---

## 📅 Tanggal & Waktu Terakhir Diperbarui
- **Waktu**: 2026-11-08 (Sprint 2 - IMPAL)
- **Penanggung Jawab Fitur**: Pengguna (Yoga / User Lead)
- **Status**: Selesai & Terverifikasi (Thunder Client + Frontend Sync)

---

## 📐 Rujukan Desain & Arsitektur
- **Class Diagram**: [Class_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Class_Diagram.md)
  - Superclass abstrak: `Agenda` (`agendaId`, `title`, `startTime`, `endTime`, `location`, `getDurationMinutes()`, `checkConflict()`).
  - Subclass `CourseSchedule`: Khusus jadwal kuliah mingguan (`day`, `room`, relasi ke master `Course`).
  - Subclass `PersonalSchedule`: Khusus kegiatan personal/organisasi ber-tanggal spesifik (`date`, `category`, `notes`).
- **Entity Relationship Diagram (ERD)**: [Entity_Relationship_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Entity_Relationship_Diagram.md)
  - Pola **Class Table Inheritance**: Tabel superclass `agenda` berelasi 1:0..1 ke `course_schedule` dan `personal_schedule` dengan PK=FK `id_agenda`.

---

## 📂 Berkas yang Dibuat / Dimodifikasi

| Lapisan | Berkas | Deskripsi |
| :--- | :--- | :--- |
| **Backend Model** | `backend/lib/models/agenda/agenda.dart` | Superclass abstrak dengan logika OOP durasi menit dan deteksi bentrok jadwal (*conflict check*). |
| **Backend Model** | `backend/lib/models/agenda/course_schedule.dart` | Model kuliah dengan query CRUD MySQL ke tabel `agenda`, `course_schedule`, dan master `course`. Dilengkapi proteksi BOLA/IDOR. |
| **Backend Model** | `backend/lib/models/agenda/personal_schedule.dart` | Model agenda personal dengan query CRUD MySQL ke tabel `agenda` dan `personal_schedule`. Dilengkapi proteksi BOLA/IDOR. |
| **Backend Controller** | `backend/lib/controllers/agenda/agenda_controller.dart` | Controller dengan unified router (`createAgenda`, `updateAgenda`, `deleteAgenda`) dan endpoint khusus per subclass. |
| **Backend Route** | `backend/lib/routes/agenda/agenda_routes.dart` | Routing Shelf di bawah `/api/agenda` terlindungi `checkAuthMiddleware()`. |
| **Frontend Repository** | `frontend/lib/presentation/features/schedule/models/schedule_repository.dart` | Integrasi `ApiClient.get`, `post`, `put`, `delete` langsung ke `/api/agenda` dengan Bearer JWT token. |

---

## 🌐 Endpoint API

- `GET /api/agenda` — Ambil gabungan seluruh agenda (kuliah & personal).
- `POST /api/agenda` — Tambah agenda baru (otomatis mendeteksi tipe Course / Personal).
- `PUT /api/agenda/:idAgenda` — Update agenda terpadu.
- `DELETE /api/agenda/:idAgenda` — Hapus agenda (cascade ke tabel subclass).
- Sub-rute: `/api/agenda/course` dan `/api/agenda/personal`.

