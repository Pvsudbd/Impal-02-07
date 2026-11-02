# 🚫 Memory: Anti-Patterns & Hal yang Dilarang (Proyek IMPAL)
<!-- Berkas ini merekam anti-pattern yang pernah dikoreksi dan wajib dihindari oleh semua agen -->

### 1. Tata Letak & Responsivitas
- **DILARANG KERAS** menggunakan angka mati (hardcoded pixel) untuk font, padding/spacing, icon, atau banner. Wajib menggunakan `context.rFont`, `context.rSpacing`, `context.rIcon`, dan `context.rLogo`.
- **DILARANG KERAS** menggunakan `BackdropFilter` blur GPU berat di HP Kentang. Wajib menggunakan warna semi-transparan datar (*flat opacity*).
- **DILARANG** meletakkan `Column` tanpa batas tinggi di dalam `Dialog` atau `BottomSheet` yang menyebabkan layout error (*unbounded vertical viewport*).
- **DILARANG** menggunakan `SingleChildScrollView + Column` untuk daftar data > 20 item. Wajib gunakan `ListView.builder` atau `SliverList`.

### 2. Badge & Kartu Tugas
- **DILARANG** membuat kontainer `Stack` kartu tugas tanpa `width: double.infinity`. Jika kontainer menyusut (*shrink-wrap*), badge akan menempel pada judul yang pendek (*anti-clustering violation*).
- **DILARANG** membiarkan teks judul kartu tugas menabrak badge di sudut kanan atas. Kolom judul wajib memiliki `padding/margin` kanan minimal 104–120 dp.

### 3. Formulir & Interaksi
- **DILARANG** memblokir fitur *paste* (tempel teks/OTP) pada `TextField`.
- **DILARANG** menghilangkan label teks pada tombol proses (*loading button*). Label teks wajib tetap terlihat di samping spinner.
- **DILARANG** membiarkan keyboard tetap terbuka saat user mengetuk area di luar form. Wajib pasang `FocusScope.of(context).unfocus()`.
- **DILARANG** membiarkan tombol submit bisa ditekan berkali-kali (*double submit*).

### 4. Perilaku Coding & Refactoring
- **DILARANG KERAS Drive-by Refactoring:** Mengubah gaya kode tetangga, memformat ulang whitespace file secara acak, menghapus komentar lama, atau mengubah urutan import yang tidak relevan.
- **DILARANG Spekulatif:** Menambahkan fitur yang tidak diminta, membuat generic abstract base widget untuk single-use component, atau membuat mock data tanpa mengikuti format JSON envelope Dart Frog `{success, message, data, error}`.
- **DILARANG Memory Leak:** Mengabaikan `_controller.dispose()` untuk `AnimationController`, `TextEditingController`, atau `StreamSubscription`.

### 5. Keamanan & Proteksi Data (AppSec Anti-Patterns)
- **DILARANG KERAS** menyimpan token JWT, password, atau data sensitif di `SharedPreferences` biasa. Wajib menggunakan `flutter_secure_storage`.
- **DILARANG KERAS** menyusun query database lokal dengan konkatenasi string mentah (`SELECT * FROM table WHERE col = '$input'`). Wajib gunakan parameter binding `?`.
- **DILARANG KERAS** menyimpan hardcoded secret, API key privat, atau encryption key di source code `.dart`.
- **DILARANG** mencetak token atau data pribadi ke terminal/logcat via `print()` di mode produksi. Wajib bungkus dengan `if (kDebugMode)`.

### 6. Kanvas Figma & Design System (FigCraft Anti-Patterns)
- **DILARANG KERAS** mengekspor Design System atau komponen Figma ke Flutter sebelum mendapat stempel persetujuan eksplisit dari skill desainer UI (`taste-skill`, `awesome-design-md`, `web-interface-guidelines`).
- **DILARANG** menggambar elemen di kanvas Figma dengan posisi absolut mengambang bebas tanpa Auto-Layout. Seluruh struktur wajib memakai Auto-Layout (Vertical/Horizontal).
- **DILARANG** menamai layer kanvas Figma dengan nama mentah acak (`Frame 123`, `Rectangle 45`). Wajib gunakan konvensi `[Modul] / [Komponen]`.
- **DILARANG** menggunakan warna atau rasio kontras teks yang melanggar standar minimal WCAG 4.5:1.
