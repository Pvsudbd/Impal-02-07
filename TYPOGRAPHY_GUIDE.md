# Panduan & Template Desain IMPAL: Tipografi, Ukuran Tombol, Sistem Spacing & Pop-up Pemberitahuan

Dokumen ini adalah **single source of truth** untuk skala tipografi (ukuran font, font weight, letter spacing, line height, warna teks), **standarisasi ukuran semua tombol**, **aturan sistem spacing (8-point Grid System)**, serta **standar pop-up pemberitahuan atas (top notification banner)** yang serasi di seluruh aplikasi **IMPAL**.

---

## 1. Font Family & Dasar Desain
- **Primary Font**: `Inter`, sans-serif
- **Theme Mode**: Dark Mode Default
  - Background Utama: `#252932`
  - Container / Card Surface: `#323846`
  - Border / Outline: `#3B4150`
- **Warna Sentimen**:
  - **Positif / Sukses**: Hijau (`#10B981`)
  - **Negatif / Peringatan / Brand Coral**: Orange (`#FA6144`)
  - **Muted / Inactive / Upcoming**: Abu-abu (`#8E95A5`)
- **Aturan Card**: Card Schedule **tidak menggunakan border sama sekali** (`border: null`), hanya menggunakan latar `#323846`, strip warna aksen di sisi kiri, `borderRadius: 12`, padding presisi (`16px, 12px, 14px, 12px`), dan bayangan halus (`BoxShadow`).

---

## 2. Standarisasi Ukuran Semua Tombol (Button Design System)

Semua tombol di dalam aplikasi **IMPAL** diserasikan ke dalam tier standar berikut:

| Kategori Tombol | Tinggi (*Height*) | Border Radius | Font Size & Weight | Letter Spacing | Styling & Shadow | Contoh Penggunaan |
| :--- | :---: | :---: | :---: | :---: | :--- | :--- |
| **Primary Page CTA** | **`48px`** | **`12px`** | `14px` (`w600` SemiBold) | `+0.15` | Full width, Bg `#FA6144`, Shadow blur 14-18, offset (0, 4-8) | `Sign In`, `Create Student Account`, `Verify Code`, `Add Schedule`, `Save Changes`, `Create Schedule` |
| **Modal / Dialog Buttons** | **`44px`** | **`10px`** | `13.5px` (`w600` SemiBold) | `+0.1` | Side-by-side (`Cancel` Outlined / Flat `#8E95A5` & `Confirm` `#FA6144`) | `Cancel`, `Delete`, `Save`, `Make`, `Decline`, `Accept & Continue` |
| **Segment / Filter Pills** | **`25px`** | **`6px`** | `11.5px` (`w600`/`w500`) | `+0.1` | Compact pill, Height 1.0, Bg aktif `#FA6144` / non-aktif `#323846` | Tab filter `All`, `Today`, `Week`, `Month` |
| **Circle Icon Buttons** | **`38px` × `38px`** | **`999px`** | Icon `16px` | - | Circular container, Bg `#323846`, Border 1px `#3B4150` | Tombol Back halaman, tombol dismiss |
| **Card Action Icons** | **`22px` × `22px`** | **`6px`** | Icon `15px` | - | Padding 3.5, color `#8E95A5` | Quick Edit & Quick Delete di card schedule |

### Aturan & Filosofi Desain Tombol:
1. **Presisi Tinggi Form & Tombol Utama (`48px`)**:
   Semua tombol aksi utama (CTA) satu halaman memiliki tinggi `48px` dan `borderRadius: 12`. Ukuran ini identik dengan tinggi kontainer input form text field (`48px`), menciptakan harmoni visual vertikal yang konsisten.
2. **Kerapian Dialog & Modal (`44px`)**:
   Tombol di dalam pop-up konfirmasi menggunakan tinggi `44px` dengan `borderRadius: 10` agar tidak memakan ruang berlebih pada layar modal yang ringkas.
3. **Ketebalan Teks Tombol (`FontWeight.w600`)**:
   Semua teks tombol menggunakan `FontWeight.w600` (SemiBold) dengan sedikit *letter-spacing* (`+0.1` hingga `+0.15`). Menghindari `FontWeight.w700` atau `w800` yang terlalu tebal dan padat.

---

## 3. Sistem & Aturan Spacing Harmonis (8-Point Grid Spacing System)

Aplikasi **IMPAL** menerapkan **8-Point Grid System** secara ketat dengan **4-point half-steps** untuk elemen mikro. Seluruh ukuran `SizedBox`, margin, dan padding diwajibkan menggunakan skala token berikut:

### A. Tabel Skala Token Spacing Standar

| Token | Nilai | Nilai Rem/DP | Kategori | Penggunaan & Penerapan |
| :--- | :---: | :---: | :--- | :--- |
| **`xxs`** | **`4px`** | `0.25rem` | Micro Spacing | Jarak ikon ke teks pada badge/chip/status pill, gap horizontal teks sub-header kecil |
| **`xs`** | **`8px`** | `0.5rem` | Compact Gap | Jarak label teks ke input form field (`SizedBox(height: 8)`), jarak horizontal ikon ke teks tombol (`SizedBox(width: 8)`), gap antar filter chips |
| **`sm`** | **`12px`** | `0.75rem` | Component Item | Jarak antar item card jadwal (`margin: bottom: 12`), padding vertikal dalam card (`12px`), gap horizontal tombol modal dialog (`SizedBox(width: 12)`) |
| **`md`** | **`16px`** | `1.0rem` | Form & Inner Gap | Jarak antar baris input form (`SizedBox(height: 16)`), padding horizontal dalam card (`16px`), jarak filter bar ke Add Schedule button (`SizedBox(height: 16)`), padding vertikal toast pemberitahuan |
| **`lg`** | **`20px`** | `1.25rem` | Page Margins | Margin horizontal layar mobile standar (`20px`), jarak header ke filter bar (`SizedBox(height: 20)`), jarak modal dialog body ke action buttons (`SizedBox(height: 20)`), jarak tombol submit CTA ke footer nav link (`SizedBox(height: 20)`) |
| **`xl`** | **`24px`** | `1.5rem` | Section Gap | Jarak pemisah antar section besar di Dashboard (`SizedBox(height: 24)`), jarak input form terakhir / controls ke tombol submit CTA (`SizedBox(height: 24)`), jarak Add Schedule button ke card list (`SizedBox(height: 24)`), padding vertikal modal konfirmasi |
| **`xxl`** | **`32px`** | `2.0rem` | Hero / Welcome Gap | Jarak vertikal dari logo/hero autentikasi ke awal input form |
| **`xxxl`** | **`40px`** | `2.5rem` | Major Layout | Padding vertikal area kosong (*empty state*), pemisah blok layar utama |

---

### B. Aturan Spacing Spesifik Per Halaman

#### 1. Schedule Page (`schedule_page.dart`)
- **Page Outer Padding**: `EdgeInsets.fromLTRB(20, 16, 20, 110)` (Margin horizontal 20px, bottom 110px untuk floating navigation bar).
- **Header ke Filter Bar**: `SizedBox(height: 20)` (Token `lg`).
- **Filter Bar ke Tombol Add Schedule**: `SizedBox(height: 16)` (Token `md`).
- **Tombol Add Schedule ke Card List**: `SizedBox(height: 24)` (Token `xl`).
- **Date Header Padding**: `EdgeInsets.only(top: 16, bottom: 12)`.
- **Card Spacing**: `margin: EdgeInsets.only(bottom: 12)` (Token `sm`).
- **Card Inner Padding**: `EdgeInsets.fromLTRB(16, 12, 14, 12)` (Kiri 16px, Atas 12px, Kanan 14px, Bawah 12px).

#### 2. Dashboard Home Page (`home_page.dart`)
- **Page Outer Padding**: `EdgeInsets.fromLTRB(20, 16, 20, 110)`.
- **Header ke Today's Schedule Section**: `SizedBox(height: 24)` (Token `xl`).
- **Today's Schedule ke Categories Section**: `SizedBox(height: 24)` (Token `xl`).
- **Categories ke Ongoing Tasks Section**: `SizedBox(height: 24)` (Token `xl`).
- **Section Title ke Content Cards**: `SizedBox(height: 12)` (Token `sm`).
- **Category Card Padding**: `EdgeInsets.symmetric(horizontal: 16, vertical: 14)`.
- **Category Card Gap**: `Padding(padding: EdgeInsets.only(right: 12))`.

#### 3. Auth Pages (`login_page.dart`, `regist_page.dart`, `forgot_password_page.dart`, `reset_password_page.dart`, `verification_code_page.dart`)
- **Desktop Container Padding**: `EdgeInsets.symmetric(horizontal: 24, vertical: 28)`.
- **Mobile Screen Margin**: `EdgeInsets.symmetric(horizontal: 20)`.
- **Hero Icon & Title Section Gap**: `SizedBox(height: 24)` ke awal form input.
- **Label Field ke Text Field**: `SizedBox(height: 8)` (Token `xs`).
- **Jarak Antar Baris Form Input**: `SizedBox(height: 16)` (Token `md`).
- **Field Terakhir ke Checkbox / Remember Me**: `SizedBox(height: 16)` (Token `md`).
- **Checkbox / Auxiliary Controls ke Tombol Submit**: `SizedBox(height: 24)` (Token `xl`).
- **Tombol Submit CTA ke Footer Navigation Link**: `SizedBox(height: 20)` (Token `lg`).

#### 4. Add & Edit Schedule Form (`add_new_schedule.dart`, `edit_schedule.dart`)
- **Form Screen Padding**: `EdgeInsets.symmetric(horizontal: 20, vertical: 16)`.
- **Label ke Field / Selector**: `SizedBox(height: 8)` (Token `xs`).
- **Jarak Antar Field**: `SizedBox(height: 16)` (Token `md`).
- **Field Terakhir ke Tombol Simpan/Buat**: `SizedBox(height: 24)` (Token `xl`).
- **Bottom Safe Margin**: `SizedBox(height: 24)` (Token `xl`).

#### 5. Pop-up Konfirmasi Modal (`pop_up_konfirmasi_delete.dart`, `pop_up_konfirmasi_edit.dart`, `pop_up_make_schedule.dart`)
- **Dialog Inner Padding**: `EdgeInsets.symmetric(horizontal: 20, vertical: 24)`.
- **Icon Badge ke Modal Title**: `SizedBox(height: 16)` (Token `md`).
- **Modal Title ke Description Body**: `SizedBox(height: 8)` (Token `xs`).
- **Description Body ke Action Buttons**: `SizedBox(height: 20)` (Token `lg`).
- **Jarak Antar Tombol Modal**: `SizedBox(width: 12)` (Token `sm`).

#### 6. Pop-up Pemberitahuan Toast (`pop_up_pemberitahuan.dart`)
- **Outer Padding**: `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`.
- **Icon Badge ke Teks Notifikasi**: `SizedBox(width: 12)` (Token `sm`).
- **Title ke Message**: `SizedBox(height: 2)` (Micro gap).
- **Teks Notifikasi ke Close Button**: `SizedBox(width: 8)` (Token `xs`).

---

## 4. Aturan & Standar Pop-up Pemberitahuan Atas (Top Notification Banner)

Aplikasi **IMPAL** menggunakan notifikasi melayang yang muncul dari atas layar (*top overlay banner*) yang elegan, responsif, dan interaktif melalui class `PopUpPemberitahuan` ([pop_up_pemberitahuan.dart](file:///c:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/frontend/lib/presentation/common_widgets/pop_up_pemberitahuan.dart)).

### A. Anatomi Visual & Ukuran Komponen
- **Posisi Layar**: Melayang di atas layar dengan offset `top: MediaQuery.of(context).padding.top + 14px`, margin horizontal `16px` dari tepi kiri dan kanan, serta dibatasi `maxWidth: 440px` di tengah (*centered*) untuk menjamin kerapian di layar mobile maupun web/desktop.
- **Card Container**:
  - Background: `#323846` (Surface Dark)
  - Border: `1px solid #3B4150`
  - Border Radius: `16px` (`BorderRadius.circular(16)`)
  - Padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`
  - Shadow: `BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))`
- **Badge Ikon Indikator**:
  - Ukuran Kontainer: `38px` × `38px`
  - Border Radius: `12px` (`BorderRadius.circular(12)`)
  - Ukuran Ikon: `20px` (`size: 20`), warna `Colors.white`
  - Glowing Aksen Ikon: `BoxShadow(color: iconBgColor.withValues(alpha: 0.35), blurRadius: 10, offset: Offset(0, 4))`
- **Tipografi & Spacing Konten**:
  - Jarak Badge Ikon ke Teks: `12px` (`SizedBox(width: 12)`)
  - Judul Notifikasi: `13.5px`, `FontWeight.w600` (SemiBold), `letterSpacing: -0.1`, warna `Colors.white`
  - Gap Judul ke Deskripsi: `2px` (`SizedBox(height: 2)`)
  - Pesan Deskripsi: `12px`, `FontWeight.w400` (Regular), `height: 1.35`, warna `#D1D5DB`
  - Gap Teks ke Tombol Close: `8px` (`SizedBox(width: 8)`)
- **Tombol Close**:
  - Ikon: `Icons.close_rounded`, ukuran `18px`, warna `#8E95A5`
  - Padding tap: `EdgeInsets.all(4)`, radius ink `10px`

---

### B. Aturan Warna & Sentimen (Color Sentiment Rule)

Warna badge ikon pada Pop-up Pemberitahuan **wajib** mengikuti aturan sentimen berikut:

| Sentimen | Warna Hex | Kode Flutter | Sifat & Peristiwa Notifikasi | Contoh Peristiwa / Trigger |
| :--- | :---: | :---: | :--- | :--- |
| **POSITIF / SUKSES** | **`#10B981`** | `Color(0xFF10B981)` | Peristiwa berhasil, konfirmasi sukses, data tersimpan, kode valid, login sukses | `Account Created`, `Password Updated`, `Recovery Code Sent`, `Code Verified`, `Login Successful`, `Schedule Created`, `Schedule Updated` |
| **NEGATIF / WARNING** | **`#FA6144`** | `Color(0xFFFA6144)` | Peringatan, data dihapus, validasi gagal, form belum disetujui, pembatalan | `Schedule Deleted`, `Terms & Privacy Policy Warning`, `Failed to connect`, `Invalid input` |

> [!IMPORTANT]
> **Aturan Sentimen Mutlak**:
> 1. Semua hal yang bersifat **positif / sukses** wajib menggunakan badge **Hijau (`#10B981`)**.
> 2. Semua hal yang bersifat **negatif / peringatan / hapus** wajib menggunakan badge **Orange (`#FA6144`)**.
> 3. Dilarang menggunakan warna lain di luar dua standar ini pada badge pop-up pemberitahuan atas.

---

### C. Animasi, Durasi & Interaksi
1. **Animasi Masuk & Keluar**:
   - `SlideTransition`: Masuk meluncur dari atas (`Offset(0, -1.2)`) ke `Offset.zero` dengan kurva `Curves.easeOutCubic`.
   - `FadeTransition`: Opasitas bertransisi lembut dari `0.0` ke `1.0`.
   - Durasi Animasi: `280ms`.
2. **Durasi Tampil (Auto-Dismiss)**:
   - Durasi default: `2800ms` (`2.8 detik`).
   - Otomatis menghilang dengan animasi mundur keluar ke atas (`reverse()`) lalu melepas `OverlayEntry`.
3. **Gestur Pengguna (Interactive Dismiss)**:
   - **Swipe / Drag ke Atas**: Pengguna dapat menyapu pop-up ke atas untuk langsung menutupnya (`onVerticalDragEnd` dengan *upward velocity*).
   - **Tap Kartu**: Mengetuk badan kartu notifikasi akan langsung menutupnya.
   - **Tombol X**: Menekan tombol silang kanan atas akan langsung memicu `dismiss()`.
4. **Single Active Notification (Singleton Overlay)**:
   - Jika notifikasi baru dipicu saat notifikasi sebelumnya masih aktif, notifikasi lama akan segera di-dismiss sehingga tidak terjadi tumpang tindih (*stacking*) di atas layar.

---

### D. Daftar Metode & Preset Standar

Seluruh modul dilarang membuat snackbar terpisah dan diwajibkan memanggil helper `PopUpPemberitahuan`:

#### 1. Generic & Sentiment Helpers
```dart
// Notifikasi Sukses (Badge Hijau #10B981)
PopUpPemberitahuan.success(
  context,
  title: 'Profile Updated',
  message: 'Your profile has been saved successfully.',
);

// Notifikasi Warning (Badge Orange #FA6144)
PopUpPemberitahuan.warning(
  context,
  title: 'Incomplete Fields',
  message: 'Please complete all required fields before continuing.',
);

// Notifikasi Error (Badge Orange #FA6144)
PopUpPemberitahuan.error(
  context,
  title: 'Network Error',
  message: 'Unable to reach the server. Please check your connection.',
);
```

#### 2. Preset Autentikasi
```dart
// Registrasi berhasil (Hijau)
PopUpPemberitahuan.accountCreated(context, name: 'Budi');

// Login berhasil (Hijau)
PopUpPemberitahuan.loginSuccess(context, username: 'Budi');

// Kode recovery dikirim (Hijau)
PopUpPemberitahuan.recoveryCodeSent(context, destination: 'budi@telkomuniversity.ac.id');

// Kode verifikasi reset benar (Hijau)
PopUpPemberitahuan.codeVerified(context);

// Password baru berhasil disimpan (Hijau)
PopUpPemberitahuan.passwordUpdated(context);

// Peringatan belum menyetujui Terms & Policy (Orange)
PopUpPemberitahuan.termsWarning(context);
```

#### 3. Preset Manajemen Jadwal
```dart
// Jadwal berhasil dibuat (Hijau)
PopUpPemberitahuan.scheduleCreated(context);

// Jadwal berhasil diedit / diperbarui (Hijau)
PopUpPemberitahuan.scheduleUpdated(context);

// Jadwal berhasil dihapus (Orange)
PopUpPemberitahuan.scheduleDeleted(context);
```

---

## 5. Tabel Skala Tipografi Standar

| Kategori | Font Size | Font Weight | Line Height | Letter Spacing | Warna Default | Penggunaan Utama |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **H1 - Page Header** | `20px` - `22px` | `w700` (Bold) | `1.2` | `-0.3` | `Colors.white` | Salam utama (`Hi {name}`), Judul halaman auth |
| **H2 - Section Header** | `16px` - `18px` | `w700` (Bold) | `1.25` | `-0.2` | `Colors.white` | Judul modal dialog (`Delete Schedule?`), Judul section |
| **H3 - Card Title** | `13.5px` | `w600` (SemiBold) | `1.25` | `-0.1` | `Colors.white` | Judul item jadwal, judul card tugas |
| **Subtitle / Accent** | `12px` | `w600` (SemiBold) | `1.3` | `+0.15` | `#FF7D65` (Coral) | Sub-header kategori (`Jadwal Kuliah`) |
| **Body Large** | `13.5px` - `14px` | `w400` / `w500` | `1.4` | `0.0` | `#D1D5DB` | Teks paragraf, input text form |
| **Body Regular** | `12.5px` | `w400` (Regular) | `1.45` | `0.0` | `#D1D5DB` | Deskripsi konfirmasi modal, teks penjelasan |
| **Notification Title**| `13.5px` | `w600` (SemiBold) | `1.2` | `-0.1` | `Colors.white` | Judul pop up pemberitahuan atas |
| **Notification Body** | `12px` | `w400` (Regular) | `1.35` | `0.0` | `#D1D5DB` | Pesan pop up pemberitahuan atas |
| **Button Primary Text**| `14px` | `w600` (SemiBold) | `1.0` | `+0.15` | `Colors.white` | Tombol CTA (`Add Schedule`, `Sign In`, `Create Schedule`) |
| **Button Dialog Text** | `13.5px` | `w600` (SemiBold) | `1.0` | `+0.1` | `Colors.white` / `#D1D5DB` | Tombol modal (`Cancel`, `Delete`, `Save`) |
| **Filter Bar Pill** | `11.5px` | `w600` (Aktif) / `w500` | `1.0` | `+0.1` | `Colors.white` / `#8E95A5` | Tab filter (`All`, `Today`, `Week`, `Month`) |
| **Metadata / Location**| `11.5px` | `w500` (Medium) | `1.2` | `+0.05` | `#8E95A5` | Jam pelaksanaan, lokasi ruangan |
| **Status Badge / Pill** | `9.5px` - `10px` | `w600` (SemiBold) | `1.0` | `+0.25` | `Colors.white` / `#8E95A5` | Badge status (`Ongoing`, `Upcoming`) |
| **Caption / Fine Print**| `11px` | `w400` (Regular) | `1.3` | `0.0` | `#8E95A5` | Timestamp, keterangan kecil di footer |

---

## 6. Flutter Code Snippet Template

### A. Tipografi (`AppTypography`)

```dart
import 'package:flutter/material.dart';

abstract class AppTypography {
  static const String fontFamily = 'Inter';

  // Headings
  static const TextStyle pageHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: Colors.white,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: Color(0xFF8E95A5),
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: Colors.white,
  );

  // Card Content
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.25,
    color: Colors.white,
  );

  static const TextStyle cardMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    color: Color(0xFF8E95A5),
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  // Buttons & Controls
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Colors.white,
  );

  static const TextStyle dialogButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  static const TextStyle filterPill = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    height: 1.0,
    letterSpacing: 0.1,
  );

  // Body & Descriptions
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: Color(0xFFD1D5DB),
  );

  // Notification Toast
  static const TextStyle notificationTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: Colors.white,
  );

  static const TextStyle notificationMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: Color(0xFFD1D5DB),
  );
}
```

### B. Spacing (`AppSpacing`)

```dart
import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(lg, md, lg, 110.0);
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(md, sm, 14.0, sm);
  static const EdgeInsets cardMarginBottom = EdgeInsets.only(bottom: sm);
  static const EdgeInsets dialogPadding = EdgeInsets.symmetric(horizontal: lg, vertical: xl);
  static const EdgeInsets notificationPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  static const Widget vGapXXS = SizedBox(height: xxs);
  static const Widget vGapXS = SizedBox(height: xs);
  static const Widget vGapSM = SizedBox(height: sm);
  static const Widget vGapMD = SizedBox(height: md);
  static const Widget vGapLG = SizedBox(height: lg);
  static const Widget vGapXL = SizedBox(height: xl);
  static const Widget vGapXXL = SizedBox(height: xxl);

  static const Widget hGapXS = SizedBox(width: xs);
  static const Widget hGapSM = SizedBox(width: sm);
  static const Widget hGapMD = SizedBox(width: md);
  static const Widget hGapLG = SizedBox(width: lg);
}
```

---

## 7. Kaidah & Best Practices Desain Sistem IMPAL

1. **Gunakan Kelipatan 8pt (dan 4pt untuk micro-spacing)**:
   Hindari memberi nilai jarak sembarang (seperti 10, 14, 18, 22, 28, 30). Selalu gunakan skala: `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`.
2. **Harmonisasi Ukuran Tombol & Input Field**:
   - Selalu gunakan `height: 48` dan `borderRadius: 12` untuk semua tombol utama halaman dan form input text field.
   - Selalu gunakan `height: 44` dan `borderRadius: 10` untuk tombol di dalam modal konfirmasi.
   - Selalu gunakan `height: 25` dan `borderRadius: 6` untuk tombol filter segment.
3. **Card Schedule Tanpa Border**:
   Card item jadwal tidak boleh menggunakan border. Gunakan container `#323846`, strip aksen kiri 4px, `borderRadius: 12`, dan padding `EdgeInsets.fromLTRB(16, 12, 14, 12)`.
4. **Warna Sentimen Pop-up Pemberitahuan**:
   - Hijau (`#10B981`) untuk hal positif / sukses.
   - Orange (`#FA6144`) untuk hal negatif / peringatan / hapus.
5. **Hindari `FontWeight.w700` atau `w800` pada teks kecil (< 14px)**:
   Pada latar belakang gelap (`#252932` / `#323846`), gunakan `FontWeight.w600` untuk penekanan dan `FontWeight.w500` untuk metadata.
6. **Berikan `letterSpacing` positif pada teks berukuran kecil**:
   Untuk teks `9.5px` - `11.5px`, tambahkan `letterSpacing: 0.1` hingga `0.25` agar jarak antar huruf lebih lega.
7. **Gunakan `letterSpacing` negatif pada judul besar**:
   Untuk teks `18px` ke atas, gunakan `letterSpacing: -0.2` hingga `-0.3` agar judul terlihat padat dan modern (*tight & punchy*).
8. **Jaga Kontras Rasio**:
   - Teks penting / judul: `Colors.white`
   - Teks deskripsi: `#D1D5DB` (Light Grey)
   - Teks keterangan / status waktu: `#8E95A5` (Slate Muted)
   - Latar dialog & surface: `#323846`
