# 🤖 Agent Rules & Guidelines (Workspace Navigation & Feature Implementation)

Dokumen ini berisi instruksi dan batasan wajib bagi AI Agent saat bekerja di repositori **Impal-02-07**.

---

## 1. 📂 Batasan Akses Direktori (Workspace Boundaries)

Agent **HANYA** diperbolehkan mengakses, membaca, mencari, atau memodifikasi berkas di dalam workspace proyek `Impal-02-07/` (serta dokumen pendukung di direktori kerja aktif yang diminta pengguna).

---

## 2. 📐 Aturan Wajib Sebelum Membuat Fitur Baru (New Feature Workflow)

Setiap kali Agent diminta membuat, merancang, atau merefaktor fitur baru:
1. **Rujukan Backend & Live Schema:** Baca `.agents/skills/impal-backend-engineer/SKILL.md` dan `.agents/skills/impal-backend-engineer/references/live_schema_snapshot.md` (atau jalankan `scripts/introspect_schema.dart` untuk mengecek kolom aktual PostgreSQL).
2. **Rujukan Arsitektur Proyek:** Periksa `document/DATABASE_REQUIREMENTS.md` dan `document/DART_FROG_ARCHITECTURE.md` sebagai acuan arsitektur resmi.
3. **Konsultasi Memori Dinamis:** Baca `.agents/memory/project_conventions.md` dan `.agents/memory/anti_patterns.md`.

---

## 3. 🛑 Batasan Operasi Git (Git Restrictions)

- ❌ **DILARANG:** Melakukan `git commit`, `git push`, atau mutasi riwayat Git tanpa instruksi tegas dari pengguna.
- ✅ **DIPERBOLEHKAN:** Perintah read-only seperti `git status`, `git diff`, `git log`, `git branch`.

---

## 4. 🏗️ Standar Framework Backend & Struktur Folder (Dart Frog & PostgreSQL)

1. **Framework Resmi:** Dart Frog (`dart_frog`) + Shelf sub-routers pada port `3000`.
2. **Database:** PostgreSQL (`db_manajemen_tugas`) menggunakan `Database.getPool()` dan `Database.transaction((tx) async { ... })` dari `backend/lib/config/db.dart`.
3. **Standar Response Envelope:**
   ```json
   {
     "status": "success" | "error",
     "message": "Pesan informasi yang jelas",
     "data": {}
   }
   ```
4. **Feature-Based Grouping (`backend/lib/`):**
   - `lib/controllers/<nama_fitur>/`
   - `lib/models/<nama_fitur>/`
   - `lib/routes/<nama_fitur>/`
   - `lib/middleware/<nama_fitur>/` (opsional)
   - Dilarang meletakkan file fitur langsung di root `controllers/`, `models/`, atau `routes/`.

---

## 5. 👥 Pembagian Tugas & Kepemilikan Fitur Tim (Team Feature Ownership)

- **Backend (`Impal-02-07/backend/`):** Pengguna bertanggung jawab menyelesaikan seluruh modul backend (`auth`, `agenda`, `course`, `profile`, `task`, `smart_priority`, `groups`, `notification`, `todo`, `dashboard`).
- **Frontend (`Impal-02-07/frontend/`):**
  - **Pengguna:** `auth`, `schedule`, `profile`.
  - **Habhindra:** `dashboard`, `team`, `task` (jangan diubah UI-nya tanpa izin eksplisit pengguna).

---

## 6. 📝 Pencatatan Riwayat Fitur & Update Skill Wajib

Setiap kali selesai menambah fitur, memperbaiki bug, atau melakukan *security hardening*:
1. Buat atau perbarui log di `.agents/features/<nama_fitur>.md` (tanggal, daftar berkas, rincian teknis, keselarasan schema, verifikasi `.agents/cybersecurity.md`).
2. Jalankan protokol `.agents/skills/sync-project-skills/SKILL.md` dan verifikasi dengan `validate_agent_sync.dart`.
