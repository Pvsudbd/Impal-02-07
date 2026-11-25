# 🗄️ Feature Log: Penambahan Kolom `group_size` (Opsi A — Jumlah Anggota Aktual)

**Tanggal**: 25 November 2026  
**Penanggung Jawab**: Yoga Perkasa Didik (Lead Backend & Database)  
**Status**: Dokumentasi & Skema Isar Selesai (Eksekusi SQL PostgreSQL dijalankan oleh Yoga; `build_runner` Isar siap dijalankan)  
**Domain Terkait**: PostgreSQL Schema, Isar DB Local Storage, ERD, Activity Diagram, Class Diagram, Database Requirements

---

## 1. Latar Belakang & Keputusan Desain
Tabel `"groups"` pada PostgreSQL (`db_manajemen_tugas`) sudah memiliki data, namun belum memiliki kolom `group_size`. Dipilih **Opsi A**:
- `group_size` menyimpan **jumlah anggota aktual** pada kelompok (minimal `1`), di-*backfill* dari `COUNT(*)` pada tabel `group_member` dan dijaga $\ge 1$ dengan constraint `CHECK (group_size >= 1)`.

---

## 2. Berkas yang Dibuat & Dimodifikasi

| Lapisan | Berkas | Ringkasan Perubahan |
|---|---|---|
| **Isar DB Collection** | `frontend/lib/data/local/collections/group_collection.dart` | Membuat skema `GroupCollection` (`remoteId`, `idLeader`, `groupName`, `description`, `inviteCode`, `groupSize`, `createdAt`, plus metadata sync `updatedAt`, `isSynced`, `syncAction`). |
| **Isar DB Service** | `frontend/lib/data/local/isar_service.dart` | Mendaftarkan `GroupCollectionSchema` pada `Isar.open` dan menambahkan helper `groupCol`, `getAllGroups`, `watchGroups`, `getGroupByRemoteId`, `saveGroup`, `saveGroups`, `updateGroupSize`, dan `deleteGroupByRemoteId`. |
| **Database Spec** | `document/DATABASE_REQUIREMENTS.md` | Menambahkan contoh skema `GroupCollection` dan kolom `group_size INT NOT NULL DEFAULT 1 CHECK (group_size >= 1)` pada DDL PostgreSQL tabel `groups`. |
| **ERD** | `Impal/Tubes/02_Diagram_dan_Model/Entity_Relationship_Diagram.md` | Menambahkan atribut `group_size` pada Mermaid `GROUPS`, Kamus Data Bagian `4.9`, dan SQL DDL `CREATE TABLE groups`. |
| **Activity Diagram** | `Impal/Tubes/02_Diagram_dan_Model/Activity_Diagram.md` | Menyelaraskan Sub-bab `4.3.6` (Create Group inisialisasi `group_size = 1`, Join Group update `group_size = COUNT(*)`). |
| **Class Diagram** | `Impal/Tubes/02_Diagram_dan_Model/Class_Diagram.md` | Menambahkan `-Int groupSize` pada class `Group` (Mermaid & PlantUML). |

---

## 3. Rujukan Desain & Keamanan (`.agents/cybersecurity.md`)
- Seluruh perubahan skema mengacu pada [Entity_Relationship_Diagram.md](file:///d:/Telkom%20University/Semester%205/Impal/ImpalTB/Impal/Tubes/02_Diagram_dan_Model/Entity_Relationship_Diagram.md) dan [DATABASE_REQUIREMENTS.md](file:///d:/Telkom%20University/Semester%205/TodoList/Impal-02-07/document/DATABASE_REQUIREMENTS.md).
- Tidak ada kredensial, password hash, atau token JWT yang disimpan di `GroupCollection` Isar DB.
- Backend modul `kelompok` milik Habindra tidak dimodifikasi tanpa izin eksplisit.

