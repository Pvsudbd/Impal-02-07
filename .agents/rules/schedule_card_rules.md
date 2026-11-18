# IMPAL Schedule Card & Form Rules

Aturan baku ini mendefinisikan standar visual, arsitektur komponen, urutan form, perilaku scroll, serta konfirmasi dan notifikasi untuk seluruh fitur jadwal (Schedule & Meeting) di aplikasi IMPAL Smart ToDoList.

---

## 1. Arsitektur Komponen Template

Semua tampilan kartu jadwal di IMPAL WAJIB menggunakan komponen bersama di [impal_schedule_card.dart](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/impal_schedule_card.dart):
1. **`ImpalScheduleCard`**: Widget kartu tunggal yang mendukung layout vertikal (`double.infinity`) maupun horizontal carousel (`width: 285`).
2. **`ImpalHorizontalScheduleList`**: Container horizontal scroll yang secara otomatis memposisikan viewport pada kartu **Ongoing**.

DILARANG membuat duplikasi implementasi kartu jadwal manual di dalam halaman (`DashboardTeamPage`, `TeamListPage`, `HomePage`, `SchedulePage`).

---

## 2. Standar Visual & Desain Token Kartu

Setiap kartu jadwal harus mematuhi token desain Figma IMPAL:
- **Card Background**: `#323846` (`Color(0xFF323846)`).
- **Border Radius**: 12px (`BorderRadius.circular(12)`).
- **Card Shadow**: `BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3))`.
- **Left Accent Stripe**: Lebar 5px, warna dinamis sesuai kategori/tipe:
  - Lecture: `#FF7D65` / `#FF826E` (Coral)
  - Meeting: `#4A90E2` / `#6C5CE7` (Blue/Indigo)
  - External / Lainnya: `#38EF7D` / `#F5A623` (Green/Amber)
- **Judul**: Maksimal 1 baris (ellipsis), Inter 14px bold, teks warna putih (`Colors.white`).
- **Badge Status Pill**:
  - `Ongoing`: Background Coral `#FF826E`, teks putih Inter 9.5px semi-bold.
  - `Overdue`: Background Gray `#8E95A5` (alpha 15%), border `#8E95A5` (alpha 35%), teks gray `#8E95A5` Inter 9.5px semi-bold.
  - `Upcoming`: Background Gray `#8E95A5` (alpha 15%), border `#8E95A5` (alpha 35%), teks gray `#8E95A5` Inter 9.5px semi-bold.
- **Lokasi (Location / Room)**: Inter 11px medium `#8E95A5`, maksimal 1 baris (ellipsis).
- **Waktu & Jam**:
  - Ikon jam (`Icons.access_time_filled_rounded`, size 10) di dalam lingkaran berlatar `accentColor.withValues(alpha: 0.2)`.
  - Teks waktu format: `HH:mm - HH:mm WIB` (Inter 11px medium `#8E95A5`).
- **Quick Action Buttons**:
  - Edit: `Icons.edit_outlined`, warna `#8E95A5`, size 15.
  - Delete: `Icons.delete_outline_rounded`, warna Coral `#FA6144`, size 15.

---

## 3. Aturan Navigasi & Scroll Horizontal (Team's Schedule & Home)

Pada carousel horizontal jadwal (`team_list_page.dart`, `dashboard_team_page.dart`, dan `home_page.dart`):
1. **Urutan data di memori**:
   ```
   [ ...Overdue Items, ...Ongoing Items, ...Upcoming Items ]
   ```
   Masing-masing kelompok diurutkan kronologis berdasarkan `startDateTime`.
2. **Fokus Utama Viewport**:
   - `ImpalHorizontalScheduleList` otomatis melakukan auto-scroll menuju kartu **Ongoing** pertama.
   - Jika tidak ada Ongoing, auto-scroll menuju kartu **Upcoming** pertama.
3. **Arah Interaksi Scroll**:
   - Scroll ke **KIRI** untuk melihat jadwal yang sudah lewat / **Overdue**.
   - Scroll ke **KANAN** untuk melihat jadwal yang akan datang / **Upcoming**.

---

## 4. Aturan Tampilan Vertikal (Schedule Page)

Pada halaman utama jadwal vertikal (`schedule_page.dart`):
1. **Grup Tanggal**:
   - Hari kemarin / lampau di bagian **ATAS** (scroll ke atas untuk melihat tanggal sebelumnya).
   - Hari ini (**Today**) berada di posisi tengah/fokus awal.
   - Hari esok / mendatang di bagian **BAWAH** (scroll ke bawah untuk melihat tanggal berikutnya).
2. **Urutan Item dalam Satu Hari**:
   ```
   [Overdue (Paling Atas) -> Ongoing (Tengah) -> Upcoming (Paling Bawah)]
   ```

---

## 5. Urutan Standar Form Schedule (Create & Edit)

Pada `ScheduleFormPage`, urutan field harus logis dan terstruktur sebagai berikut:
1. **Schedule Type Selector** (Lecture / External)
2. **Course Name / Schedule Title** (Input text wajib)
3. **Location / Room** (Input text opsional)
4. **Date Picker** (**SELALU DITAMPILKAN**, baik `Repeat Weekly` aktif maupun tidak)
5. **Time Duration** (Start Time dan End Time pickers)
6. **Repeat Weekly Switch** (Pengulangan mingguan)
7. **Notes** (Textarea catatan opsional)
8. **Action Buttons**: Add Schedule / Save Changes (+ Delete Schedule jika mode Edit)

> **Catatan Penting**: Pemilihan `Repeat Weekly` tidak boleh menyembunyikan Date picker, karena tanggal awal / pertemuan pertama tetap perlu dicatat dan disimpan ke repository.

---

## 6. Aturan Pop-up Konfirmasi Hapus & Pemberitahuan

Setiap tindakan penghapusan atau perubahan jadwal WAJIB memiliki alur konfirmasi dan feedback visual:

### A. Konfirmasi Hapus
- **Schedule**:
  - Title: `'Delete Schedule?'`
  - Message: `'Are you sure you want to delete this schedule? This action cannot be undone.'`
- **Meeting**:
  - Title: `'Delete Meeting?'`
  - Message: `'Are you sure you want to delete this meeting? This action cannot be undone.'`
  - Dialog widget: `PopUpKonfirmasiDelete.show(context, title: ..., message: ...)`

### B. Notifikasi Feedback (PopUpPemberitahuan)
- **Create Schedule**: `PopUpPemberitahuan.scheduleCreated(context)` (Badge Hijau)
- **Edit Schedule**: `PopUpPemberitahuan.scheduleUpdated(context)` (Badge Hijau)
- **Delete Schedule**: `PopUpPemberitahuan.scheduleDeleted(context)` (Badge Coral `#FA6144`)
- **Create Meeting**: `PopUpPemberitahuan.meetingCreated(context)` (Badge Hijau)
- **Edit Meeting**: `PopUpPemberitahuan.meetingUpdated(context)` (Badge Hijau)
- **Delete Meeting**: `PopUpPemberitahuan.meetingDeleted(context)` (Badge Coral `#FA6144`)
