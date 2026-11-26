# Feature Log: Prioritas 2A — Modul Tim / Kelompok (`/api/groups`)

**Tanggal**: 26 November 2026  
**Penulis**: Antigravity Assistant & Yoga Perkasa Didik  
**Status**: Completed  
**Domain Terkait**: `groups`, `group_member`, `group_milestone`, `group_task`, `group_sub_task`, `meeting_schedule`

---

## 1. Daftar Berkas yang Dibuat / Dimodifikasi

### Backend (`Impal-02-07/backend/`)
- `lib/models/kelompok/group_repository.dart` — Repository terpusat mencakup 6 tabel tim (`"groups"`, `group_member`, `group_milestone`, `group_task`, `group_sub_task`, `meeting_schedule`) dengan proteksi keanggotaan `_requireMembership`, pembatasan role `LEADER` vs `MEMBER`, penegakan kepemilikan penyelesaian tugas (`id_assigned_to` / `LEADER`), auto-Fuzzy pada `group_task`, serta penghapusan berjenjang *child-first* anti-orphan saat `disbandGroup`, `deleteGroupTask`, `deleteMilestone`, dan `leaveGroup`.
- `lib/controllers/group/group_controller.dart` — Controller HTTP REST dengan validasi panjang string (`groupName <= 100`, `title <= 150`, `meetingTitle/platformLocation <= 100`), validasi `gradeWeight` (`0..100`), `priority` (`HIGH|MEDIUM|LOW`), dan pemetaan error bersih (`400`/`403`/`404`/`409`) tanpa membocorkan `e.toString()`.
- `lib/routes/group/group_routes.dart` — Router `/api/groups` terlindungi penuh oleh `checkAuthMiddleware()`.
- `bin/server.dart` & `routes/index.dart` — Mounting `/api/groups`.
- `test/groups_test.dart` — Integration test end-to-end 3 user (Leader, Member, Outsider) ke PostgreSQL live yang menguji create/join, BOLA, milestones + `progressPercent`, group tasks + auto-Fuzzy + pembatasan complete, subtasks, meetings, leave, dan orphan-free disband di seluruh 6 tabel.

---

## 2. Verifikasi Keamanan & Mutu
- Seluruh query kelompok wajib lolos `_requireMembership` (pengguna non-anggota mendapat `403 Forbidden`).
- Aksi ubah/bubarkan kelompok hanya diizinkan untuk `LEADER`; penyelesaian `group_task`/`group_sub_task` yang sudah di-assign hanya diizinkan oleh assignee atau `LEADER`.
- Nama tabel `"groups"` selalu di-quote agar aman dari reserved keyword PostgreSQL.
