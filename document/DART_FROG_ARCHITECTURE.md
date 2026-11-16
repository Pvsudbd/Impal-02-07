# Dokumentasi Arsitektur Backend Dart Frog & PostgreSQL

**Dokumen**: DART_FROG_ARCHITECTURE.md  
**Project**: Impal-02-07 TodoList Smart System  
**Penanggung Jawab Backend**: Yoga Perkasa Didik (103072400106)  
**Framework**: Dart Frog (`package:dart_frog: ^1.2.6`)  
**Database**: PostgreSQL 15+ (`package:postgres: ^3.6.0`)  

---

## 1. Pendahuluan

Sistem Backend Impal-02-07 mengadopsi framework **Dart Frog**. Dart Frog adalah framework server-side modern untuk bahasa pemrograman Dart yang dikembangkan oleh Very Good Ventures. Pemilihan Dart Frog memastikan:
1. **Unifikasi Bahasa (Full-stack Dart)**: Tim pengembang menggunakan bahasa Dart baik pada sisi frontend (Flutter) maupun backend, meminimalkan *context-switching* dan memudahkan *code sharing* tipe data / model.
2. **Kinerja Tinggi & Asynchronous I/O**: Memanfaatkan engine Dart async non-blocking berbasis *event loop* yang sangat cepat dan hemat konsumsi memori.
3. **Pemisahan Peran Tegas**:
   - **Frontend Caching (Isar DB)**: Dikelola oleh Habindra untuk kebutuhan local storage offline-first di aplikasi Android/Web.
   - **Backend Remote API (Dart Frog & PostgreSQL)**: Dikelola oleh Yoga Perkasa Didik untuk authentication, sinkronisasi jadwal, agregasi data kalender, dan persistensi terpusat. Keduanya saling berkomunikasi menggunakan protokol HTTP REST API standar berformat JSON.

---

## 2. Cara Kerja Dart Frog

### 2.1 Konsep Inti

1. **`RequestContext`**:
   Setiap permintaan HTTP yang masuk dibungkus dalam objek `RequestContext`. Objek ini menyediakan:
   - Akses data permintaan (`context.request`).
   - Akses layanan dependensi (`context.read<T>()`).
   - Penyisipan metadata antar middleware (`context.provide<T>()`).

2. **`Response.json(...)`**:
   Dart Frog menyederhanakan pengiriman balasan JSON. Alih-alih melakukan serialisasi manual dan menetapkan header manual, `Response.json(body: ...)` secara otomatis melakukan serialisasi data dan menyematkan header `Content-Type: application/json; charset=utf-8`.

3. **Dependency Injection via `provider<T>`**:
   Koneksi PostgreSQL atau konfigurasi database diinjeksi pada tingkat *middleware* menggunakan fungsi `provider<Database>()`. Hal ini membuat *route handler* dan *controller* bersifat *loosely coupled* dan mudah diuji.

4. **Pipeline & Middleware Chaining**:
   Permintaan HTTP dieksekusi secara berurutan melalui *pipeline*:
   - **CORS Middleware**: Mengizinkan akses origin silang (`Access-Control-Allow-Origin: *`) dan menangani preflight request `OPTIONS`.
   - **Request Logger**: Mencatat metode HTTP, rute URL, status kode respon, dan durasi eksekusi.
   - **Database Provider**: Menjamin instance database siap digunakan di setiap handler.
   - **Sub-Router Handlers**: Menyalurkan request ke controller yang relevan (`/api/auth`, `/api/agenda`, `/api/profile`).

---

## 3. Alur Komunikasi Client-Server & Database

```text
+-----------------------+
|  Frontend (Flutter)   |
|  (Client / Isar DB)   |
+-----------+-----------+
            |
            | HTTP / REST (JSON)
            v
+-------------------------------------------------------+
|                 Backend (Dart Frog)                   |
|                                                       |
|  1. Server Port 3000 (package:dart_frog serve)        |
|  2. Middleware (CORS, Logger, DatabaseProvider)       |
|  3. Router:                                           |
|     - /api/auth   -> AuthController                   |
|     - /api/agenda -> AgendaController                 |
|     - /api/profile-> ProfileController                |
+---------------------------+---------------------------+
                            |
                            | TCP Socket (SQL Query)
                            v
            +-------------------------------+
            |     Remote PostgreSQL DB      |
            |       (10.147.115.231)        |
            +-------------------------------+
```

---

## 4. Cara Menjalankan Server Backend

Pastikan dependensi telah terinstal:
```bash
cd backend
dart pub get
```

Jalankan server Dart Frog:
```bash
dart run bin/server.dart
```

Server akan aktif dan siap menerima request pada `http://localhost:3000`.

### Verifikasi Cepat (Health Check):
- **Cek Status Server**: Buka `http://localhost:3000/` di browser atau kirim request GET via Postman/curl.
- **Cek Koneksi Database**: Buka `http://localhost:3000/test-db`.
- **Cek Tabel Database**: Buka `http://localhost:3000/tables`.
- **Header Verifikasi**: Setiap respon menyertakan header `X-Powered-By: Dart with package:dart_frog`.

