# 🤖 Agent Rules & Guidelines (Workspace Navigation & Feature Implementation)

Dokumen ini berisi instruksi dan batasan wajib bagi AI Agent saat bekerja di repositori ini.

---

## 1. 📂 Batasan Akses Direktori (Workspace Boundaries)

Saat bekerja di dalam direktori induk `D:\Telkom University\Semester 5`, Agent **HANYA** diperbolehkan mengakses, membaca, mencari, atau memodifikasi file pada dua folder berikut:
- ✅ `D:\Telkom University\Semester 5\TodoList` (Source code proyek aplikasi Frontend & Backend)
- ✅ `D:\Telkom University\Semester 5\Impal` (Dokumentasi Tugas Besar, Diagram UML, SKPL, ERD)

⚠️ **LARANGAN KERAS (STRICT RESTRICTION):**
- **DILARANG** mengakses, membaca, mencari (`search_dir`, `grep_search`, `list_dir`, `view_file`, dll.), ataupun memodifikasi folder dan file lain di luar folder `Impal` dan `TodoList` di direktori `D:\Telkom University\Semester 5` (misalnya folder mata kuliah lain atau berkas pribadi).

---

## 2. 📐 Aturan Wajib Sebelum Membuat Fitur Baru (New Feature Workflow)

Setiap kali Agent diminta untuk membuat, merancang, atau merefactor fitur baru (baik di sisi Frontend Flutter maupun Backend), Agent **WAJIB** membaca dan mematuhi dokumentasi arsitektur resmi terlebih dahulu:

### A. Rujukan Class Diagram (Struktur Kelas & OOP)
- **Lokasi File**: `D:\Telkom University\Semester 5\Impal\ImpalTB\Impal\Tubes\02_Diagram_dan_Model\Class_Diagram.md`
- **Fungsi & Kewajiban**:
  - Wajib memeriksa nama class, nama atribut (lengkap dengan tipe data & access modifier), dan signature method (parameter & return type).
  - Wajib mengikuti kaidah relasi antar-kelas (Inheritance/Generalization, Composition, Association, Dependency) sesuai diagram resmi.

### B. Rujukan ERD & Skema Database (Physical Schema & MySQL)
- **Lokasi File**: `D:\Telkom University\Semester 5\Impal\ImpalTB\Impal\Tubes\02_Diagram_dan_Model\Entity_Relationship_Diagram.md`
- **Fungsi & Kewajiban**:
  - Wajib memeriksa struktur nama tabel, nama kolom, tipe data SQL, Foreign Key, dan relasi fisik (misal: Class Table Inheritance pada `agenda`, `course_schedule`, `personal_schedule`).

---

## 3. 🎯 Prinsip Konsistensi & Integritas Dokumen

1. **Single Source of Truth**:
   - Selalu jadikan `Class_Diagram.md` dan `Entity_Relationship_Diagram.md` di folder `02_Diagram_dan_Model` sebagai satu-satunya rujukan utama.
   - **JANGAN PERNAH** menggunakan file usang / arsip lama (seperti `CDlama.md` di folder `vault/`).
2. **Validasi Desain Sebelum Implementasi**:
   - Pastikan entitas model, DTO, atau query database yang dibuat di kode selaras 100% dengan apa yang didefinisikan pada Class Diagram dan ERD.

---

## 4. 🛑 Batasan Operasi Git (Git Restrictions)

Demi menjaga keamanan dan riwayat version control proyek:
- ❌ **DILARANG KERAS (FORBIDDEN)**:
  - Melakukan `git commit` atau `git push` ke GitHub/remote repository secara mandiri/otomatis.
  - Memodifikasi riwayat commit atau melakukan operasi mutasi Git tanpa instruksi tegas dari pengguna.
- ✅ **DIPERBOLEHKAN (READ-ONLY INSPECTION)**:
  - Perintah git yang bersifat pemeriksaan status / observasi lokal, seperti `git status`, `git diff`, `git log`, `git branch`, dan sejenisnya.

---

## 5. 🏗️ Konvensi Struktur Folder Backend (Feature-Based Folder Grouping)

Ketika mengimplementasikan atau menambahkan fitur baru di backend (`backend/lib/`), Agent **WAJIB** mengorganisasi file ke dalam subfolder bernama fitur tersebut di setiap layernya agar terstruktur, rapi, dan mudah dirawat:
- `lib/controllers/<nama_fitur>/`
- `lib/models/<nama_fitur>/`
- `lib/routes/<nama_fitur>/`
- `lib/middleware/<nama_fitur>/` (jika fitur membutuhkan middleware khusus)
- `lib/config/<nama_fitur>/` (jika ada konfigurasi spesifik fitur)

**Contoh Implementasi:**
Jika membuat fitur bernama `makan` (sebagaimana pola yang sudah diterapkan pada `auth`, `agenda`, `kelompok`, `task`):
```text
backend/lib/
├── controllers/
│   └── makan/
│       └── makan_controller.dart
├── models/
│   └── makan/
│       └── makan_model.dart
├── routes/
│   └── makan/
│       └── makan_routes.dart
└── middleware/
    └── makan/ (opsional jika dibutuhkan)
```

⚠️ **LARANGAN:** Jangan pernah meletakkan file langsung di root `controllers/`, `models/`, atau `routes/` tanpa dibungkus subfolder nama fiturnya.



