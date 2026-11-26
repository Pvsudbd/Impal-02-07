# 🌐 Feature Log: Controller & Routing REST API Kelompok & To-Do (Prioritas 3)

**Tanggal**: 17 November 2026  
**Penanggung Jawab Fitur**: Habindra Dzaky Alghifari (103072400095)  
**Status**: Completed  
**Domain Terkait**: Backend REST API, Dart Frog Routing, Kelompok (Groups), Join Team, Meeting Schedule, Todo Items

---

## 1. Latar Belakang & Masalah
Sebelumnya, backend hanya memiliki rute aktif untuk `/api/auth`, `/api/agenda`, dan `/api/profile`. 
Modul kelompok (`groups`), anggota tim (`group_member`), rapat (`meeting_schedule`), tugas kelompok (`group_task`), dan checklist harian (`todo_item`) belum memiliki Controller maupun Route handler di backend, sehingga panggilan dari frontend tidak dapat diproses dan data tidak pernah tersimpan ke PostgreSQL.

---

## 2. Rincian Endpoint yang Diimplementasikan

### A. Modul Kelompok & Tim (`/api/groups` & `/api/team`)
1. **`GET /api/groups`**: Mengambil daftar seluruh kelompok yang dipimpin atau diikuti oleh pengguna aktif (berdasarkan JWT `idUser`).
2. **`POST /api/groups`**: Membuat kelompok baru di tabel `groups` dan otomatis mendaftarkan pembuat sebagai `LEADER` di tabel `group_member`.
3. **`POST /api/groups/join`**: Validasi kode undangan (`invite_code`):
   - Jika kode tidak ada di database PostgreSQL $\rightarrow$ Mengembalikan HTTP 404 *"Invalid team invite code"*.
   - Jika user sudah menjadi anggota $\rightarrow$ Mengembalikan HTTP 400 *"Already a member"*.
   - Jika valid $\rightarrow$ Mendaftarkan user ke `group_member` dengan role `MEMBER` dan mengembalikan HTTP 200 sukses.
4. **`GET /api/groups/<idGroup>`**: Mengambil detail lengkap kelompok, daftar anggota, jadwal rapat, dan tugas kelompok.
5. **`GET/POST /api/groups/<idGroup>/meetings`**: Mengambil dan membuat jadwal rapat kelompok di tabel `meeting_schedule`.
6. **`GET/POST /api/groups/<idGroup>/tasks`**: Mengambil dan membuat tugas tim di tabel `group_task`.

### B. Modul To-Do Item (`/api/todo`)
1. **`GET /api/todo`**: Mengambil to-do item milik pengguna aktif (mendukung query parameter `?date=YYYY-MM-DD`).
2. **`POST /api/todo`**: Membuat item to-do baru di tabel `todo_item`.
3. **`PUT /api/todo/<idItem>/toggle`**: Toggle status selesai (`is_done`) dengan parameter binding aman.
4. **`DELETE /api/todo/<idItem>`**: Menghapus item to-do milik pengguna.

---

## 3. Berkas yang Dibuat & Dimodifikasi

| Lapisan | Berkas | Deskripsi Modifikasi |
|---|---|---|
| **Controller** | `backend/lib/controllers/kelompok/group_controller.dart` | Logika bisnis kelompok, join tim dengan validasi kode, rapat tim, dan tugas tim. |
| **Controller** | `backend/lib/controllers/todo/todo_controller.dart` | Logika bisnis CRUD to-do checklist harian. |
| **Route** | `backend/lib/routes/kelompok/group_routes.dart` | Rute Shelf Router dengan proteksi JWT Middleware `checkAuthMiddleware()`. |
| **Route** | `backend/lib/routes/todo/todo_routes.dart` | Rute To-Do dengan proteksi JWT Middleware. |
| **Server** | `backend/bin/server.dart` | Mounting rute `/api/groups`, `/api/team`, dan `/api/todo` ke dalam pipeline Dart Frog. |

---

## 4. Kepatuhan Keamanan & Standar
- **Zero BOLA / IDOR**: Identitas pengguna diekstraksi dari token JWT (`_getUserId(req)`).
- **Zero SQL Injection**: Seluruh query menggunakan parameterized binding `@param` via `Database.query()`.
