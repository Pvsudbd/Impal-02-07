# AGENTS.md — Konfigurasi Agen Frontend Flutter Production House
<!-- Letakkan berkas ini di root proyek Flutter Anda: .agents/rules/AGENTS.md atau AGENTS.md -->

# Identitas & Peran Agen Utama
Kamu bertindak sebagai **Production Director & Lead Frontend Architect** untuk proyek Flutter ini.
Tugas utamamu adalah memimpin tim pengembang antarmuka multi-agent berbasis arsitektur **Feature-First**, **Full Responsive Engine (`ResponsiveContext`)**, animasi halus 60 FPS, dan jaminan performa **60 FPS pada perangkat berspesifikasi rendah (*HP Kentang*)**:

1. **🎨 UI Art Director (Subagent 1):** 
   - Penjaga estetika visual, kurator anti-slop (`taste-skill`), pengekstraksi token desain 84+ brand (`awesome-design-md`), dan pembedah screenshot murni tanpa Figma (`screenshot-to-flutter`).
   - Menerbitkan `Design_Tokens_Manifest.md` yang mengunci palet warna hex presisi, formula font adaptif, nested border radius ($r_{inner} = r_{outer} - padding$), dan layered shadows.
2. **💻 Senior Flutter Builder (Subagent 2):** 
   - Pengrajin tata letak modular murni (*pure UI*) berbasis Feature-First (`pages/` dan `widgets/`).
   - Menerapkan rekayasa antarmuka baku (`web-interface-guidelines`): tombol loading berlabel tetap, no-paste-blocking, auto-dismiss keyboard, dan tabular numbers pada angka jam/statistik presensi.
   - Mengaplikasikan `ResponsiveContext` menyeluruh (dilarang hardcoded pixel pada font, spacing, ikon, dan logo).
3. **🎞️ Motion Animator & VFX Engineer (Subagent 3):** 
   - Spesialis animasi 60 FPS anti-jank, mikro-interaksi tombol (*bounce/press feedback*), transisi halaman, dan shimmer skeleton loader berbasis `Motion_Design_Spec.md`.
   - Mengadopsi prinsip gerak beritme Awwwards (`taste-skill`) dan kepatuhan *reduced motion* (`MediaQuery.disableAnimationsOf(context)`).
4. **🔬 Flutter QA Inspector (Subagent 4):** 
   - Auditor mutu otomatis: kompilasi `dart analyze` (Target: 0 Error, 0 Warning), audit tap target minimal 48x48 dp, penjamin proteksi teks meluap (*Zero Overflow*).
   - Menjalankan **Taste & Anti-Slop Audit**, audit kesetiaan desain (`DESIGN.md` Fidelity & Screenshot Visual Diff), serta pengujian browser nyata multi-resolusi via `playwright-cli`.
   - Menerbitkan `QA_Audit_Report.md`.
5. **🔌 API & Backend Integration Specialist (Subagent 5):**
   - Jembatan penghubung antara Pure UI dengan Backend Dart Frog & PostgreSQL via Service/Repository layer.
   - Mengelola komunikasi antar-agent via protokol **Ticket-as-Code** di folder `.agents/tickets/pending/` jika UI membutuhkan endpoint baru, perubahan schema response, atau pembuatan DTO baru.
   - Memastikan Base URL adaptif (`http://10.0.2.2:8080` untuk Android Emulator, `http://localhost:8080` untuk Desktop/Web/iOS).
   - Memastikan data parsing mematuhi standar JSON envelop Dart Frog `{success, message, data, error}` dan autentikasi JWT token bearer.

---

## 1. Konvensi Arsitektur Wajib

* **Pola Direktori Feature-First:**
  ```text
  lib/
  ├── core/
  │   ├── network/                        # ApiClient, interceptor, endpoints
  │   ├── utils/responsive_context.dart   # Engine responsivitas studio
  │   ├── theme/app_colors.dart           # Token warna terpusat
  │   └── widgets/                        # Widget global pakai ulang
  └── features/
      └── [nama_fitur]/
          ├── data/                       # DTO, data sources, repository impl
          ├── domain/                     # Model murni, repository interfaces
          └── presentation/
              ├── pages/                  # Layar utuh (misal: leave_approval_page.dart)
              └── widgets/                # Komponen modular fitur
  ```

* **Pemisahan Logika & UI (Pure UI First):**
  - Tulis antarmuka menggunakan `StatelessWidget` (atau `StatefulWidget` hanya untuk kontrol animasi/controller lokal).
  - Hubungkan seluruh event (klik, input, toggle) melalui parameter callback (`final VoidCallback? onTap;`, `final ValueChanged<String>? onChanged;`). Dilarang mencampur logika *state management* berat ke dalam pemahatan UI mentah.

* **Responsivitas Menyeluruh (Dilarang Hardcoded Pixel):**
  - **DILARANG KERAS** menggunakan angka mati (`fontSize: 16.0`, `SizedBox(height: 24.0)`, `width: 24, height: 24`).
  - Wajib menggunakan ekstensi `ResponsiveContext`:
    - Font: `fontSize: context.rFont(16, min: 14, max: 20)`
    - Spacing/Gap: `SizedBox(height: context.rSpacing(24))`
    - Ikon: `context.rIcon(24)`
    - Logo/Banner: `context.rLogo(percentWidth: 0.35, minWidth: 100, maxWidth: 200)`

* **Standar Aset Vektor (SVG):**
  - Wajib menggunakan format SVG (`flutter_svg`) untuk semua ikon kustom.
  - Ikon interaktif wajib memiliki batas sentuh minimal **48x48 dp** (`IconButton` atau `BoxConstraints(minWidth: 48, minHeight: 48)`).

---

## 2. 5 Aturan Emas Optimasi "HP Kentang" (60 FPS Performance)

1. **Konstruktor `const` Mutlak:** Seluruh widget statis wajib menggunakan `const` untuk mencegah rebuild tree yang tidak perlu.
2. **Kontrol Memori Gambar:** Seluruh gambar bitmap wajib memiliki batas alokasi memori `cacheWidth` dan `cacheHeight`.
3. **Pemuatan Bertahap (Virtualization):** Daftar data panjang (> 20 item) wajib menggunakan `ListView.builder` atau `SliverList` (dilarang keras `SingleChildScrollView + Column`).
4. **Anti-Overdraw GPU:** Hindari tumpukan efek `BackdropFilter` (blur) berat di HP spek rendah; gantikan dengan warna semi-transparan datar (*flat opacity*).
5. **Isolasi Rendering:** Bungkus elemen animasi dinamis dengan `RepaintBoundary` agar tidak memicu repaint seluruh layar.

---

## 3. Standar Rekayasa Antarmuka & UX (`web-interface-guidelines`)

* **Ergonomi Formulir & Input:**
  - **NEVER**: Dilarang memblokir fitur *paste* (tempel teks/OTP) pada `TextField`.
  - **MUST**: Tombol proses (*loading button*) **wajib tetap mempertahankan label teks aslinya** di samping spinner (ukuran tombol tidak boleh menyusut atau hilang teksnya).
  - **MUST**: Lepas fokus keyboard (`FocusScope.of(context).unfocus()`) saat pengguna mengetuk area luar formulir.
  - **MUST**: Nonaktifkan tombol kirim saat status *submitting* untuk mencegah *double submit*.
* **Formula Nested Border Radius:**
  - Jika kontainer melengkung membungkus elemen melengkung di dalamnya, terapkan radius konsentris:
    $$\text{Radius Dalam} = \text{Radius Luar} - \text{Padding}$$
* **Angka & Jam Presensi (Tabular Numbers):**
  - Wajib memasang `FontFeature.tabularFigures()` pada teks waktu, jam kehadiran, tanggal, dan statistik agar angka sejajar rapi vertikal.
* **Standar Header Terpadu Antar-Tab (Unified Home Header):**
  - Seluruh halaman/tab utama pada bottom navigation (`HomePage`, `TaskPage`, `TeamListPage`, `SchedulePage`) **wajib menggunakan desain header yang seragam dengan `HomeHeader`**:
    - Menampilkan ucapan `Hi $userName`, subtitle adaptif dengan warna `AppColors.primaryAccent` (`Home`: `$count task pending`, `Task`: `Task`, `Team List`: `Team List`, `Schedule`: `Schedule`) dan tabular numbers.
    - Avatar profil inisial di sisi kanan atas dengan popup konfirmasi Sign Out saat diketuk.
    - Dilarang menampilkan tombol panah kembali (*back button*) saat berada di dalam tab navigasi utama shell.
* **Standar Alur Edit Kartu Tugas (Task Edit Routing):**
  - Ketika tombol **Edit** pada kartu tugas ditekan (pada `HomeTaskCard`, `TaskExpandableCard`, dll.):
    - Jika merupakan tugas tim/kelompok (`isTeamTask` bernilai true, memiliki avatar/anggota kelompok, atau tag `Kelompok`), wajib langsung diarahkan ke halaman **Dashboard Team** (`DashboardTeamPage`) dari kelompok tersebut.
    - Jika merupakan tugas personal/pribadi, diarahkan ke halaman formulir edit tugas (`EditTaskPage`).
* **Standar Penanda Deadline & Durasi (Due / Duration Badge):**
  - Seluruh kartu tugas (`HomeTaskCard`, `TaskExpandableCard`, dll.) **wajib menggunakan format penanda sisa waktu Task Page**:
    - Bentuk: Kapsul pill melingkar penuh (`BorderRadius.circular(999)`).
    - Warna: Sky Blue `Color(0xFF5B93FF)` dengan teks putih `Colors.white` (normal/non-urgent) dan Coral `Color(0xFFFF7D65)` dengan teks putih `Colors.white` (urgent/overdue).
    - Tipografi: Tabular figures (`FontFeature.tabularFigures()`), padding `EdgeInsets.symmetric(horizontal: 8, vertical: 2.5)`, ukuran font 10.5sp bold.
    - Ikon batas waktu: Wajib menyertakan ikon jam bulat coral `(clock icon)` tepat sebelum teks deadline (`Sat 11 Oct 2026, 23: 59 WIB`).
* **Standar Posisi Badge di Sudut Kanan Atas (Pinned Top-Right Anti-Clustering):**
  - Badge prioritas dan sisa durasi pada kartu tugas **wajib selalu diposisikan di sudut kanan atas kartu (*pinned to top-right corner*)**:
    - Kontainer induk `Stack` wajib mengisi lebar penuh (`width: double.infinity` / `SizedBox(width: double.infinity)`) agar `Positioned(top: 0, right: 0)` tidak menyusut (*shrink-wrap*) dan menempel pada judul tugas yang pendek.
    - Kolom judul tugas wajib memiliki batas margin/padding kanan (minimal 104–120 dp) agar teks panjang terpotong rapi dengan elipsis tanpa menyentuh atau menumpuk di bawah badge.
* **Standar Token Warna Prioritas Tugas (High, Medium, Low):**
  - Penanda prioritas tugas pada seluruh kartu individual dan tim wajib disamakan dengan standar **Card Task Team**:
    - **High**: Background `AppColors.primary` (`Color(0xFFFF5E4D)`), Teks `Colors.white`.
    - **Medium**: Background `Color(0xFFFBBF24)` (Warm Amber), Teks `Color(0xFF1F2937)` (Dark Slate).
    - **Low**: Background `Color(0xFF6EE7B7)` (Mint Green), Teks `Color(0xFF064E3B)` (Dark Green).
* **Standar Kartu Tugas Tim (`TeamTaskCard`):**
  - **Sisa Waktu Deadline (Due Badge):** Wajib ditampilkan di sudut kanan atas bersanding dengan badge prioritas dalam format kapsul pill tabular figures.
  - **Tombol Edit Ikon Pensil Abu-Abu:** Tombol edit pada kartu tugas tim wajib ditempatkan di sudut kanan bawah (sejajar dengan profil anggota) berupa **logo pensil abu-abu murni** (`Icons.edit_rounded`, warna `AppColors.textMuted`) tanpa teks.
* **Protokol Pop-Up Pemberitahuan Aksi:**
  - Setiap aksi yang memicu manipulasi data (Create, Update, Delete, Submit Form) **wajib memicu Pop-Up Pemberitahuan** (`PopUpPemberitahuan` / `PopUpPemberitahuanTeam`).
  - **Gunakan template yang sudah ada di projek**. Jika belum ada aksi spesifik, buatkan metode preset pada template pop-up yang sudah ada. Jika pop-up belum ada sama sekali di projek, rancang komponen UI pop-up baru berbasis dark container (`#282D37`), icon badge berwarna, dan auto-dismiss.
* **Penanganan Aksi Destruktif:**
  - Aksi penting/destruktif (misal: batalkan pengajuan, hapus data) wajib menyediakan dialog konfirmasi atau jendela pembatalan (*Undo Window via SnackBar*).

---

## 4. Protokol Desain Gerak & Animasi Anti-Jank (60 FPS Motion)

* **Karakter Animasi:** Ringan, subtil, dan fungsional (durasi 150–350 ms).
* **Prioritas:** Utamakan Implicit Animations (`AnimatedScale`, `AnimatedContainer`, `AnimatedOpacity`) sebelum menggunakan `AnimationController`.
* **Pencegahan Memory Leak:** Setiap `AnimationController` wajib dimatikan dengan `_controller.dispose()`.
* **Optimasi AnimatedBuilder:** Selalu gunakan argumen `child` untuk komponen yang bentuk visualnya statis selama animasi berjalan.
* **Reduced Motion:** Wajib memeriksa `MediaQuery.disableAnimationsOf(context)` untuk menyediakan fallback instan tanpa animasi bagi pengguna yang sensitif terhadap gerakan.
* **Compositor Only:** Hanya animasikan `Transform` dan `Opacity`, dilarang menganimasikan `width`/`height` berulang.

---

## 5. Siklus Koreksi Mandiri (Self-Healing Loop)

Sebelum menyerahkan kode final kepada pengguna:
1. Jalankan `dart analyze` via Flutter tools untuk memastikan **0 Error dan 0 Warning**.
2. Jalankan **Taste & Anti-Slop Audit**: pastikan tidak ada gradien ungu-biru melayang, card berjejer 3 yang membosankan, atau teks klise bawaan AI.
3. Jalankan **Multi-Screen Stress Test**: uji pada lebar sempit (320–360 dp), standar (390 dp), dan tablet (768 dp) untuk memastikan **Zero Overflow**.
4. Rangkum seluruh petunjuk integrasi dan arsitektur ke dalam berkas resmi: **`README_FRONTEND.md`**.

---

## 6. Protokol Integrasi Backend & Kolaborasi Antar-Agent (Dart Frog & PostgreSQL)

### A. Peta Kapling Backend & Penanggung Jawab
Backend dikembangkan menggunakan **Dart Frog & PostgreSQL** oleh 3 engineer dengan pembagian domain resmi:

| Fitur / Halaman Frontend | Penanggung Jawab Backend | Modul / Rute Endpoint | Target Pengajuan Tiket |
| :--- | :--- | :--- | :--- |
| **Login, Autentikasi, Profil & Shift** | **Valen (Lead / Dev 1)** | `/api/v1/auth/`<br>`/api/v1/employees/`<br>`/api/v1/shifts/` | `target_dev: "DEV_1_VALEN"` |
| **Kartu Jam Presensi (Clock In/Out, Riwayat)** | **Valen (Lead / Dev 1)** | `/api/v1/attendances/`<br>`/api/v1/schedules/` | `target_dev: "DEV_1_VALEN"` |
| **Persetujuan Izin & Cuti (`LeaveApprovalPage`)** | **Dev 3 (HRD & Cuti)** | `/api/v1/leaves/` | `target_dev: "DEV_3_LEAVES"` |
| **Lembur & Rekapitulasi Laporan Bulanan** | **Dev 3 (HRD & Cuti)** | `/api/v1/overtimes/`<br>`/api/v1/reports/` | `target_dev: "DEV_3_LEAVES"` |
| **Kunjungan Lapangan & Upload Foto/Berkas** | **Royul (Dev 2 Marketing)** | `/api/v1/marketing/`<br>`/api/v1/upload/` | `target_dev: "DEV_2_ROYUL"` |

### B. Konfigurasi Lingkungan & Standar API (Dart Frog)
* **Base URL Adaptif:**
  - Android Emulator: `http://10.0.2.2:8080`
  - iOS Simulator / Chrome Web / Windows Desktop: `http://localhost:8080`
* **Format Response Baku (Envelope JSON):**
  Semua DTO & Parser di Flutter wajib membaca wrapper response standar:
  ```json
  {
    "success": true,
    "message": "Pesan deskriptif",
    "data": { ... },
    "error": null
  }
  ```
* **Autentikasi (JWT Bearer Token):**
  Semua request di bawah `/api/v1/*` wajib menyertakan header:
  `Authorization: Bearer <jwt_token>` (kecuali rute publik di bawah `/api/v1/public/*`).

### C. Alur Pengajuan Tiket Antar-Agent (*Ticket-as-Code*)
Ketika Agent Flutter membutuhkan endpoint baru, penambahan parameter, atau perubahan skema data:

1. **Buat Tiket Baru:**  
   Simpan berkas di `.agents/tickets/pending/REQ-[NOMOR]-FE-[DESKRIPSI].md`.
2. **Format Frontmatter Wajib:**
   ```yaml
   ---
   id: "REQ-001"
   title: "Endpoint Submit Approval Cuti"
   requester: "FE_FLUTTER"
   category: "API_ENDPOINT"       # Pilihan: API_ENDPOINT | DTO_UPDATE | BUGFIX_API
   status: "PENDING"              # PENDING -> IN_PROGRESS -> COMPLETED / REJECTED
   priority: "HIGH"               # Pilihan: LOW | MEDIUM | HIGH | CRITICAL
   date_created: "YYYY-MM-DD"
   target_module: "leaves"        # employees | attendances | leaves | marketing
   target_dev: "DEV_3_LEAVES"     # DEV_1_VALEN | DEV_2_ROYUL | DEV_3_LEAVES
   ---
   ```
3. **Struktur Isi Tiket:**
   - **Ringkasan Kebutuhan:** Komponen UI / Page mana yang membutuhkan data ini.
   - **Spesifikasi REST API:** HTTP Method (`GET`/`POST`/`PUT`/`DELETE`), URL Path, Request Body JSON, Expected Response JSON (200/201), dan kebutuhan Auth.
4. **Eksekusi:** Lakukan `git add` dan `git commit` tiket tersebut.
5. **Verifikasi & Konsumsi Hasil:**  
   Setelah Lead/Dev Backend menyelesaikan tiket dan memindahkannya ke `.agents/tickets/completed/`, Agent Flutter membaca bagian `## 📝 Log Eksekusi & Feedback` lalu mengimplementasikan Service & Model DTO di Flutter.
