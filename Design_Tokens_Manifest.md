# 🎨 Design Tokens Manifest — IMPAL Smart ToDoList

Issued by: **UI Art Director (Subagent 1)**  
Compliance: `AGENTS.md` & Figma Design Tokens Specifications  
Status: **Locked & Active**

---

## 1. Palet Warna Baku (Hex Precision Palette)

### A. Surfaces & Backgrounds
| Token Name | Hex Code | Color Literal | Penggunaan |
| :--- | :--- | :--- | :--- |
| `bgPrimary` | `#282D37` | `Color(0xFF282D37)` | Background utama Scaffold & recessed pocket navbar |
| `bgSecondary` | `#1E222B` | `Color(0xFF1E222B)` | Backdrop desktop web / frame pembungkus |
| `bgCard` | `#323846` | `Color(0xFF323846)` | Kartu jadwal, container form, navbar shell |
| `bgDialog` | `#282D37` | `Color(0xFF282D37)` | Permukaan modal dialog & picker |

### B. Brand Accent (Coral Engine)
| Token Name | Hex Code | Color Literal | Penggunaan |
| :--- | :--- | :--- | :--- |
| `primary` | `#FA6144` | `Color(0xFFFA6144)` | Tombol CTA utama, lingkaran floating aktif navbar |
| `primaryGradientStart`| `#FF7253` | `Color(0xFFFF7253)` | Titik awal gradien coral tombol aktif navbar |
| `primaryGradientEnd` | `#FA6144` | `Color(0xFFFA6144)` | Titik akhir gradien coral tombol aktif navbar |
| `primaryAccent` | `#FF7D65` | `Color(0xFFFF7D65)` | Subtitle header (`10 task pending`), link aksen |
| `primaryLight` | `#FF826E` | `Color(0xFFFF826E)` | Badge status `Ongoing`, aksen garis kuliah |

### C. Typography & Text Hierarchy
| Token Name | Hex Code | Opacity / Role |
| :--- | :--- | :--- |
| `textWhite` | `#FFFFFF` | Headings, judul kartu, teks tombol aktif (100%) |
| `textBody` | `#D1D5DB` | Deskripsi konten, body text (82%) |
| `textMuted` | `#8E95A5` | Label form, teks waktu, ikon sekunder (55%) |
| `textSubtle` | `#6B7280` | Placeholder input, copyright, hint (42%) |

### D. Semantic Status Colors
| Status | Accent Hex | Badge Background | Badge Border |
| :--- | :--- | :--- | :--- |
| **Ongoing** | `#FF826E` | `#FF826E` | Solid Coral |
| **Completed** | `#10B981` | `#10B981` (Alpha 18%) | `#10B981` (Alpha 40%) |
| **Upcoming** | `#8E95A5` | `#8E95A5` (Alpha 15%) | `#8E95A5` (Alpha 35%) |
| **Destructive / Error** | `#EF4444` | `#EF4444` (Alpha 15%) | Solid Red `#EF4444` |

---

## 2. Formula Tipografi Adaptif (`ResponsiveContext`)

Dilarang keras menggunakan ukuran font piksel mati. Skala tipografi dihitung proporsional terhadap baseline layar 390 dp:

$$\text{fontSize} = \text{clamp}\left( \text{base} \times \frac{\text{effectiveWidth}}{390}, \text{min}, \text{max} \right)$$

### Skala Baku Tipografi
- **Screen Title (`Hi Jarvis`)**: `context.rFont(22, min: 20, max: 26)`, Weight: 700, Letter-spacing: -0.3.
- **Section Subtitle (`10 task pending`)**: `context.rFont(12.5, min: 11.5, max: 14)`, Weight: 600, Letter-spacing: 0.15.
- **Card Title (`Schedule / Task`)**: `context.rFont(13.5, min: 12.5, max: 15)`, Weight: 600, Letter-spacing: -0.1.
- **Time & Numerical Labels**: `context.rFont(11.5, min: 10.5, max: 13)`, Weight: 500 + `FontFeature.tabularFigures()`.
- **Button CTA**: `context.rFont(14, min: 13, max: 16)`, Weight: 600, Letter-spacing: 0.15.

---

## 3. Formula Nested Border Radius Konsentris

Untuk mencegah efek sudut gepeng atau distorsi lengkungan saat kontainer bertingkat ditumpuk, radius elemen dalam ($r_{inner}$) dihitung secara geometris:

$$r_{inner} = \max\left(0, r_{outer} - \text{padding}\right)$$

### Contoh Penerapan pada IMPAL UI:
- **Card Container**: $r_{outer} = 12\text{px}$, Padding = $14\text{px} \implies r_{inner} = 0\text{px}$ (tepi menyatu rata).
- **Dialog Modal**: $r_{outer} = 24\text{px}$, Padding = $16\text{px} \implies r_{inner} = 8\text{px}$ pada card input waktu di dalamnya.
- **Header Avatar Frame**: $r_{outer} = 999\text{px}$ (Lingkaran), Padding = $1.5\text{px} \implies r_{inner} = 999\text{px}$.

---

## 4. Layered Shadows & Glow Tokens

```dart
// Floating Active Nav Button Glow
static const List<BoxShadow> primaryGlowShadow = [
  BoxShadow(
    color: Color(0x80FA6144),
    blurRadius: 18,
    spreadRadius: 1,
    offset: Offset(0, 6),
  ),
];

// Card Subtle Shadow (Anti-Overdraw Optimized)
static const List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Color(0x33000000),
    blurRadius: 10,
    offset: Offset(0, 3),
  ),
];

// Modal Dialog Elevation Shadow
static const List<BoxShadow> dialogShadow = [
  BoxShadow(
    color: Color(0x99000000),
    blurRadius: 35,
    offset: Offset(0, 18),
    spreadRadius: -4,
  ),
];
```

