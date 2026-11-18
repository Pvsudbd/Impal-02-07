# IMPAL Standard Navigation Bar & Persistent Shell Rules

Semua halaman utama yang memiliki navigasi bawah (bottom navigation bar) di aplikasi IMPAL (Home, Task, Team/Kelompok List, Dashboard Kelompok/Team, dan Schedule) **WAJIB** mengikuti arsitektur **Single Persistent Navigation Shell** dan menggunakan komponen resmi:

```dart
import '../../common_widgets/impal_bottom_nav_bar.dart'; // atau path import relatif yang sesuai
ImpalBottomNavBar(...)
```

---

## 1. Arsitektur Single Persistent Navigation Shell (Aturan Utama Navigasi)

Untuk mencegah terjadinya tumpukan halaman yang kacau (*navigation stack chaos*), hilangnya animasi perpindahan tab, dan ketidaksinkronan status navbar, aplikasi IMPAL wajib menerapkan **Single Persistent Shell**:

1. **Satu Scaffold & Satu Instance Navbar di Root**:
   - Hanya halaman Root Shell (`HomePage` / Main Shell) yang memiliki `Scaffold` utama dan me-render `ImpalBottomNavBar` di lapisan bawah `Stack`.
   - Navbar bersifat **persistent (tetap & diam)** di bagian bawah layar. Navbar tidak boleh di-rebuild, dihancurkan, atau ditumpuk rute baru saat pengguna berpindah tab.
2. **Pola Content View & Sub-Flow Tab**:
   - Setiap tab di-render sebagai Content View (`ScheduleContentView`, `TeamListContentView`, `DashboardTeamPage(isStandalone: false)`).
   - Pertukaran tampilan antar tab dikontrol oleh `_currentTab` dan transisi `AnimatedSwitcher` (Cross-fade), sehingga lingkaran aktif oranye pada navbar dapat meluncur mulus (*fluid animation*) ke tab tujuan.
3. **Pengelolaan Sub-Halaman di Dalam Tab (Sub-State Pattern)**:
   - Jika suatu tab memiliki halaman detail (misalnya Tab 2: `TeamListContentView` $\leftrightarrow$ `DashboardTeamPage`):
     - Dikelola melalui state di parent shell (contoh: `_selectedTeam`).
     - Ketika pengguna memilih tim, parent shell mengubah state `_selectedTeam = team`, dan konten tab 2 berganti ke `DashboardTeamPage(isStandalone: false)`. **Navbar tetap berada di Tab 2**.
     - Tombol Back di header kiri atas sub-halaman wajib memanggil callback `onBack` yang mereset state (`_selectedTeam = null`), sehingga tampilan kembali ke daftar tim **tanpa merusak posisi navbar dan tanpa menumpuk rute navigator**.
     - **Aturan Tab Reset**: Ketika pengguna mengetuk tab **Team** di navbar (baik saat berpindah dari tab lain seperti Schedule/Home maupun saat menekan tab Team kembali), tampilan **WAJIB SELALU kembali ke halaman daftar tim (`TeamListContentView`)**, mereset sub-state `_selectedTeam = null`. Sub-halaman detail tidak boleh dipertahankan saat berpindah tab.
4. **Kapan Boleh Menggunakan `Navigator.push`?**:
   - `Navigator.push` / modal hanya diizinkan untuk formulir/dialog aksi sesaat yang memang menutupi layar penuh sementara, seperti:
     - `ScheduleFormPage` (Tambah / Edit Jadwal)
     - Pop-up konfirmasi / modal picker (`PopUpJoinTeam`, `PopUpCreateTeam`, dsb).
   - **DILARANG KERAS** menggunakan `Navigator.push` antar tab utama atau untuk membuka halaman yang memiliki bottom navbar.

---

## 2. Spesifikasi Desain Baku Komponen `ImpalBottomNavBar`

- **Bentuk (Shape)**: Scooped Navigation Bar dengan lengkungan/cutout (notch) presisi konsentris selebar 6px mengelilingi tombol lingkaran aktif.
- **Tombol Melayang (Floating Active Action)**:
  - Lingkaran berdiameter 54px dengan gradien coral (`0xFFFF7253` ke `0xFFFA6144`).
  - Glow shadow coral (`Color(0x80FA6144)` blur 18, spread 1, offset 0, 6).
  - Berpindah tab dengan animasi halus (`TweenAnimationBuilder<double>` dengan kurva `Curves.easeInOutCubic`).
- **Warna Bar**:
  - `barColor`: `#323846`
  - `pocketColor`: `#282D37` (recessed pocket di belakang scoop agar elemen scroll tidak bocor).
- **Tab Standar (4 Tab)**:
  - Tab 0: Home / Beranda (`Icons.home_outlined` / `Icons.home_rounded`)
  - Tab 1: Tasks / Tugas (`Icons.checklist_rounded`)
  - Tab 2: Team / Kelompok (`Icons.groups_outlined` / `Icons.groups_rounded`)
  - Tab 3: Schedule / Kalender (`Icons.calendar_month_outlined` / `Icons.calendar_month_rounded`)

---

## 3. Larangan Mutlak

1. **DILARANG** membuat `Scaffold` baru dengan `ImpalBottomNavBar` duplikat saat navigasi antar tab atau sub-halaman tab.
2. **DILARANG** membuat custom bottom navbar dengan style berbeda (misal pil mengambang polos, BottomNavigationBar bawaan Flutter biasa, dsb) di halaman utama aplikasi.
3. **DILARANG** menduplikasi painter scooped navbar di dalam file page; selalu gunakan `ImpalBottomNavBar`.
