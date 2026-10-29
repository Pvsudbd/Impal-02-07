# 🎞️ Motion Design Spec — 60 FPS Anti-Jank Engine

Issued by: **Motion Animator & VFX Engineer (Subagent 3)**  
Compliance: `AGENTS.md` Section 4 & Section 2 (HP Kentang Optimization)  
Status: **Locked & Active**

---

## 1. Karakter Animasi & Durasi

- **Durasi Standar**: 150 ms – 350 ms.
- **Kurva Gerak Baku (Awwwards Harmonic Motion)**:
  - Perpindahan Tab Navbar: `Curves.easeInOutCubic` (350 ms).
  - Cross-fade Halaman / Form: `Curves.easeOut` (140 ms masuk) dan `Curves.easeIn` (100 ms keluar).
  - Micro-interaction Tekan Tombol (*Bounce Press Feedback*): `Curves.easeInOut` (120 ms).

---

## 2. Reduced Motion Fallback (`MediaQuery.disableAnimationsOf(context)`)

Semua komponen animasi wajib mematuhi preferensi aksesibilitas pengguna:
```dart
final disableMotion = MediaQuery.disableAnimationsOf(context);
final effectiveDuration = disableMotion ? Duration.zero : const Duration(milliseconds: 350);
```
- Jika pengguna mengaktifkan "Reduce Motion" di perangkat mereka, durasi animasi otomatis menjadi `Duration.zero` (transisi instan tanpa efek pemicu pusing/vertigo).

---

## 3. Compositor-Only Principle (Anti-Jank HP Kentang)

1. **Hanya Gerakkan `Transform` dan `Opacity`**:
   - Dilarang keras menganimasikan `width` atau `height` berulang kali di dalam loop animasi karena memicu *layout pass* dan *relayout boundary invalidation*.
   - Gunakan `Transform.scale` / `AnimatedScale` dan `Opacity` / `AnimatedOpacity`.
2. **Isolasi Rendering (`RepaintBoundary`)**:
   - Bungkus komponen yang sering mengalami animasi (misalnya Scoop Navbar Painter dan Carousel Auto-scroll) dengan `RepaintBoundary` agar kartu atau background statis di sekitarnya tidak ikut di-*repaint*.
3. **Pembersihan Kontroller Memori (`dispose()`)**:
   - Semua `AnimationController` lokal diwajibkan memanggil `_controller.dispose()` di dalam `dispose()` lifecycle.

---

## 4. Mikro-Interaksi Tombol Baku (`AppButton`)

Ketika tombol disentuh (`onHighlightChanged`), tombol menyusut halus ke skala `0.98` lalu membal kembali:
```dart
AnimatedScale(
  scale: (_isPressed && _isEnabled && !disableMotion) ? 0.98 : 1.0,
  duration: disableMotion ? Duration.zero : const Duration(milliseconds: 120),
  curve: Curves.easeInOut,
  child: ...,
)
```
Teks label tombol **tetap dipertahankan** di samping spinner saat loading untuk mencegah layout shift.

