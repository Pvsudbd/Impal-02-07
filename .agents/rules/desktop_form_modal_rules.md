# Desktop Form Modal & Mobile Wording Parity Rules
<!-- Lokasi Resmi: .agents/rules/desktop_form_modal_rules.md -->

## 1. Tujuan & Lingkup Penggunaan
Aturan ini mengikat seluruh modal/dialog formulir Desktop (`>= 1024 dp`) maupun modal terpadu Mobile–Desktop pada proyek **IMPAL**:
- `DesktopPersonalTaskModal` (`features/task/widgets/desktop/desktop_personal_task_modal.dart`)
- `DesktopScheduleModal` (`features/schedule/widgets/desktop/desktop_schedule_modal.dart`)
- `DesktopTeamTaskModal` (`features/team/widgets/desktop/desktop_team_task_modal.dart`)
- `DesktopTeamMeetingModal` (`features/team/widgets/desktop/desktop_team_meeting_modal.dart`)
- `PopUpJoinTeam` & `PopUpCreateTeam` (`features/team/`)
- `DesktopEditProfileModal` & `DesktopChangePasswordModal` (`features/profile/widgets/desktop/desktop_profile_modals.dart`)

---

## 2. Hukum Paritas Wording & Header Mobile (Strict Mobile Parity Law)

1. **Dilarang Menambah Subtitle Ekstra di Bawah Judul Modal:**
   - Jika halaman/modal versi **Mobile** tidak menampilkan teks deskriptif/subjudul di bawah judul utama, maka modal **Desktop** juga **DILARANG KERAS** menambahkan kalimat subjudul dari FigCraft (contoh: jangan tambahkan *"Add a weekly lecture..."*, *"Team Task Details"*, *"Meeting Details"*, atau kalimat penjelasan di bawah judul).
   - Header modal cukup menampilkan judul utama (`Add Schedule`, `Create Task`, `Create Team Task`, `Create Meeting`, `Join Team`, `Create Team`, `Edit Profile`, `Change Password`) + kontrol kanan atas (`Alert On`/`Alert Off` bila relevan & tombol `[✕]`).

2. **Kata-Kata & Subjudul Bagian Wajib Mengikuti Mobile Secara Persis:**
   - Dilarang mengganti istilah mobile dengan istilah baru dari FigCraft:
     - **Schedule (`DesktopScheduleModal`):** `Schedule Type` (`Lecture`, `Meeting`, `External`), `Course` / `Meeting Title` / `Schedule Title`, `Location / Room`, `Date` (`d MMM yyyy`, **tanpa kotak hari terpisah**), **`Time Duration`** (dua kotak jam `HH:mm` dengan pemisah `-`, tanpa prefix `Start:`/`End:` dan tanpa badge `Duration (Valid)` tambahan), **`Repeat Weekly`** (satu baris switch tanpa teks tambahan), `Meeting Link / URL (Optional)`, `Notes (Optional)`, CTA `Create Schedule` / `Create Meeting` / `Save Changes`.
     - **Personal Task (`DesktopPersonalTaskModal`):** `Task Category` (`College Task`, `Personal`), `Task Title`, `Course`, `Submission Deadline`, `Task Grade Weight` (`Automatic` menyembunyikan `High`/`Medium`/`Low`), `Notes & Instructions`.
     - **Team Task (`DesktopTeamTaskModal`):** `Task Name`, `Description`, `Submission Deadline`, `Assign To`, `Milestone (Optional)` (**tanpa** `Course/Task Grade Weight`).
     - **Team Meeting (`DesktopTeamMeetingModal` & `PopUpCreateMeeting`):** `Meeting Name`, `Location`, `Date & Time`, `Start Time`, `End Time (Estimated)`, `Repeat Weekly`, `Meeting Link / URL (Optional)`, `Description (Optional)`. Ketika dibuka dari **`DashboardTeamPage`** (`showTeamMeetingOption: false`), checkbox & pemilih `Team Meeting` otomatis disembunyikan baik di Mobile maupun Desktop.
     - **Join & Create Team:** `Join Team` (4 kotak persegi 1:1 rata tengah + lookup dinamis `TEAM FOUND` / `TEAM NOT FOUND` saat 4 karakter terisi), `Create Team` (`Team Name`, `Description (Optional)`, `Team Invite Code` dengan `[↻ Generate New]` di kanan judul dan tombol salin **ikon murni**).

3. **Title Case & 100% Bahasa Inggris (Dilarang ALL-CAPS):**
   - Seluruh label field, judul bagian, dan teks tombol wajib menggunakan **Title Case Bahasa Inggris** sesuai versi mobile (misal: `Time Duration`, `Full Name`, `Current Password`), **DILARANG** menyalin teks **FULL KAPITAL** (`COURSE NAME`, `TIME SLOT`, `NAMA LENGKAP`, `CURRENT PASSWORD`) atau Bahasa Indonesia dari FigCraft.

---

## 3. Spesifikasi UI, Interaksi & Anti-Patterns

- **Quick Dismiss Tanpa Tombol `Cancel` Redundan:** Gunakan tombol `[✕]` di pojok kanan atas untuk menutup modal; **dilarang** menampilkan tombol `Cancel` di pojok kiri bawah modal form yang sudah memiliki `[✕]`. Mode Edit menampilkan `[Delete ...]` di kiri + `[Save Changes]` di kanan; mode Create menampilkan tombol CTA full-width.
- **Unfocus Sebelum Menutup Modal:** Selalu panggil `FocusManager.instance.primaryFocus?.unfocus();` sebelum `Navigator.of(context).pop()` agar tidak memicu *white flash* pada Flutter Web.
- **Border Fokus Adaptif:** `border` dan `enabledBorder` menggunakan `AppColors.borderSubtle` (`#3B4150`); border hanya berubah oranye (`AppColors.primary` / `#FA6144`) saat `focusedBorder` (ditekan/aktif).
- **Zero Overflow (`Row` Headers):** Seluruh label teks di dalam `Row` header form wajib dibungkus `Expanded` atau `Flexible(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))`.
