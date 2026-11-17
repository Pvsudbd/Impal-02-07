# Frontend Team API Integration (Prioritas 4)

## Ringkasan Fitur
- **Nama Fitur**: Integrasi Frontend Team (Join Team & Create Team) dengan Backend API PostgreSQL
- **Tanggal**: 17 November 2026
- **Status**: Completed & Verified (`dart analyze`: 0 Error, 0 Warning)

---

## Masalah Sebelumnya
Sebelum integrasi ini, fungsi **Join Team** dan **Create Team** di halaman `team_list_page.dart` hanya menjalankan mock lokal (in-memory):
- Pengguna yang memasukkan kode acak apa pun (misal: "tes tes test") langsung mendapatkan pop-up `"Successfully joined team with code 'tes tes test'"` tanpa divalidasi ke database.
- Pembuatan tim baru (*Create Team*) hanya menambahkan objek ke memory lokal tanpa tersimpan permanen di database PostgreSQL.

---

## Perubahan Teknis yang Dilakukan

### 1. `frontend/lib/presentation/features/team/models/team_model.dart`
- Menambahkan field `inviteCode` dan `description`.
- Menambahkan factory constructor `TeamModel.fromMap(Map<String, dynamic> map)` untuk memetakan data JSON dari backend (`id_group`, `group_name`, `invite_code`, `description`, `member_count`).
- Menambahkan method `toMap()`.

### 2. `frontend/lib/presentation/features/team/models/team_repository.dart`
- Menambahkan `fetchTeamsFromApi()`:
  - Mengambil daftar kelompok nyata dari endpoint `GET /api/groups` menggunakan JWT Bearer Token pengguna yang sedang login.
  - Memperbarui list tim `_teams` dan memicu `teamsNotifier`.
- Menambahkan `joinTeamApi(String inviteCode)`:
  - Mengirim request `POST /api/groups/join` dengan payload `{'invite_code': inviteCode}`.
  - Memvalidasi respons: jika sukses (200), menyisipkan tim baru dan memperbarui list tim.
  - Jika gagal (404/400), mengembalikan pesan kesalahan dari backend.
- Menambahkan `createTeamApi({required String name, String? description, String? inviteCode})`:
  - Mengirim request `POST /api/groups` ke backend untuk menyimpan tim ke tabel `groups` dan mendaftarkan pembuat sebagai `LEADER` di `group_member`.

### 3. `frontend/lib/presentation/features/team/team_list_page.dart`
- Pada `_showJoinTeamDialog`:
  - Menggantikan eksekusi mock dengan pemanggilan `TeamRepository().joinTeamApi(trimmedCode)`.
  - Jika backend mengembalikan status `'error'`, menampilkan notifikasi peringatan:
    `PopUpPemberitahuan.teamWarning(context, title: 'Join Team Failed', message: errorMsg);`
  - Hanya menampilkan notifikasi sukses jika API mengembalikan respons berhasil.
- Pada `_showCreateTeamDialog`:
  - Menggantikan mock in-memory dengan pemanggilan `TeamRepository().createTeamApi(...)`.
  - Menampilkan notifikasi error jika gagal dan notifikasi sukses jika berhasil dibuat di PostgreSQL.
- Pada `initState()`:
  - Memanggil `TeamRepository().fetchTeamsFromApi()` saat halaman dibuka agar daftar tim selalu sinkron dengan database.

---

## Verifikasi Kualitas
- **Kompilasi & Analisis Statis**: `dart analyze` $\rightarrow$ **0 Error, 0 Warning (No issues found!)**.
- **Kepatuhan UI & Desain**: Menggunakan komponen baku `PopUpPemberitahuan.teamWarning` (Coral `#FA6144`) dan `PopUpPemberitahuan.teamJoined` (Green `#10B981`) sesuai pedoman studio `AGENTS.md`.
