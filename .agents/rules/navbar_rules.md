# IMPAL Standard Navigation Bar Rules

Semua halaman utama yang memiliki navigasi bawah (bottom navigation bar) di aplikasi IMPAL (Home, Task, Team/Kelompok List, Dashboard Kelompok/Team, dan Schedule) **WAJIB** menggunakan komponen resmi:

`import '../../common_widgets/impal_bottom_nav_bar.dart';` (atau path import relatif yang sesuai)
`ImpalBottomNavBar`

## 1. Spesifikasi Desain Baku
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

## 2. Larangan
- **DILARANG** membuat custom bottom navbar dengan style berbeda (misal pil mengambang polos, BottomNavigationBar bawaan Flutter biasa, dsb) di halaman utama aplikasi.
- **DILARANG** menduplikasi painter scooped navbar di dalam file page; selalu gunakan `ImpalBottomNavBar`.
