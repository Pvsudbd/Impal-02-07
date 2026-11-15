# Feature Log: Migrasi Driver Backend dari MySQL ke PostgreSQL & Perbaikan Create Schedule (Meeting, Lecture, External)

**Tanggal**: 15 November 2026  
**Penulis**: Antigravity Assistant & Tim Pengembang Impal-02-07 (Yoga Perkasa Didik)  
**Status**: Completed  
**Domain Terkait**: Database Layer, Configuration, PostgreSQL Migration, Agenda & Schedule Module

---

## 1. Latar Belakang & Masalah
Sistem basis data utama TodoList Smart System dimigrasikan dari MySQL lokal (Laragon) ke PostgreSQL remote/server (`172.22.245.175:5432`) dengan database `db_manajemen_tugas`.

Saat pengujian pembuatan jadwal (Meeting, Lecture, dan External), data tidak tersimpan ke database karena beberapa akar masalah:
1. **Lecture (CourseSchedule)**:
   - Query `INSERT INTO course ... ON CONFLICT (course_code) DO NOTHING` melempar error `Severity.error 42P10: there is no unique or exclusion constraint matching the ON CONFLICT specification`. Hal ini terjadi karena tabel `course` di PostgreSQL hasil migrasi belum memiliki constraint `PRIMARY KEY` atau `UNIQUE` pada kolom `course_code`.
   - Di PostgreSQL, tabel `agenda` memiliki kolom `id_student`, sedangkan query mencoba menulis ke `id_user` terlebih dahulu dan query awal gagal fatal sebelum rollback/fallback.
   - Kolom `course_code` bertipe `VARCHAR(20)`. Jika judul mata kuliah panjang digunakan sebagai `courseCode`, terjadi overflow string.
   - Kolom hari (`day`) pada database menggunakan nama Indonesia (`Senin`, `Selasa`, dst.), sementara form frontend mengirimkan nama hari Inggris (`Monday`, `Tuesday`, dst.).
2. **Meeting & External (PersonalSchedule)**:
   - Tipe data `TIME` PostgreSQL (`time without time zone`) dikembalikan oleh driver `package:postgres` sebagai object `Time(HH:MM:SS.mmm)`. Parser `parseTime` lama memecah string dengan `split(':')`, menyebabkan `parts[0]` bernilai `'Time(HH'` sehingga `int.tryParse` gagal dan jam selalu menjadi `00:00`.
   - `PersonalSchedule.toJson()` sebelumnya men-hardcode `'type': 'External'`, sehingga tipe `Meeting` tidak dikenali oleh frontend saat deserialisasi.
   - Controller `createPersonalSchedule` tidak mengklasifikasikan `category` sebagai `Meeting` jika frontend mengirimkan payload generic `type: Meeting`.
   - SQL `start_time`, `end_time`, dan `date` membutuhkan type cast eksplisit (`::time` dan `::date`) untuk parameter prepared statement PostgreSQL.
3. **Frontend `ScheduleRepository`**:
   - `addSchedule` dan `updateSchedule` men-hardcode `category: isCourse ? 'Kuliah' : 'Personal'`, sehingga jadwal `Meeting` kehilangan kategori meeting-nya.
   - Field `meetingUrl` dan `teamName` tidak diteruskan ke body POST/PUT.

---

## 2. Solusi & Rincian Perbaikan

### A. Course Schedule (`backend/lib/models/agenda/course_schedule.dart`)
- Menghapus klausa `ON CONFLICT (course_code) DO NOTHING` dan menggantinya dengan pengecekan aman `SELECT course_code FROM course WHERE course_code = :courseCode LIMIT 1`. Jika belum ada, lakukan `INSERT INTO course`. Pendekatan ini aman dan tidak memerlukan constraint unik khusus.
- Menambahkan sanitasi panjang `courseCode` (maksimal 20 karakter) dan `title` (maksimal 100 karakter).
- Mengarahkan `INSERT INTO agenda` untuk memprioritaskan kolom `id_student` yang ada pada skema PostgreSQL aktif (dengan fallback ke `id_user`).
- Menambahkan fungsi helper `_normalizeDay` untuk mengonversi nama hari bahasa Inggris (`Monday` $\rightarrow$ `Senin`, dst.) secara otomatis.
- Memperbaiki parser `parseTime` dengan Regex `r'(\d{1,2}):(\d{2})'` sehingga mampu mengekstrak jam dan menit dari format `Time(HH:MM:SS.mmm)`, `DateTime`, maupun `String`.

### B. Personal Schedule (`backend/lib/models/agenda/personal_schedule.dart`)
- Memperbaiki parser `parseTime` dan `parseDate` agar kompatibel penuh dengan deserialisasi PostgreSQL `Time` dan `Date`.
- Memperbarui `toJson()` untuk mendeteksi `category` atau `location` yang berkaitan dengan meeting (`category.toLowerCase() == 'meeting'` atau lokasi mengandung `meet`/`zoom`/`team`) sehingga field `type` mengembalikan `'Meeting'`, bukan melulu `'External'`.
- Memprioritaskan kolom `id_student` pada `INSERT INTO agenda` dan menambahkan type casting eksplisit `:startTime::time`, `:endTime::time`, dan `:date::date`.

### C. Agenda Controller (`backend/lib/controllers/agenda/agenda_controller.dart`)
- Pada `createPersonalSchedule`, jika request mengirimkan `type: 'Meeting'`, otomatis menetapkan `category: 'Meeting'`. Jika request mengirimkan `type: 'External'`, menetapkan `category: 'External'`.
- Menjaga fallback `location` ke `body['meetingUrl']` jika `location` tidak diisi.

### D. Frontend Schedule Repository (`frontend/lib/presentation/features/schedule/models/schedule_repository.dart`)
- Memperbaiki pemetaan `category`:
  `'category': isCourse ? 'Kuliah' : (isMeeting ? 'Meeting' : 'External')`.
- Menyertakan `meetingUrl` dan `teamName` ke dalam body request `ApiClient.post` dan `ApiClient.put`.

---

## 3. Hasil Verifikasi Pengujian
Pengujian dijalankan langsung terhadap backend dan database PostgreSQL `172.22.245.175:5432`:
- **Lecture (Kuliah)**: `POST /api/agenda` $\rightarrow$ Status **201 Created**, tersimpan di tabel `agenda` & `course_schedule` dengan hari yang dinormalisasi.
- **Meeting (Rapat)**: `POST /api/agenda` $\rightarrow$ Status **201 Created**, tersimpan di tabel `agenda` & `personal_schedule` dengan kategori `Meeting` dan jam akurat.
- **External (Kegiatan Luar)**: `POST /api/agenda` $\rightarrow$ Status **201 Created**, tersimpan di tabel `agenda` & `personal_schedule` dengan kategori `External` dan jam akurat.
- Record uji coba telah dibersihkan secara otomatis.
