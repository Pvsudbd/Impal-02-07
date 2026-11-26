# 🛡️ Feature Log: Guard Status "Already Joined" pada Alur Join Team

**Tanggal**: 25 November 2026  
**Penanggung Jawab**: Yoga Perkasa Didik (Lead Backend, menangani modul backend `kelompok` sesuai pembaruan `.agents/rules/Agents.md`)  
**Status**: Completed  
**Domain Terkait**: Backend `kelompok` (`GroupController.joinGroup`), Frontend Dialog (`PopUpJoinTeam`)

---

## 1. Latar Belakang & Masalah
Saat pengguna memasukkan `invite_code` pada dialog **Join Team** untuk kelompok yang sudah diikutinya:
1. Di backend (`GroupController.joinGroup`), pengecekan sudah ada terhadap `group_member`, namun belum mengecek apakah `id_leader` di tabel `"groups"` sama dengan `idUser` (celah jika ada data lama di mana leader belum memiliki baris di `group_member`).
2. Di dialog `PopUpJoinTeam` (`frontend/lib/presentation/features/team/pop_up_join_team.dart`), saat user mengetik kode invite tim yang sudah ada di `TeamRepository().teams`, banner malah menampilkan `TEAM FOUND` berwarna hijau dan tombol `Join Workspace Now` tetap aktif (penolakan baru muncul setelah hit API).

---

## 2. Rincian Perubahan

| Lapisan | Berkas | Perubahan |
|---|---|---|
| **Backend Controller** | `backend/lib/controllers/kelompok/group_controller.dart` | Menambahkan pengecekan `idLeader == idUser` sebelum query `group_member` pada `joinGroup`, serta sinkronisasi `group_size` setelah insert ke `group_member`. |
| **Frontend Dialog** | `frontend/lib/presentation/features/team/pop_up_join_team.dart` | Menambahkan `_isAlreadyJoined(code)` terhadap `TeamRepository().teams`, menampilkan banner warning `ALREADY JOINED` (`PopUpPemberitahuan.negativeColor`), menonaktifkan tombol submit saat sudah bergabung, dan menampilkan `PopUpPemberitahuan.teamWarning` bila di-submit via Enter. |

---

## 3. Rujukan Desain & Keamanan (`.agents/cybersecurity.md`)
- Identitas pengguna (`idUser`) tetap diambil eksklusif dari JWT middleware (`_getUserId(req)`), mencegah BOLA/IDOR.
- Query PostgreSQL menggunakan parameterized binding `@idGroup`, `@idUser`.
- String UI dialog 100% berbahasa Inggris dan mematuhi *Strict Sentiment Color Law* (`PopUpPemberitahuan.negativeColor` untuk status warning).

