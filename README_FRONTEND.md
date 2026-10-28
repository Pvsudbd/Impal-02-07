# 📱 IMPAL Smart ToDoList — Frontend Architecture & Production Guide

Proyek frontend mobile & web untuk IMPAL (Implementasi Pola Desain Perangkat Lunak) Kelompok 7, dikembangkan menggunakan Flutter dengan standar studio tingkat produksi berbasis **`AGENTS.md`**.

---

## 🏛️ 1. Struktur Arsitektur Direktori

```text
frontend/lib/
├── core/
│   ├── network/                        # ApiClient, interceptor, endpoints & envelope parser
│   │   ├── api_client.dart             # HTTP Client dengan auth header otomatis
│   │   ├── api_endpoints.dart          # Base URL adaptif & rute REST API
│   │   └── api_response.dart           # Dart Frog Envelope {success, message, data, error}
│   ├── theme/                          # Token warna & tipografi terpusat
│   │   ├── app_colors.dart             # Palet warna hex & layered shadows
│   │   ├── app_spacing.dart            # Grid spacing 8-point & padding preset
│   │   └── app_typography.dart         # Skala teks baku Inter
│   ├── utils/                          # Engine responsivitas & transisi
│   │   ├── responsive_context.dart     # Engine ResponsiveContext studio
│   │   ├── page_transitions.dart       # Transisi halus 60 FPS
│   │   └── top_toast.dart              # Toast notifikasi
│   └── widgets/                        # Komponen global pakai ulang
│       ├── app_button.dart             # Loading button anti-double submit & label tetap
│       └── unfocus_on_tap.dart         # Ergonomi keyboard auto-dismiss
│
├── presentation/                       # Presentation layer & modular views
│   ├── common_widgets/                 # Shared widgets IMPAL
│   │   ├── impal_bottom_nav_bar.dart   # Scooped persistent navbar (Single Shell)
│   │   ├── impal_schedule_card.dart    # Kartu jadwal (Horizontal & Vertikal)
│   │   ├── impal_time_picker_dialog.dart # 24-hr time picker (Dial & Ketik mode)
│   │   ├── impal_date_picker_dialog.dart # Seamless date picker
│   │   └── pop_up_pemberitahuan.dart   # Feedback toast & alerts
│   └── features/                       # Fitur aplikasi (Feature-First)
│       ├── auth/                       # Login, Register, Forgot & Reset Password, OTP
│       │   ├── widgets/                # AuthCardWrapper, AuthTextField, OtpBoxes, PasswordStrengthCard, dll.
│       ├── dashboard/                  # Home page & task tracking
│       │   ├── models/                 # dashboard_models.dart (CategoryItem, TaskItem, TaskTag, ScheduleItem)
│       │   └── widgets/                # HomeHeader, HomeCategoriesSection, HomeTaskCard, HomeScheduleSection
│       ├── jadwal/                     # Schedule views, create & edit schedule form
│       │   ├── models/                 # schedule_model.dart, schedule_repository.dart
│       │   └── widgets/                # ScheduleTypeSelector, ScheduleDateTimeSection, TeamMeetingAutocomplete, dll.
│       └── team/                       # Team collaboration, tasks & meeting management
│           ├── create_task_team.dart   # Layar Terpadu Dual-Mode: Create & Edit Task Team (Multi-Assignee)
│           ├── pop_up_pemberitahuan_team.dart # Helper notifikasi pop-up team resmi IMPAL
│           ├── models/                 # team_model.dart, team_repository.dart, team_task_model.dart, team_member_model.dart
│           └── widgets/                # TeamCard, TeamHeader, TeamDashboardHeader, TeamTaskCard, SubmissionDeadlinePicker, AssigneeDropdown (Multi-Select), dll.
```

---

## 📐 2. Responsive Engine (`ResponsiveContext`)

Hindari hardcoded pixel. Selalu gunakan ekstensi `context`:
```dart
import 'package:impal_smart_todolist/core/utils/responsive_context.dart';

// Font adaptif
Text('Title', style: TextStyle(fontSize: context.rFont(16, min: 14, max: 20)));

// Spacing & Gap
context.vGap(24); // SizedBox(height: ...)

// Ikon adaptif
Icon(Icons.star, size: context.rIcon(24));

// Logo / banner
context.rLogo(percentWidth: 0.35, minWidth: 100, maxWidth: 200);

// Nested Border Radius
final innerRadius = context.nestedRadius(outerRadius: 16, padding: 8); // 8px
```

---

## ⚡ 3. 5 Aturan Emas HP Kentang (60 FPS Performance)

1. **Konstruktor `const` Mutlak**: Seluruh widget statis wajib memakai `const` untuk menghindari rebuild tree.
2. **Kontrol Memori Gambar**: Batasi alokasi `cacheWidth` dan `cacheHeight` pada bitmap.
3. **Pemuatan Bertahap**: List panjang menggunakan `ListView.builder` / `SliverList`.
4. **Anti-Overdraw GPU**: Hindari tumpukan blur `BackdropFilter` berat; gunakan flat color opacity.
5. **Isolasi Rendering (`RepaintBoundary`)**: Elemen animasi dibungkus dengan `RepaintBoundary`.

---

## 🔌 4. Integrasi Backend (Dart Frog & PostgreSQL)

- **Base URL Adaptif**:
  - Android Emulator: `http://10.0.2.2:8080`
  - Web / Desktop / iOS: `http://localhost:8080`
- **Envelope JSON**:
  ```json
  {
    "success": true,
    "message": "Operasi berhasil",
    "data": { ... },
    "error": null
  }
  ```
- **Protokol Ticket-as-Code**:
  Jika membutuhkan endpoint baru, ajukan tiket di `.agents/tickets/pending/REQ-[NOMOR]-FE-[DESKRIPSI].md` sesuai domain dev backend yang dituju (`DEV_1_VALEN`, `DEV_2_ROYUL`, `DEV_3_LEAVES`).

---

## 🧪 5. Menjalankan Pengujian

Verifikasi kompilasi dan kelayakan widget:
```bash
flutter analyze
flutter test
```
Target studio: **0 Error, 0 Warning**.

