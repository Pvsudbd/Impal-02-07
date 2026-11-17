# 📝 Feature Log: Task Overdue Detection & Fuzzy Priority Guard

**Tanggal**: 17 November 2026  
**Penanggung Jawab Fitur**: Habindra Dzaky Alghifari (103072400095)  
**Status**: Completed & Verified  
**Domain Terkait**: Task Management, Overdue Dialog Warning, Fuzzy Priority Logic, Team Tasks

---

## 1. Latar Belakang & Masalah
Sebelumnya, ketika pengguna membuat tugas personal maupun tugas kelompok dengan deadline yang sudah lewat di masa lalu (misal: kemarin atau sebulan lalu):
1. Sistem menerima tugas tersebut tanpa peringatan apa pun.
2. Tugas yang kadaluarsa tetap diproses oleh Smart Priority Engine (AI Fuzzy Mamdani) dan diberi estimasi durasi normal (misal: `12h`/`24h`).
3. Pada halaman Task Page, tab filter 'Overdue' tidak memfilter tugas berdasarkan deadline riil, melainkan hanya placeholder priority High.

---

## 2. Solusi Rekayasa yang Diterapkan
1. **Dialog Konfirmasi Overdue (`PopUpOverdueTaskDialog`)**:
   - Jika `deadlineDateTime.isBefore(DateTime.now())`, sistem memunculkan dialog konfirmasi berdesain dark container `#323846` dengan badge jam coral `#FA6144`.
   - Menjelaskan bahwa deadline telah terlewat dan memberikan 2 opsi:
     - **Change Date**: Membatalkan submit agar user dapat mengubah tanggal deadline.
     - **Proceed as Overdue**: Menerima pembuatan tugas tetapi dengan status **Overdue**, durasi badge `Overdue` (warna Coral `#FFFF7D65`), dan mematikan pembobotan otomatis fuzzy (`isAutomaticWeight = false`, `centroidDefuzzification = 'N/A (Overdue)'`).
2. **Perlindungan Logika Fuzzy di Backend (`backend/lib/models/task/task.dart`)**:
   - Menambahkan getter `isOverdue => _deadline.isBefore(DateTime.now())`.
   - Pada method `updateFuzzyPriority()`, jika tugas telah overdue, skor prioritas diatur ke `0.0`, prioritas `LOW`, dan `isFuzzyAuto = false`.
3. **Filter Tab Overdue Akurat (`task_page.dart`)**:
   - Filter 'Overdue' kini menyaring tugas yang benar-benar memiliki status overdue (`t.isOverdue || t.durationBadge.toLowerCase() == 'overdue'`).
4. **Dukungan Dual-Mode Form**:
   - Berlaku untuk pembuatan tugas baru (*Add Task*), pengeditan tugas (*Edit Task*), serta tugas kelompok (*Create Task Team*).

---

## 3. Berkas yang Dibuat & Dimodifikasi

| Lapisan | Berkas | Deskripsi Modifikasi |
|---|---|---|
| **UI Dialog** | `frontend/lib/presentation/features/task/widgets/pop_up_overdue_task_dialog.dart` | Dialog konfirmasi peringatan tanggal terlewat dengan opsi *Change Date* atau *Proceed as Overdue*. |
| **Presentation** | `frontend/lib/presentation/features/task/create_task.dart` | Validasi tanggal deadline di masa lalu sebelum submit, integrasi dialog konfirmasi, dan setting atribut Overdue/bypassed fuzzy. |
| **Presentation** | `frontend/lib/presentation/features/team/create_task_team.dart` | Validasi tanggal deadline di masa lalu untuk tugas kelompok tim. |
| **Presentation** | `frontend/lib/presentation/features/task/task_page.dart` | Perbaikan filter tab 'Overdue' menggunakan `isOverdue`. |
| **Model** | `frontend/lib/presentation/features/task/models/task_item_model.dart` | Menambahkan getter `isOverdue` berdasarkan tanggal deadline & duration badge. |
| **Backend Model** | `backend/lib/models/task/task.dart` | Guarding method `updateFuzzyPriority` untuk menonaktifkan kalkulasi fuzzy pada tugas overdue. |
