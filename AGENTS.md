# AGENTS.md — Konfigurasi Agen Full-Stack IMPAL (Flutter + Dart Frog + PostgreSQL)

> **Prinsip Utama:** *Caution over speed* — hindari asumsi sepihak, pangkas overengineering, lakukan perubahan bedah (*surgical*), dan verifikasi setiap hasil sebelum menyerahkan kode.

---

## 👥 Pembagian Tugas & Kepemilikan Fitur Tim (Feature Ownership)

- **Backend (`Impal-02-07/backend/` — Tanggung Jawab Penuh Pengguna):**
  Seluruh modul backend (`auth`, `agenda`, `course`, `profile`, `task`, `smart_priority`, `groups`, `notification`, `todo`, `dashboard`) adalah ruang lingkup resmi Backend Engineer.
- **Frontend (`Impal-02-07/frontend/` — Pembagian Kapling UI):**
  - **Pengguna:** Autentikasi (`auth`), Jadwal (`schedule`), Profil (`profile`).
  - **Habhindra:** Dashboard (`dashboard`), Kelompok (`team`), Tugas (`task`).
  - ⚠️ Pada sisi Frontend, fokus pada modul Pengguna dan jangan merombak UI milik Habhindra tanpa instruksi eksplisit dari pengguna.

---

## 📝 Pencatatan Perubahan & Sinkronisasi Skill Wajib

1. **Feature Log (`.agents/features/<nama_fitur>.md`):** Setiap fitur baru, bugfix, atau hardening wajib dicatat (tanggal, berkas diubah, rincian teknis, keselarasan schema/ERD, dan audit `.agents/cybersecurity.md`).
2. **Workspace Skills Sync (`.agents/skills/sync-project-skills/SKILL.md`):** Setiap perubahan backend atau skema database wajib menjalankan siklus sinkronisasi skill (`introspect_schema.dart` + update rules/memory/feature log + `validate_agent_sync.dart`).

---

## 🧠 4 Pilar Perilaku Karpathy dalam Rekayasa IMPAL

1. **Think Before Coding:** Wajib membaca `.agents/memory/anti_patterns.md` dan `.agents/memory/project_conventions.md` sebelum mulai. Nyatakan asumsi & tradeoff performa secara eksplisit; tanya pengguna jika kontrak API atau desain ambigu.
2. **Simplicity First:** Utamakan *Pure UI First* di Flutter dan kode minimal di backend; dilarang menambah fitur spekulatif atau abstraksi prematur untuk komponen sekali pakai.
3. **Surgical Changes:** Ubah hanya baris yang relevan. Dilarang *drive-by refactoring* (merapikan whitespace acak, mengubah gaya widget tetangga, atau menghapus komentar lama yang tidak terkait). Bersihkan orphan variable/import akibat perubahan sendiri.
4. **Goal-Driven Execution:** Ubah perintah menjadi target verifikasi terukur (`dart analyze` = 0 error/warning, `dart test` lulus, multi-viewport 320dp–1280dp bebas overflow).

---

## 👥 Ekosistem Subagent Produksi

| Layer | Peran & Fokus |
| :--- | :--- |
| **Design & UX** | `ui-art-director` (anti-slop, token FigCraft [figcraft_canvas_rules.md](.agents/rules/figcraft_canvas_rules.md)), UX Architect (Matriks 5 State, Thumb Zone, microcopy). |
| **Presentation & Motion** | Senior Flutter Builder (Pure UI, `ResponsiveContext`, Desktop Adaptive), Motion Animator (60 FPS, `Transform`/`Opacity`, *reduced motion*). |
| **Data & Backend** | Backend Dart Frog Engineer ([SKILL.md](.agents/skills/impal-backend-engineer/SKILL.md)), State & Offline-First Architect (Isar DB + sync queue). |
| **QA, Test & AppSec** | Flutter QA Inspector (`dart analyze`, zero overflow), Test Specialist (`WidgetTester`), Profiler (heap < 150 MB), AppSec Auditor ([security_hardening_rules.md](.agents/rules/security_hardening_rules.md)). |

---

## 1. Konvensi Arsitektur & Performa Frontend (HP Kentang 60 FPS)

- **Feature-First & Pure UI:** Pisahkan UI (`StatelessWidget` + callback) dari state/API. Gunakan [design_tokens.md](.agents/rules/design_tokens.md), [typography_rules.md](.agents/rules/typography_rules.md), [header_rules.md](.agents/rules/header_rules.md), [navbar_rules.md](.agents/rules/navbar_rules.md), dan [motion_spec.md](.agents/rules/motion_spec.md).
- **Responsivitas Mutlak:** Dilarang hardcoded pixel. Wajib `context.rFont`, `context.rSpacing`, `context.rIcon`, `context.rLogo`, ikon SVG (`flutter_svg`), dan tap target minimal **48×48 dp**.
- **5 Aturan Emas 60 FPS:** Konstruktor `const`, `cacheWidth`/`cacheHeight` pada bitmap, `ListView.builder`/`SliverList` untuk > 20 item, hindari `BackdropFilter` berat (pakai *flat opacity*), dan isolasi animasi dengan `RepaintBoundary`.
- **Standar UX & Formulir:** Matriks 5 State (Ideal, Empty, Shimmer, Error Recovery, Offline), no-paste-blocking, tombol loading tetap menampilkan label teks, `FocusScope.of(context).unfocus()`, anti double-submit, `FontFeature.tabularFigures()` pada jam/angka, dan `r_inner = r_outer - padding`.
- **Standar Kartu & Pop-Up:** Lihat detail di [schedule_card_rules.md](.agents/rules/schedule_card_rules.md), [ui_language_rules.md](.agents/rules/ui_language_rules.md), dan `.agents/memory/project_conventions.md` (100% English UI untuk pop-up, positif `#10B981`, negatif/peringatan `#FA6144`).
- **Desktop ($\ge 1024$ dp):** BottomNav $\rightarrow$ `NavigationRail` (240–280 dp), List $\rightarrow$ Master-Detail Split View (panel kiri 380 dp), BottomSheet $\rightarrow$ Centered Dialog (max 520 dp), Pull-to-refresh $\rightarrow$ Explicit Refresh Button.
- **Protokol Retrofit 3 Langkah:** Audit Gap $\rightarrow$ Micro-Refactoring Terfokus $\rightarrow$ Test Lockdown (`dart analyze` 0 error/warning).

---

## 2. Protokol Backend Dart Frog, PostgreSQL & Update Skill Agent

### A. Standar Teknis Backend (`Impal-02-07/backend/`)
- **Framework & Runtime:** Dart Frog + Shelf sub-routers pada `PORT=3000` (Android Emulator `http://10.0.2.2:3000`, Web/Desktop `http://localhost:3000`).
- **Database:** PostgreSQL (`db_manajemen_tugas`) via `Database.getPool()` (`Pool.withEndpoints`) dan `Database.transaction((tx) async { ... })` di `backend/lib/config/db.dart`. Kredensial & `JWT_SECRET` wajib dari `.env` (dilarang hardcode).
- **Format Envelope JSON Baku:**
  ```json
  { "status": "success" | "error", "message": "...", "data": {} }
  ```
- **Keamanan (`.agents/cybersecurity.md` & [backend_dart_frog_rules.md](.agents/rules/backend_dart_frog_rules.md)):**
  - Semua rute privat dilindungi `checkAuthMiddleware()` (`Authorization: Bearer <jwt>`).
  - BOLA/IDOR protection: ambil `idUser` eksklusif dari JWT context, bukan dari URL/body.
  - Parameterized query `:param` / `Sql.named` mutlak; sanitasi semua pesan error HTTP (jangan bocorkan `e.toString()`).

### B. Sistem Skills & Mekanisme Update Pengetahuan Agent (`.agents/skills/`)
Proyek ini menggunakan **Workspace Skills** resmi Antigravity agar pengetahuan skema DB dan kontrak API tidak usang:
1. **[impal-backend-engineer](.agents/skills/impal-backend-engineer/SKILL.md):** Runbook backend Dart Frog, snapshot skema live 16 tabel ([live_schema_snapshot.md](.agents/skills/impal-backend-engineer/references/live_schema_snapshot.md)), dan skrip introspeksi langsung PostgreSQL (`scripts/introspect_schema.dart`).
2. **[sync-project-skills](.agents/skills/sync-project-skills/SKILL.md):** Protokol wajib setelah perubahan backend/skema DB:
   - Jalankan `introspect_schema.dart --write` jika struktur tabel PostgreSQL berubah.
   - Perbarui skill, `.agents/rules/backend_dart_frog_rules.md`, `.agents/memory/*`, `.agents/features/*`, dan `ROADMAP_AUDIT_DAN_PENINGKATAN.md`.
   - Validasi dengan `dart run ../.agents/skills/sync-project-skills/scripts/validate_agent_sync.dart` dari `backend/`.

---

## 3. Siklus Koreksi Mandiri, Self-Authoring Rules & Konsensus

1. **Verifikasi Sebelum Selesai:** `dart analyze` (0 Error, 0 Warning), `dart test` lulus, `validate_agent_sync.dart` lulus, serta perbarui `ROADMAP_AUDIT_DAN_PENINGKATAN.md`.
2. **Aturan Penempatan Dokumen:** Dilarang membuat file rule baru di root proyek. Simpan rule baru di `.agents/rules/<nama>_rules.md` dan daftarkan di [.agents/rules/README.md](.agents/rules/README.md).
3. **Konsensus Maker vs Checker:** Tidak ada perubahan yang dianggap selesai sebelum QA (`dart analyze` + test pass) dan AppSec (`.agents/cybersecurity.md`) terpenuhi. Keamanan dan stabilitas selalu diprioritaskan.
