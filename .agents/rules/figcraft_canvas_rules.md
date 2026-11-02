# 🎨 FigCraft Canvas & Bi-Directional Design System Rules
<!-- Lokasi Resmi: .agents/rules/figcraft_canvas_rules.md -->

Dokumen ini mendefinisikan aturan resmi untuk pembuatan kanvas Figma via FigCraft MCP, standarisasi Design System Day-0, protokol persetujuan skill desainer, serta alur sinkronisasi dua arah (**Prompt $\rightarrow$ Figma $\leftrightarrow$ Flutter Code**) pada proyek **IMPAL**.

---

## 1. Protokol Inisiasi Day-0 Design System di Figma

Setiap kali memulai proyek baru atau menghubungkan FigCraft ke proyek:
Agen **UI Art Director (`ui-art-director`)** WAJIB membuat satu kanvas master terpadu berjudul `[SYSTEM] Design System & Foundations` memuat **9 Pilar Utama**:

| No | Pilar Design System | Spesifikasi Kanvas Figma via FigCraft | Output Token di Flutter |
| :---: | :--- | :--- | :--- |
| **1** | **Design Direction** | Kartu filosofi visual, moodboard, tone & voice, anti-slop principles. | Catatan arsitektur UI di `README_FRONTEND.md`. |
| **2** | **Color Palette** | Swatches warna hex (Primary `#FA6144`, Background `#282D37`, Card `#323846`, Semantics `#10B981`/`#F59E0B`). Wajib uji kontras WCAG $\ge 4.5:1$. | `lib/core/theme/app_colors.dart`. |
| **3** | **Typography Scale** | Skala font Inter (Display 22sp bold, Heading 16sp, Body 13.5sp, Caption 11.5sp, Tabular Figures jam/angka). | `lib/core/theme/app_typography.dart`. |
| **4** | **8-Point Grid Spacing** | Penunjuk visual spacing: 4 (xs), 8 (sm), 12 (tight), 16 (md), 24 (lg), 32 (xl), 48 dp (2xl). | `context.rSpacing()` & konstanta padding. |
| **5** | **Concentric Border Radius** | Koleksi radius: 4dp (input), 8dp (chip), 12–16dp (card), 24dp (modal), 999dp (pill). Formula: $r_{inner} = r_{outer} - padding$. | `BorderRadius.circular()`. |
| **6** | **Core Components** | Button variants (Primary, Outlined, Ghost, Loading label tetap), TextField states, Cards, Status Pills. | `lib/core/widgets/` & modular feature widgets. |
| **7** | **5 State UI Matrix** | Frame visual percontohan 5 kondisi: Ideal, Empty (ilustrasi + motivasi), Shimmer Loading (1:1), Error Recovery, Offline Banner. | Matriks penanganan state pada presentation page. |
| **8** | **Responsive Breakpoints** | Frame acuan resolusi: Compact Mobile (320dp), Standard Mobile (390dp), Tablet (768dp). | `ResponsiveContext` adaptive layout. |
| **9** | **Accessibility (a11y)** | Kotak hitbox overlay transparan minimal **48x48 dp** pada setiap ikon/tombol interaktif. | `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`. |

---

## 2. Gerbang Persetujuan Skill Desain (Design Approval Gate)

Sebelum Design System atau komponen kanvas diekspor ke kode Flutter:
1. **Evaluasi 3 Skill Desain Wajib:**
   - **`taste-skill`:** Menilai kebersihan visual, memastikan tidak ada gradien ungu-biru melayang, layout murahan, atau elemen klise AI.
   - **`awesome-design-md`:** Mengomparasikan palet dan ritme layout dengan 84+ brand papan atas (Linear, Stripe, Apple, Supabase).
   - **`web-interface-guidelines`:** Memeriksa kepatuhan rasio kontras WCAG, radius konsentris, dan tap target $\ge 48\times 48\text{ dp}$.
2. **Siklus Perbaikan Berulang (Self-Correction Loop):**
   - Jika ditemukan kekurangan (misal kontras gagal atau auto-layout tidak proporsional): Agen **WAJIB langsung merevisi kanvas Figma via FigCraft**.
   - Dilarang melanjutkan ke coding Flutter sebelum status evaluasi menyatakan:
     ```text
     STATUS: DESIGN SYSTEM APPROVED (TASTE: ELITE, ACCESSIBILITY: PASS, AESTHETICS: PASS)
     ```
3. **Dokumentasi Audit:** Menerbitkan laporan ringkas `DESIGN_SYSTEM_AUDIT_REPORT.md`.

---

## 3. Matriks Translasi Tiga Arah (Tri-Directional Mapping)

### A. Flutter Code $\rightarrow$ Figma Canvas (Reverse Engineering)
Ketika kode widget Flutter diubah menjadi komponen native Figma via FigCraft:

| Elemen Kode Flutter | Node Figma yang Dihasilkan (FigCraft) | Properti Auto-Layout |
| :--- | :--- | :--- |
| `Column(...)` | `FrameNode` | LayoutMode: `VERTICAL`, PrimaryAxisAlign: `MIN` |
| `Row(...)` | `FrameNode` | LayoutMode: `HORIZONTAL`, CounterAxisAlign: `CENTER` |
| `EdgeInsets.symmetric(h: 16, v: 12)` | `FrameNode` | `paddingLeft/Right = 16`, `paddingTop/Bottom = 12` |
| `SizedBox(height: 16)` | `FrameNode` | `itemSpacing = 16` |
| `BorderRadius.circular(16)` | `FrameNode` / `RectangleNode` | `cornerRadius = 16` |
| `BoxDecoration(color: Color(0xFF323846))` | `FrameNode` | Fills: Solid Hex `#323846` |
| `Text('Title', style: TextStyle(...))` | `TextNode` | Font family, weight, size, fills (color) |
| `BoxShadow(...)` | `FrameNode` | Effects: `DROP_SHADOW` (offset X/Y, blur, color) |

### B. Figma Canvas $\rightarrow$ Flutter Code (Direct Compilation)
Node yang diseleksi di Figma diterjemahkan menjadi kode Flutter:
- Auto-Layout Vertical $\rightarrow$ `Column` dengan `ResponsiveContext` spacing.
- Auto-Layout Horizontal $\rightarrow$ `Row` atau `Wrap`.
- Fill Color $\rightarrow$ Pemetaan ke `AppColors` token (bukan hardcoded Color di presentation).
- Component Variants $\rightarrow$ Enum/State model pada widget.

---

## 4. Konvensi Penamaan Layer di Figma
Untuk mencegah kanvas berantakan:
- Format nama Frame utama: `[Fitur] / [Halaman] / [Komponen]`
  *(Contoh: `Task / Detail / TaskStatusCard`)*
- Komponen Design System: `[SYSTEM] / [Kategori] / [Nama]`
  *(Contoh: `[SYSTEM] / Button / Primary-Default`)*
- Layer dilarang bernama default mentah seperti `Frame 1234`, `Rectangle 56`, atau `Group 89`.

---

## 📌 Checklist Verifikasi Kanvas (Pre-Export Checklist)
Sebelum menyerahkan komponen ke Senior Flutter Builder:
- [ ] 1. Apakah seluruh elemen dibungkus dengan Auto-Layout yang benar? *(Dilarang posisi absolut bebas)*
- [ ] 2. Apakah formula nested border radius telah konsentris ($r_{inner} = r_{outer} - padding$)?
- [ ] 3. Apakah kontras teks terhadap latar belakang lolos minimal WCAG 4.5:1?
- [ ] 4. Apakah touch target tombol minimal 48x48 dp?
- [ ] 5. Apakah komponen memiliki varian 5 state (Ideal, Empty, Shimmer, Error, Offline)?
