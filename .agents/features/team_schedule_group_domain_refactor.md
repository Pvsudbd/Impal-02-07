# Refactoring: Team's Schedule Group Domain Separation

## 1. Background & Root Cause
Sebelumnya, widget `Team's Schedule` di *Team Dashboard* (baik Mobile maupun Desktop) membaca data dari `ScheduleRepository.schedulesNotifier` yang merupakan domain jadwal kuliah dan agenda personal (`/api/agenda`).
Hal ini menyebabkan:
- Terjadi pencampuran antara agenda pribadi dan rapat kelompok.
- Filter meeting mengandalkan string pattern matching (`meet`, `discord`, `group`) terhadap seluruh agenda personal.
- Respon dari endpoint personal `/api/agenda` tidak memiliki properti `teamName`, sehingga data `teamName` pada jadwal kelompok sempat ter-reset menjadi `null` dan menyebabkannya hilang dari tampilan.

## 2. Solusi Arsitektur
Memisahkan domain rapat kelompok sepenuhnya ke **domain Kelompok (Team / Group)**:
1. **Repository**: Menambahkan state `Map<String, List<ScheduleModel>> _teamMeetings` ke `TeamTaskRepository` dengan method:
   - `getMeetings(teamCode)`
   - `fetchMeetingsFromApi(teamCode, {targetTeamName})` -> `GET /api/groups/<teamCode>/meetings`
   - `addMeeting(teamCode, meeting)` -> `POST /api/groups/<teamCode>/meetings`
   - `updateMeeting(teamCode, meeting)` -> `PUT /api/groups/<teamCode>/meetings/<idMeeting>`
   - `deleteMeeting(teamCode, idMeeting)` -> `DELETE /api/groups/<teamCode>/meetings/<idMeeting>`
2. **Backend**:
   - Mendaftarkan endpoint PUT dan DELETE di `group_routes.dart` (`/<idGroup>/meetings/<idMeeting>`).
   - `GroupController.createMeeting`, `updateMeeting`, `deleteMeeting`, dan `getGroupMeetings` terintegrasi dengan tabel `meeting_schedule` di remote PostgreSQL.
3. **Frontend UI**:
   - `DashboardTeamPage`: Memanggil `fetchMeetingsFromApi` saat `initState` dan `didUpdateWidget`, serta meneruskan daftar meeting kelompok langsung ke widget anak.
   - `DesktopGroupWorkspaceView`: Mengamati `TeamTaskRepository()` secara reaktif untuk merender `DesktopTeamScheduleBanner`.
   - `TeamScheduleSection` (Mobile): Menggunakan meeting dari kelompok aktif dan menampilkan empty state jika kelompok belum memiliki rapat.
   - `PopUpCreateMeeting` & `DesktopTeamMeetingModal`: Saat `teamNameValue` ada, langsung memanggil `TeamTaskRepository().addMeeting/updateMeeting/deleteMeeting`.

