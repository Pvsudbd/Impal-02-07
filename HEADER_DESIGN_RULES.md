# Standarisasi Desain Header & Tombol Back (IMPAL Design System)

Dokumen ini mendefinisikan aturan dan spesifikasi standar untuk komponen **Header Halaman** (seperti pada *Schedule Page*, *Team List Page*, dan halaman turunan lainnya) serta komponen **Tombol Back** di seluruh aplikasi **IMPAL**.

---

## 1. Prinsip Utama Keserasian Header

Seluruh header halaman internal/tab wajib memiliki struktur, dimensi, tipografi, dan perataan yang serasi:
1. **Tata Letak Baris (*Row Layout*)**:
   - `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center)`
   - Sisi kiri (`Expanded`): Memuat tombol back (kondisional) + kolom judul & subjudul.
   - Sisi kanan: Avatar inisial pengguna dengan lingkaran konsisten.
2. **Padding Halaman**:
   - `SliverPadding(padding: const EdgeInsets.fromLTRB(20, 14, 20, ...))`
   - Jarak pemisah ke section/komponen berikutnya seragam: `const SizedBox(height: 16)`.

---

## 2. Spesifikasi Tombol Back (*Square Back Button*)

> **Aturan Wajib**: Tombol back **TIDAK BOLEH** berbentuk lingkaran (`circle`/`999px`). Tombol back wajib berupa **kotak sudut membulat (*rounded square*)** dengan ikon panah di tengahnya.

| Properti | Nilai Standar | Keterangan |
| :--- | :--- | :--- |
| **Bentuk (*Shape*)** | Kotak membulat (*Rounded Square*) | Menggunakan `BoxDecoration(borderRadius: BorderRadius.circular(10))` |
| **Ukuran (*Dimension*)** | **`38px` × `38px`** | Touch target ergonomis & proporsional dengan avatar 42px |
| **Border Radius** | **`10px`** | Sudut membulat halus konsisten dengan modal dialog |
| **Warna Latar (*Background*)** | `#323846` (`Color(0xFF323846)`) | Warna permukaan container card IMPAL |
| **Garis Batas (*Border*)** | `1px solid #3B4150` | Border halus memperjelas batas tombol di mode gelap |
| **Ikon Panah (*Icon*)** | `Icons.arrow_back_ios_new_rounded` | Ikon chevron/arrow modern bersudut lengkung |
| **Ukuran Ikon (*Icon Size*)** | **`16px`** | Proporsional di dalam kotak 38px |
| **Warna Ikon (*Icon Color*)** | `Colors.white` (`#FFFFFF`) | Kontras tinggi terhadap latar `#323846` |
| **Gap ke Teks Judul** | **`12px`** (`SizedBox(width: 12)`) | Skala spacing `sm` IMPAL |

### Cuplikan Kode Flutter Standar (*Reference Snippet*):
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onBack ?? () => Navigator.of(context).maybePop(),
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3B4150), width: 1),
      ),
      child: const Center(
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    ),
  ),
)
```

---

## 3. Spesifikasi Tipografi Header (Judul & Subjudul)

Kolom judul ditempatkan di dalam `Expanded(child: Column(...))` dengan `crossAxisAlignment: CrossAxisAlignment.start` dan `mainAxisSize: MainAxisSize.min`:

### A. Teks Judul Utama (Greeting)
- **Teks**: `'Hi <UserName>'` (contoh: `'Hi Jarvis'`)
- **Font Family**: `'Inter'`
- **Ukuran (*Font Size*)**: **`22px`**
- **Ketebalan (*Font Weight*)**: `FontWeight.w700` (Bold)
- **Warna Teks**: `Colors.white` (`#FFFFFF`)
- **Letter Spacing**: `-0.3`
- **Line Height**: `1.2`
- **Overflow**: `TextOverflow.ellipsis`

### B. Gap Antara Judul & Subjudul
- **Tinggi Gap**: **`3px`** (`const SizedBox(height: 3)`)

### C. Teks Subjudul (Kategori / Konteks Halaman)
- **Teks**:
  - Halaman Dashboard: `'10 task pending'`
  - Halaman Schedule: `'Schedule'`
  - Halaman Team List: `'Team List'`
- **Font Family**: `'Inter'`
- **Ukuran (*Font Size*)**: **`12.5px`**
- **Ketebalan (*Font Weight*)**: `FontWeight.w600` (SemiBold)
- **Warna Teks**: `#FF7D65` (`Color(0xFFFF7D65)`) — Coral Brand Accent
- **Letter Spacing**: `+0.15`
- **Overflow**: `TextOverflow.ellipsis`

---

## 4. Spesifikasi Avatar Pengguna (Sisi Kanan)

Avatar inisial pengguna di sisi kanan header berfungsi sebagai pengenal akun sekaligus anchor visual:

| Properti | Nilai Standar | Keterangan |
| :--- | :--- | :--- |
| **Ukuran (*Dimension*)** | **`42px` × `42px`** | Serasi dengan ketinggian area judul + subjudul |
| **Bentuk (*Shape*)** | Lingkaran (`BoxShape.circle`) | Membedakan kontras bentuk dengan tombol back yang kotak |
| **Warna Latar** | `#323846` (`Color(0xFF323846)`) | Konsisten dengan palet latar surface |
| **Garis Batas (*Border*)** | `1px solid #3B4150` | Border outline lembut |
| **Inisial Pengguna** | 2 Huruf Kapital (contoh: `JS`, `JD`) | Diambil dari nama pengguna |
| **Font Style Inisial** | `13.5px`, `w700`, `letterSpacing: 0.2` | Warna abu-abu muted `#8E95A5` |

---

## 5. Ringkasan Implementasi Komponen Header Penuh

```dart
Widget _buildHeader() {
  final initials = _getUserInitials(widget.userName);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Row(
          children: [
            if (widget.showBackButton) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF323846),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3B4150), width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hi ${widget.userName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '<Page Subtitle>', // e.g. 'Schedule' or 'Team List'
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFFF7D65),
                      fontSize: 12.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF323846),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3B4150), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF8E95A5),
            fontSize: 13.5,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    ],
  );
}
```
