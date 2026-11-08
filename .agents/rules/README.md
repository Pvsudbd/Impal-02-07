# 📚 Indeks Aturan & Panduan Desain Modular (Proyek IMPAL)
<!-- Lokasi: .agents/rules/README.md -->

Direktori ini adalah **pusat standarisasi modular (*single source of truth*)** untuk seluruh aturan antarmuka, desain, navigasi, dan komponen di proyek **IMPAL**. Setiap agen wajib membaca aturan spesifik yang relevan sebelum membuat atau memodifikasi komponen terkait.

---

## 📑 Daftar Aturan Aktif

| Berkas Aturan | Deskripsi & Lingkup Komponen |
| :--- | :--- |
| [header_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/header_rules.md) | Standarisasi Header Halaman, Tombol Back Kotak (`38x38 dp`), Avatar Profil Inisial, dan gap 16 dp. |
| [typography_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/typography_rules.md) | Skala Font Inter, Tier Ukuran Tombol (Large, Medium, Small, Filter), Sistem Spacing 8-Point Grid, & Top Banner Toast. |
| [ui_language_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/ui_language_rules.md) | Bahasa UI 100% Bahasa Inggris, Format Hari/Tanggal Kalender, dan Desain `ImpalTimePickerDialog`. |
| [schedule_card_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/schedule_card_rules.md) | Komponen Kartu `ImpalScheduleCard` (mode horizontal/vertikal), Form Input Jadwal, Scrollable Modal, & Dialog Konfirmasi. |
| [navbar_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/navbar_rules.md) | Bilah Navigasi Bawah (*Bottom Navigation Bar*), Active Indicator Coral Pill, & Translasi ke Desktop Navigation Rail. |
| [design_tokens.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/design_tokens.md) | Palet Hex Presisi Dark Mode (`#252932`, `#323846`, `#FA6144`), Layered Shadows, dan Concentric Border Radius. |
| [motion_spec.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/motion_spec.md) | Protokol Animasi 60 FPS, Durasi 150–350 ms, Shimmer Skeleton Loader, dan Kepatuhan *Reduced Motion*. |
| [security_hardening_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/security_hardening_rules.md) | Standar Keamanan OWASP Mobile Top 10, Zero Insecure Storage (`flutter_secure_storage`), Anti-SQL Injection, & Proteksi Token. |
| [figcraft_canvas_rules.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/figcraft_canvas_rules.md) | Inisiasi Day-0 Design System (9 Pilar), Gerbang Persetujuan Skill Desain, & Sinkronisasi Tiga Arah (Figma $\leftrightarrow$ Flutter). |

---

## ⚙️ SOP Pembuatan Rules atau Guide Baru oleh Agen

Ketika:
1. **Pengguna meminta membuat aturan/guide baru** (misal: *"buatkan rule untuk pop-up form"*, *"buatkan guide filter tim"*), ATAU
2. **Agen menyadari adanya pola desain/rekayasa baru yang berulang** dan membutuhkan standardisasi tertulis:

### 📌 Aturan Peletakan Berkas Wajib:
1. **LOKASI WAJIB:** Semua rule baru **WAJIB ditaruh di direktori `.agents/rules/`** dengan format penamaan snake_case:  
   `📂 .agents/rules/[nama_fitur]_rules.md`
2. **LARANGAN ROOT:** **DILARANG** menaruh berkas rules baru langsung di root folder proyek (`/`). Folder root hanya untuk `AGENTS.md`, `README.md`, `ROADMAP_AUDIT_DAN_PENINGKATAN.md`, dan `README_FRONTEND.md`.
3. **STRUKTUR ISI MINIMAL DOKUMEN RULE:**
   - Judul & Path Berkas (`# [Nama Komponen] Rules & Implementation Guide`).
   - Prinsip Utama & Komponen Template Bersama yang digunakan.
   - Tabel Spesifikasi Dimensi, Padding, Spacing, & Tipografi.
   - Interaksi, Tap Target (min 48×48 dp), & Matriks 5 State.
   - Larangan Khusus (*Anti-Patterns*).
4. **PEMBARUAN INDEKS:** Setelah membuat berkas rule baru, agen **WAJIB mendaftarkan berkas tersebut ke dalam tabel di `.agents/rules/README.md` ini**.
