# 🛡️ Panduan & Standar Cybersecurity Proyek (Security Baseline Guide)
<!-- Lokasi File: .agents/cybersecurity.md -->
<!-- Diadaptasi dari: https://github.com/briiirussell/cybersecurity-skills -->

Dokumen ini merupakan panduan dan standar baku keamanan siber (*cybersecurity standards*) yang disintesis dan disesuaikan khusus untuk arsitektur proyek **Smart System Todolist** (Frontend Flutter, Backend Dart Shelf REST API, dan Basis Data MySQL 8.0/Laragon).

Dokumen ini diadopsi dari repositori keahlian keamanan agen AI **`briiirussell/cybersecurity-skills`**, mencakup domain inti:
1. **API Security Audit** (`api-audit` — OWASP API Security Top 10)
2. **Application Security Audit** (`owasp-audit` — OWASP Top 10)
3. **Secrets & Credentials Audit** (`secrets-audit`)
4. **Mobile & Client Security Audit** (`mobile-audit` — OWASP MASVS)
5. **Dependency & Supply Chain Audit** (`dependency-audit`)

---

## 1. 🌐 API Security Audit (`api-audit` — OWASP API Top 10)

Fokus pada pengamanan endpoint REST API backend Dart Shelf (`/api/auth`, `/api/agenda`, `/api/profile`, `/api/student`):

### 1.1 Pencegahan BOLA / IDOR (Broken Object Level Authorization — API1:2023)
* **Aturan Mutlak:** Identitas pengguna (`id_student`) **WAJIB** diekstraksi secara eksklusif dari token JWT yang telah diverifikasi di `request.context['student']['idStudent']`.
* ❌ **DILARANG KERAS:** Mengambil `id_student` dari parameter URL (`/api/student/:id`) atau body JSON klien untuk menentukan data siapa yang diakses/diubah.
* **Verifikasi Objek:** Saat memperbarui atau menghapus entitas anak (misal: agenda, tugas), pastikan klausul `WHERE` selalu menyertakan `AND id_student = :idStudent`:
  ```sql
  -- BENAR: Mencegah user A menghapus agenda milik user B
  DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_student = :idStudent;
  ```

### 1.2 Broken Authentication & Manajemen Token (API2:2023)
* **Hashing Password:** Password **WAJIB** di-hash menggunakan algoritma **BCrypt** dengan salt (`BCrypt.hashpw(password, BCrypt.gensalt())`). Dilarang menyimpan password plain-text atau hash lemah (MD5/SHA1).
* **Verifikasi JWT:**
  - Token JWT ditandatangani menggunakan `SecretKey` dari `Database.jwtSecret`.
  - Token memiliki masa kedaluwarsa eksplisit (`expiresIn: const Duration(days: 7)`).
  - Middleware `checkAuthMiddleware()` wajib menolak request jika format bukan `Bearer <token>` atau token sudah kedaluwarsa (HTTP 401/403).

### 1.3 Pencegahan Mass Assignment (API3:2023)
* ❌ **DILARANG:** Memasukkan seluruh `request.body` langsung ke dalam query database.
* ✅ **WAJIB:** Menggunakan mekanisme *whitelisting* eksplisit pada atribut yang boleh diubah pengguna.
  - Field yang boleh diubah di profil: `name`, `email`.
  - Field yang **DILARANG** diubah lewat update biasa: `id_student`, `password_hash`, `role`, `created_at`.

### 1.4 Pengendalian Konsumsi Sumber Daya (API4:2023)
* **Request Timeout:** Klien HTTP di frontend wajib menerapkan timeout request maksimal 15 detik (`requestTimeout = Duration(seconds: 15)`).
* **Validasi Ukuran Payload:** Body request wajib dicek agar tidak kosong dan panjang input string dibatasi sesuai batas kolom MySQL (misal: judul agenda maks 150 karakter).

### 1.5 Security Misconfiguration & Pencegahan Kebocoran Informasi (API8:2023)
* **Konfigurasi CORS:** Header CORS hanya mengizinkan metode yang digunakan: `GET, POST, PUT, DELETE, OPTIONS`.
* **Sanitasi Error Response:**
  - Di level production, jangan pernah mengembalikan pesan error mentah database (misal: SQL syntax error atau database credentials) langsung ke response JSON klien.
  - Berikan pesan umum deskriptif: `{"status": "error", "message": "Terjadi kesalahan server."}`.

---

## 2. 🛡️ Application Security & Code Audit (`owasp-audit`)

### 2.1 Pencegahan SQL Injection (A03:2021 — Injection)
* ❌ **DILARANG KERAS (VULNERABLE):**
  ```dart
  // DILARANG: String concatenation atau interpolasi langsung ke query SQL
  final sql = "SELECT * FROM student WHERE email = '$email'";
  ```
* ✅ **WAJIB (SECURE):**
  Menggunakan **Parameterized Queries / Prepared Statements**:
  ```dart
  // BENAR: Menggunakan parameter binding yang aman
  final results = await Database.query(
    'SELECT * FROM student WHERE email = :email LIMIT 1',
    {'email': email},
  );
  ```

### 2.2 Pencegahan Broken Access Control (A01:2021)
* Seluruh endpoint yang memanipulasi data pribadi (Jadwal, Profil, Tugas, Kelompok) **WAJIB** dibungkus oleh `Pipeline().addMiddleware(checkAuthMiddleware())`.
* Endpoint publik **HANYA** diperbolehkan untuk rute autentikasi awal:
  - `POST /api/auth/login`
  - `POST /api/auth/register`
  - `GET /` (Health check)

### 2.3 Validasi & Sanitasi Input
* **Email:** Wajib divalidasi format RFC 5322 sebelum diproses.
* **Password:** Minimal 6 karakter, tidak boleh mengandung spasi kosong.
* **Sanitasi String:** Gunakan `.trim()` untuk memotong whitespace di awal dan akhir teks input.

---

## 3. 🔑 Secrets & Credential Management (`secrets-audit`)

### 3.1 Isolasi Berkas Konfigurasi Sensitif
* **Kunci Rahasia & Password Database:**
  - Seluruh kredensial (`DB_PASSWORD`, `JWT_SECRET`, `DB_HOST`, `DB_USER`) **WAJIB** disimpan dalam file `.env` di folder backend.
  - File `.env` **DILARANG KERAS** di-commit ke Git remote (wajib terdaftar di `.gitignore`).
  - Sediakan file template `.env.example` yang hanya berisi nama key tanpa nilai rahasia produksi.

### 3.2 Pembersihan Log & Debugging
* ❌ **DILARANG:** Menuliskan `print()` atau `debugPrint()` yang mencetak data sensitif seperti password plain text, token JWT lengkap, atau connection string database ke terminal/console.
* ✅ Sanitasi log: Jika perlu mencatat identifier untuk debugging, cukup gunakan ID atau inisial (`[AUTH] Login attempt for user ID: $idStudent`).

---

## 4. 📱 Client & Mobile Security (`mobile-audit` — OWASP MASVS)

Panduan keamanan untuk lapisan Flutter Client:

### 4.1 Penyimpanan Sesi Lokal (Insecure Storage Mitigation)
* **Penyimpanan Token:**
  - Token otentikasi disimpan di `SharedPreferences` lokal dengan key `auth_token`.
  - Jika aplikasi ditingkatkan ke level *High Security Production*, migrasikan penyimpanan token ke `flutter_secure_storage` (menggunakan Keychain di iOS dan EncryptedSharedPreferences di Android).
* **Pembersihan Sesi saat Sign Out:**
  - Saat pengguna menekan "Sign Out", aplikasi **WAJIB** menghapus seluruh data sesi lokal (`is_logged_in`, `auth_token`, `auth_user`).

### 4.2 Anti Double-Submit & Form Replay
* Tombol interaktif submit form (Login, Tambah Jadwal, Edit Profil) wajib memiliki indikator `_isLoading` / `_isSubmitting` dan otomatis menonaktifkan callback `onTap: _isLoading ? null : _handleSubmit` untuk mencegah duplikasi request dan serangan brute force lokal.

---

## 5. 📦 Dependency & Supply Chain Audit (`dependency-audit`)

### 5.1 Integritas Paket Dependensi
* Seluruh paket di `backend/pubspec.yaml` dan `frontend/pubspec.yaml` harus menggunakan versi yang stabil dan terpercaya:
  - Backend: `shelf`, `shelf_router`, `mysql_client`, `dart_jsonwebtoken`, `bcrypt`, `uuid`, `dotenv`.
  - Frontend: `http`, `shared_preferences`, `intl`.
* Jalankan audit dependensi berkala melalui terminal:
  ```powershell
  # Cek dependensi usang atau bermasalah
  dart pub outdated
  ```

---

## ✅ Checklist Verifikasi Keamanan Sebelum Rilis Fitur (Security Verification Gate)

Sebelum menandai fitur baru selesai, verifikasi item berikut:
- [ ] Apakah seluruh query database menggunakan parameter binding (`:paramName`), **tanpa** string concat?
- [ ] Apakah endpoint yang dibuat dilindungi oleh `checkAuthMiddleware()`?
- [ ] Apakah `id_student` diambil dari JWT payload dan bukan dari body/parameter URL klien?
- [ ] Apakah password baru di-hash menggunakan BCrypt sebelum disimpan ke MySQL?
- [ ] Apakah tidak ada file `.env`, kredensial, atau token rahasia yang ter-stage di Git?
- [ ] Apakah tombol form di Flutter menerapkan penonaktifan state saat loading?
- [ ] Apakah response error tidak membocorkan stack trace mentah ke pengguna?

