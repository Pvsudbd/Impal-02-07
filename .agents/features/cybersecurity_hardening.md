# 🛡️ Fitur: Cybersecurity Hardening (Penguatan Keamanan Sistem)
<!-- Lokasi File: .agents/features/cybersecurity_hardening.md -->

Dokumentasi audit dan perbaikan celah keamanan (*vulnerability hardening*) pada codebase backend dan frontend sesuai standar [briiirussell/cybersecurity-skills](https://github.com/briiirussell/cybersecurity-skills).

---

## 📅 Tanggal & Waktu Terakhir Diperbarui
- **Waktu**: 2026-11-08 (Sprint 2 - IMPAL)
- **Status**: Selesai Diaudit & Diproteksi

---

## 📂 Berkas yang Dimodifikasi & Diperkuat

| Lapisan | Berkas | Jenis Hardening |
| :--- | :--- | :--- |
| **Backend Model** | `backend/lib/models/agenda/course_schedule.dart` | **BOLA / IDOR Mitigation**: Validasi kepemilikan agenda mahasiswa sebelum eksekusi update + subquery scope checking. |
| **Backend Model** | `backend/lib/models/agenda/personal_schedule.dart` | **BOLA / IDOR Mitigation**: Validasi kepemilikan agenda mahasiswa sebelum eksekusi update + subquery scope checking. |
| **Backend Model** | `backend/lib/models/profile/profile_model.dart` | **Data Integrity & Validation**: Pengecekan keunikan email sebelum update untuk mencegah tabrakan akun mahasiswa. |
| **Backend Controller** | `backend/lib/controllers/auth/auth_controller.dart` | **Information Leakage**: Penghapusan kebocoran `detail: e.toString()` dari response HTTP ke klien. |
| **Backend Controller** | `backend/lib/controllers/profile/profile_controller.dart` | **Information Leakage & Mass Assignment**: Sanitasi output error dan whitelisting ketat field body input. |
| **Backend Server** | `backend/bin/server.dart` | **Information Leakage**: Sanitasi endpoint `/test-db` agar tidak membocorkan error driver database. |
| **Frontend Network** | `frontend/lib/core/network/api_client.dart` | **Resource Consumption / DoS Protection**: Penambahan batas waktu request 15 detik (`.timeout(requestTimeout)`) pada semua pemanggilan HTTP statis (`get`, `post`, `put`, `delete`) dan penghapusan deklarasi duplikat `requestTimeout`. |
| **Frontend UI** | `frontend/lib/presentation/features/profile/profile_page.dart` | **Insecure Storage Mitigation**: Pembersihan total token sesi (`auth_token`, `jwt_token`, `auth_user`, `is_logged_in`) saat Sign Out. |
| **Frontend UI** | `frontend/lib/presentation/features/dashboard/widgets/home_header.dart` | **Insecure Storage Mitigation**: Pembersihan total token sesi saat Sign Out dari header avatar. |
| **Git Config** | `.gitignore` | **Secrets Protection**: Menambahkan rule eksplisit `backend/.env` dan `backend/.dart_tool/`. |

---

## 🛡️ Checklist Kepatuhan Standar (.agents/cybersecurity.md)
- [x] **OWASP API1:2023 (BOLA)**: Tidak ada endpoint atau model update/delete yang mengizinkan manipulasi tanpa mencocokkan `id_student` dari JWT.
- [x] **OWASP API3:2023 (Mass Assignment)**: Validasi whitelist ketat pada atribut entitas.
- [x] **OWASP API4:2023 (Resource Consumption)**: Request timeout 15 detik pada HTTP client Flutter.
- [x] **OWASP A03:2021 (Injection)**: 100% query database menggunakan parameter binding (`:paramName`).
- [x] **OWASP A05:2021 (Security Misconfiguration)**: Pesan error produksi tidak mengekspos exception/stack trace mentah.
- [x] **OWASP MASVS (Mobile Storage)**: Menghilangkan risiko lingering session token di storage lokal saat pengguna logout.

