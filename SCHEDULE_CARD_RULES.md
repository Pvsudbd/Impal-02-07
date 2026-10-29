# IMPAL Schedule Card & Form Rules

Dokumen ini mendefinisikan aturan dan panduan implementasi untuk seluruh komponen kartu jadwal (Schedule & Meeting), form input, urutan scroll, konfirmasi dialog, dan toast pemberitahuan di proyek IMPAL.

---

## 1. Komponen Template Bersama

Lokasi berkas template: [impal_schedule_card.dart](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/impal_schedule_card.dart)

### `ImpalScheduleCard`
Komponen kartu serbaguna yang digunakan di:
- **`SchedulePage`** (mode vertikal, `isHorizontal: false`)
- **`HomePage`** (mode horizontal carousel & single card)
- **`DashboardTeamPage`** (mode horizontal Team's Schedule)
- **`TeamListPage`** (mode horizontal Team's Schedule)

**Parameter Utama:**
- `schedule`: Model data `ScheduleModel`.
- `isHorizontal`: Boolean mode horizontal (lebar tetap 285px) atau vertikal (`double.infinity`).
- `onTap`: Callback ketika kartu disentuh.
- `onEdit`: Callback tombol ikon edit (`Icons.edit_outlined`).
- `onDelete`: Callback tombol ikon hapus (`Icons.delete_outline_rounded`).
- `customTimeText`: Formatter waktu kustom (opsional).

### `ImpalHorizontalScheduleList`
Container scroll horizontal otomatis yang memposisikan kartu **Ongoing** di tengah/awal pandangan pengguna.
- Otomatis menghitung `targetIndex` kartu `Ongoing`.
- Jika tidak ada `Ongoing`, memfokuskan kartu `Upcoming` pertama.
- Pengguna dapat menggulir ke **kiri** untuk melihat jadwal lampau (**Overdue**) dan ke **kanan** untuk jadwal mendatang (**Upcoming**).

---

## 2. Standar Desain Token & Visual

| Properti | Nilai Token | Keterangan |
| :--- | :--- | :--- |
| **Card Background** | `#323846` | Warna kartu latar gelap IMPAL |
| **Border Radius** | `12px` | Sudut membulat standar |
| **Left Accent Bar** | `5px width` | Warna aksen kategori (`schedule.accentColor`) |
| **Title Typography** | Inter 14px, Bold, `#FFFFFF` | Maksimal 1 baris (ellipsis) |
| **Badge Ongoing** | Background `#FF826E`, Teks `#FFFFFF` | Inter 9.5px, Semi-Bold |
| **Badge Overdue** | Bg `#8E95A5` 15%, Border 35%, Teks `#8E95A5` | Inter 9.5px, Semi-Bold |
| **Badge Upcoming** | Bg `#8E95A5` 15%, Border 35%, Teks `#8E95A5` | Inter 9.5px, Semi-Bold |
| **Location** | Inter 11px, Medium, `#8E95A5` | Menampilkan lokasi / ruangan |
| **Time Format** | `HH:mm - HH:mm WIB` | Ikon jam + teks Inter 11px |
| **Edit Icon** | `#8E95A5`, size 15 | `Icons.edit_outlined` |
| **Delete Icon** | `#FA6144`, size 15 | `Icons.delete_outline_rounded` |

---

## 3. Urutan Field Form Schedule (Create & Edit)

Di [schedule_form_page.dart](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/jadwal/schedule_form_page.dart):
1. **Schedule Type** (Lecture / External)
2. **Course / Schedule Title** (Input text wajib)
3. **Location / Room** (Input text opsional)
4. **Date Picker** (**Selalu tampil** baik Repeat Weekly aktif maupun tidak)
5. **Time Duration** (Start Time dan End Time pickers)
6. **Repeat Weekly Switch** (Pengulangan mingguan)
7. **Notes** (Textarea opsional)
8. **Action Buttons**: Add Schedule / Save Changes (+ Delete Schedule bila isEdit)

---

## 4. Alur Konfirmasi Hapus & Pemberitahuan

### Konfirmasi Hapus ([pop_up_konfirmasi_delete.dart](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/features/jadwal/pop_up_konfirmasi_delete.dart))
- **Schedule**: Judul `'Delete Schedule?'`
- **Meeting**: Judul `'Delete Meeting?'`, pesan `'Are you sure you want to delete this meeting? This action cannot be undone.'`

### Notifikasi Feedback ([pop_up_pemberitahuan.dart](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/pop_up_pemberitahuan.dart))
- **Meeting Created**: `PopUpPemberitahuan.meetingCreated(context)` (Pemberitahuan Berhasil - Hijau)
- **Meeting Updated**: `PopUpPemberitahuan.meetingUpdated(context)` (Pemberitahuan Berhasil - Hijau)
- **Meeting Deleted**: `PopUpPemberitahuan.meetingDeleted(context)` (Pemberitahuan Dihapus - Coral `#FA6144`)
- **Schedule Deleted**: `PopUpPemberitahuan.scheduleDeleted(context)`
