# 📚 Indeks Aturan & Panduan Desain Modular (Proyek IMPAL)
<!-- Lokasi: .agents/rules/README.md -->

Direktori ini adalah **pusat standarisasi modular (*single source of truth*)** untuk seluruh aturan antarmuka, backend, keamanan, dan navigasi di proyek **IMPAL**. Setiap agen wajib membaca aturan relevan sebelum membuat atau memodifikasi komponen terkait.

---

## 📑 Daftar Aturan Aktif

| Berkas Aturan | Deskripsi & Lingkup Komponen |
| :--- | :--- |
| [backend_dart_frog_rules.md](./backend_dart_frog_rules.md) | Standar Backend Dart Frog, PostgreSQL Connection Pool, Transaksi `runTx`, Tipe Kolom Live DB, Keamanan BOLA/OWASP, & Sinkronisasi Skill. |
| [header_rules.md](./header_rules.md) | Standarisasi Header Halaman, Tombol Back Kotak (`38x38 dp`), Avatar Profil Inisial, dan gap 16 dp. |
| [typography_rules.md](./typography_rules.md) | Skala Font Inter, Tier Ukuran Tombol (Large, Medium, Small, Filter), Sistem Spacing 8-Point Grid, & Top Banner Toast. |
| [ui_language_rules.md](./ui_language_rules.md) | Bahasa UI 100% Bahasa Inggris, Format Hari/Tanggal Kalender, dan Desain `ImpalTimePickerDialog`. |
| [schedule_card_rules.md](./schedule_card_rules.md) | Komponen Kartu `ImpalScheduleCard` (mode horizontal/vertikal), Form Input Jadwal, Scrollable Modal, & Dialog Konfirmasi. |
| [navbar_rules.md](./navbar_rules.md) | Bilah Navigasi Bawah (*Bottom Navigation Bar*), Active Indicator Coral Pill, & Translasi ke Desktop Navigation Rail. |
| [design_tokens.md](./design_tokens.md) | Palet Hex Presisi Dark Mode (`#252932`, `#323846`, `#FA6144`), Layered Shadows, dan Concentric Border Radius. |
| [motion_spec.md](./motion_spec.md) | Protokol Animasi 60 FPS, Durasi 150–350 ms, Shimmer Skeleton Loader, dan Kepatuhan *Reduced Motion*. |
| [security_hardening_rules.md](./security_hardening_rules.md) | Standar Keamanan OWASP Mobile Top 10, Zero Insecure Storage (`flutter_secure_storage`), Anti-SQL Injection, & Proteksi Token. |
| [figcraft_canvas_rules.md](./figcraft_canvas_rules.md) | Inisiasi Day-0 Design System (9 Pilar), Gerbang Persetujuan Skill Desain, & Sinkronisasi Tiga Arah (Figma $\leftrightarrow$ Flutter). |

---

## ⚙️ SOP Pembuatan Rules atau Guide Baru oleh Agen

1. **Lokasi Wajib:** Semua rule baru wajib ditaruh di `.agents/rules/` dengan penamaan snake_case (`[nama_fitur]_rules.md`). Dilarang menaruh rule baru di root proyek.
2. **Pembaruan Indeks:** Setelah membuat berkas rule baru, wajib mendaftarkannya ke tabel di `.agents/rules/README.md` menggunakan relative link (`./nama_file.md`), lalu jalankan `validate_agent_sync.dart`.
