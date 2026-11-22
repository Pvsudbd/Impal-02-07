# User Manual Rules & Implementation Guide
<!-- Lokasi Resmi: .agents/rules/user_manual_rules.md -->

Dokumen ini merangkum seluruh aturan baku pembuatan **User Manual** berdasarkan materi perkuliahan Telkom University (Slide 22–26) serta standar acuan **ISO/IEC/IEEE 26514:2022** sebagai panduan wajib sebelum menyusun dokumentasi pengguna untuk proyek **IMPAL**.

---

## 1. Filosofi, Komponen Utama & Kapan Dibuat

### A. Komponen Terpenting
User manual berfokus pada dua hal utama:
1. **Antarmuka (UI)** yang dilihat oleh pengguna.
2. **Tugas (*task*)** yang perlu diselesaikan oleh pengguna.

> **Aturan Penyusunan:** Susun dokumen **berdasarkan tugas** (contoh: *"Mencetak struk transaksi"*), **BUKAN berdasarkan susunan menu**.

### B. Kapan User Manual Dibuat & Diperbarui
- Dibuat **setelah pengembangan selesai**, mengikuti versi rilis perangkat lunak.
- Wajib **diperbarui setiap kali antarmuka (UI) atau alur kerja (*flow*) berubah**.

### C. Dua Bentuk User Manual yang Sah
| Bentuk | Contoh Implementasi |
| :--- | :--- |
| **Hardcopy / PDF** | Buku panduan cetak, file PDF yang dapat diunduh, atau kartu ringkas (misal: di meja kasir). |
| **Online Help** | Situs bantuan dengan fitur pencarian (*searchable*), bantuan di dalam aplikasi (*tooltip*, panduan langkah pertama/*onboarding*), atau video singkat. |

---

## 2. Isi Wajib & Cakupan Rilis Formal

### A. Empat Komponen Wajib (Mandatory)
Setiap user manual **wajib** memuat empat hal berikut:

| Komponen Wajib | Ketentuan Isi |
| :--- | :--- |
| **1. Prosedur Operasional** | Langkah-langkah **bernomor** (`1, 2, 3, ...`) untuk setiap tugas pengguna. |
| **2. Tangkapan Layar (Screenshot / SS) UI** | **WAJIB** menyertakan screenshot aktual dari antarmuka (UI) yang dilihat pengguna pada setiap tugas/langkah kunci, agar pengguna langsung mengenali tombol, form, atau layar yang dimaksud. |
| **3. Pesan Error & Penanganannya** | Penjelasan **arti pesan**, **penyebab**, dan **cara mengatasinya**. |
| **4. Fitur Navigasi** | Daftar isi, judul dan subjudul, nomor halaman, **indeks** (wajib jika dokumen **> 40 halaman**), dan fitur pencarian. |

### B. Pelengkap (Opsional / Tidak Wajib)
- Daftar gambar.
- Daftar tabel.

### C. Lima Area yang Harus Tercakup Saat Rilis Formal
Tidak harus dipisah menjadi lima dokumen berbeda, namun **kelima topik berikut harus tercakup**:
1. **Deskripsi fungsional** — penjelasan fungsi dan kemampuan sistem.
2. **Instruksi instalasi** — cara memasang dan menyiapkan perangkat lunak.
3. **Manual pengantar** — panduan dasar untuk pengguna baru agar cepat mulai.
4. **Manual referensi** — katalog fakta, daftar perintah, atau daftar pesan error untuk dicari cepat.
5. **Panduan administrator** — pengelolaan sistem, konfigurasi, dan manajemen hak akses/data oleh admin.

---

## 3. Struktur & Kedalaman Navigasi

### A. Batas Maksimal Kedalaman Subtopik
Kedalaman penomoran subtopik dibatasi **maksimal 3 level di bawah bab**:

```text
1        Transaksi Penjualan          (Bab)
1.2      Membuat transaksi baru       (Level 1)
1.2.3    Memasukkan kode barang       (Level 2)
1.2.3.4  Ubah jumlah item             (Level 3 — TERDALAM YANG DIIZINKAN)
```

> **Larangan (`1.2.3.4.5`):** Jika mencapai 4 level di bawah bab (`x.x.x.x.x`), struktur dianggap **terlalu dalam** dan **wajib dipecah menjadi topik baru**.

### B. Penyusunan Daftar Pesan Error
- Untuk memudahkan pencarian pada mode referensi, daftar pesan error lebih baik **disusun berdasarkan urutan abjad**.

### C. Pemecahan Dokumen Per Volume (Untuk Perangkat Lunak Besar)
Satu volume raksasa sulit digunakan. Terapkan prinsip **satu volume untuk satu jenis pembaca (role)**:

| Volume | Target Pembaca | Contoh Ruang Lingkup |
| :--- | :--- | :--- |
| **Vol. 1** | *End User* (Pengguna akhir / Kasir) | Operasional harian & penyelesaian tugas pengguna. |
| **Vol. 2** | Admin / Pengelola | Kelola data master, barang, harga, atau pengaturan bisnis. |
| **Vol. 3** | Tim IT / Teknis | Instalasi, konfigurasi sistem, dan pemeliharaan. |

---

## 4. Pendekatan Modern: Docs-as-Code & Kerangka Diátaxis

### A. Empat Jenis Isi (Kerangka Diátaxis)
| Jenis Isi | Tujuan | Contoh Topik | Padanan Formal |
| :--- | :--- | :--- | :--- |
| **Tutorial** | Belajar sambil praktik | *"Transaksi pertamamu"* | Dekat dengan **Manual Pengantar** |
| **Panduan How-To** | Menyelesaikan satu tugas spesifik | *"Cara membatalkan item"* | Prosedur operasional per tugas |
| **Referensi** | Fakta cepat untuk dicari | *"Daftar pesan error"* | Dekat dengan **Manual Referensi** |
| **Penjelasan** | Memahami alasan / konsep di balik sistem | *"Cara diskon dihitung"* | Penjelasan logika / aturan bisnis |

### B. Praktik Docs-as-Code
- Ditulis menggunakan format **Markdown** dan disimpan di **repositori yang sama dengan kode program**.
- Ikut ditinjau (*review*) melalui **Pull Request (PR)** dan diberi **versi bersama rilis aplikasi**.
- Dapat dibangun menjadi situs dokumentasi statis menggunakan **MkDocs**, **Docusaurus**, atau **GitHub Pages**.

### C. Standar Acuan Resmi
- **IEEE 1063-2001** sudah berstatus *superseded* (digantikan).
- Standar acuan terkini yang berlaku adalah **`ISO/IEC/IEEE 26514:2022`**.

---

## 5. Standar Estetika & Tata Letak Visual (Minimalis Apple + Full Dark Mode Aplikasi)

User manual **tidak boleh kaku seperti teks polos**, tetapi juga **dilarang ramai, penuh kotak warna-warni, atau penuh lencana mencolok (*visual clutter*)**. Gabungkan **kesederhanaan editorial minimalis ala Apple** (*Quiet Chrome*) dengan **Full Dark Mode & palet warna resmi aplikasi IMPAL ([design_tokens.md](file:///C:/Telkom/Smt%205/IMPAL/Code/Impal-02-07/.agents/rules/design_tokens.md))**:

1. **Full Dark Mode Edge-to-Edge & Palet Warna Resmi Aplikasi:**
   - **Kanvas Gelap Penuh (*Full-Bleed*):** Seluruh halaman PDF menggunakan latar gelap `#1E222B` (`bgSecondary`) penuh hingga tepi halaman (**tanpa margin putih sisa kertas**), dipadukan permukaan lembut `#282D37` (`bgPrimary`) atau `#323846` (`bgCard`) dan garis pemisah *hairline* `#323846` / `#3B4150`.
   - **Hierarki Teks Gelap:** Judul utama `#FFFFFF` (`textWhite`), teks isi `#D1D5DB` (`textBody`), dan teks sekunder/metadata `#8E95A5` (`textMuted`) & `#6B7280` (`textSubtle`).
   - **Satu Warna Aksen Merek (`#FA6144`):** Gunakan **Coral `#FA6144`** (`primary`) sebagai satu-satunya aksen utama (label pembuka, angka langkah inti `1`–`3`, nomor halaman Daftar Isi). **Dilarang** memakai biru generik (`#0066CC`) atau gradien dekoratif.
   - **Warna Semantik Baku Aplikasi:** Gunakan `#10B981` untuk status berhasil (`OK`) dan `#EF4444` / `#FF7D65` untuk pesan dan penanda error (`A`–`B`) agar kontras terbaca jelas di atas kanvas gelap.
2. **Tipografi Bersih & *Whitespace* Lapang:**
   - Gunakan font sans-serif modern berkarakter editorial (`SF Pro` / `Inter` / `Segoe UI`) dengan *tracking* judul agak rapat, bobot seimbang, dan ruang kosong (*whitespace*) lega agar halaman terasa ringan.
   - **Hindari Kotak Berlapis (*Over-Carding*):** Sajikan langkah bernomor sebagai daftar bersih yang dipisahkan garis *hairline* tipis—jangan membungkus setiap langkah ke dalam kotak berbingkai terpisah.
3. **Presentasi Screenshot (SS) UI yang Tajam, Fokus & Tanpa Bayangan Keruh:**
   - Tampilkan SS UI dengan sudut membulat presisi (`14–16px`) dan **garis tepi *hairline* tipis terang yang tajam** (`1px solid #3B4150` atau putih transparan halus `rgba(255, 255, 255, 0.14)`) langsung di pinggir gambar tanpa bingkai tambahan—**DILARANG** memakai *drop-shadow* blur besar (`box-shadow` dengan blur lebar) di PDF.
   - **Screenshot Fokus (*Cropped Focus*):** Untuk elemen kecil seperti banner notifikasi atau *toast*, **WAJIB memotong (*crop*) screenshot** pada area terkait agar teks tampil besar dan terbaca jelas.
   - **Anotasi Tenang & Selaras Warna App:** Gunakan lingkaran angka (`1`, `2`, `3` berwarna Coral `#FA6144`) dan huruf opsi (`a`, `b` berwarna Slate `#4B5563`), `OK` (`#10B981`), serta `A`–`B` (`#EF4444`) tanpa kotak garis bertumpuk. Penanda **dilarang menimpa teks UI penting**.
   - **Sinkronisasi Pasca Perubahan UI:** Setiap kali teks, *placeholder*, atau elemen UI berubah di kode, **WAJIB mengambil ulang screenshot terbaru** sebelum menerbitkan user manual.
4. **Callout & Tabel Bersih Tanpa Dekorasi Berlebihan:**
   - Blok catatan (*Sebelum Mulai*, *Tips*) cukup berupa permukaan `#282D37` bersudut membulat halus tanpa garis tebal warna-warni di sisi kiri dan tanpa emoji berlebihan.
   - Tabel error memakai garis horizontal *hairline* tipis (`#323846`) dengan jarak baris lega (*breathing room*).
5. **Kemasan Dokumen Minimalis (Khusus PDF):**
   - Halaman pertama langsung dibuka dengan *editorial header* yang bersih, ringkas, dan modern di atas kanvas gelap `#1E222B`, serta *header/footer* tipis berhuruf kecil (`#8E95A5`) menyatu di dalam tiap halaman penuh.

---

## 6. Prinsip Keringkasan, Fokus Langkah & Bahasa Pengguna

Agar user manual **tidak bertele-tele** dan langsung bisa diikuti pengguna akhir (*end user*):

1. **Panjang Dokumen Proporsional (*Concise & To-the-Point*):**
   - Sesuaikan jumlah halaman dengan kompleksitas tugas. Panduan untuk **1 fitur sederhana** (misal: Login) idealnya dirangkum dalam **2–3 halaman** padat yang rapi, tidak perlu dipecah menjadi 5+ halaman dengan banyak ruang kosong.
   - Setiap langkah operasional maksimal **1–2 kalimat aktif yang singkat**. Hindari menjelaskan cara kerja internal UI (seperti animasi *loading* atau *auto-dismiss keyboard*) kecuali berdampak langsung pada tindakan pengguna.
2. **Pisahkan Langkah Inti vs Opsi/Tautan Alternatif:**
   - Nomor langkah berurutan (`1`, `2`, `3`, ...) **hanya digunakan untuk alur utama wajib** hingga tugas selesai.
   - Fitur opsional (misal: ikon lihat sandi, *Remember me*) atau navigasi ke tugas lain (misal: *Forgot password?*, *Register Now*) dipisahkan ke bagian **Opsi & Tautan Bantuan** (menggunakan penanda huruf `a`, `b`, `c` agar tidak membingungkan urutan langkah inti).
3. **100% Bahasa Pengguna (*Zero Developer Jargon*):**
   - **DILARANG** mencantumkan istilah kode atau arsitektur internal (seperti nama kelas `HomePage`, kunci penyimpanan `is_logged_in`, `SharedPreferences`, atau `viewport < 600 dp`) pada panduan untuk pengguna akhir. Ganti dengan bahasa manusia (*"halaman Beranda/Dashboard"*, *"sesi masuk tersimpan otomatis"*).
4. **Aliran Halaman Tanpa Ruang Kosong Mubazir:**
   - Hindari *forced page break* yang menyisakan subtopik berisi hanya 1–2 baris lalu melompat ke halaman baru. Kelompokkan subtopik terkait secara seimbang.
5. **Akurasi Alur Bisnis, Target Pengguna Umum & Konsistensi Label (*Functional & Label Accuracy*):**
   - **Target Pengguna Umum:** Aplikasi ini ditujukan **untuk semua orang (pengguna umum)**, bukan eksklusif mahasiswa atau email kampus. Gunakan sapaan netral (*"pengguna"* / *"akun Anda"*), jangan membatasi hanya *"mahasiswa"* atau *"email kampus"*.
   - **Kredensial Login Aktual:** Form Login **hanya menerima Username atau Email umum** (misal `@gmail.com`) dan **TIDAK menerima Student ID / NIM**. **DILARANG** menyuruh pengguna menyiapkan atau memasukkan NIM / Student ID.
   - **Konsistensi Penamaan Label:** Penyebutan nama kolom/tombol pada langkah, *caption* gambar, dan tabel error **wajib 100% seragam** dengan label aktual di layar (contoh: tulis `kolom Username or Email`, bukan hanya `kolom Username`).

---

## 7. Template Standar Satu Halaman Tugas User Manual

Gunakan struktur baku berikut saat menulis setiap topik tugas (mengacu pada contoh `2.3 Mencetak struk transaksi`):

```markdown
## [Nomor Bab.Subtopik] [Nama Tugas dengan Kata Kerja Aktif]
<!-- Contoh: 2.3 Mencetak struk transaksi -->

**Tujuan:** [Jelaskan tujuan tugas dalam satu kalimat singkat dan jelas.]

**Sebelum mulai:** [Sebutkan prasyarat sebelum menjalankan tugas, misal: transaksi sudah dibayar / pengguna sudah login.]

**Langkah Inti:**
1. ...
2. ...
3. ...

**Opsi & Tautan Terkait (Opsional):**
- **a.** [Fungsi opsi tambahan pada layar]
- **b.** [Tautan alternatif bila relevan]

   ![Screenshot UI Langkah Tugas Teranotasi](path/ke/ss_ui_tugas.png)
   *(**WAJIB:** Sertakan tangkapan layar/SS UI aktual beresolusi tajam dengan bingkai rapi dan anotasi angka `1 2 3` untuk langkah inti serta `a b` untuk opsi, sesuai dengan UI versi rilis terbaru.)*

> 💡 **Tips:** [Opsional — sisipkan trik singkat atau jalan pintas yang membantu pengguna bekerja lebih cepat.]

**Jika muncul pesan error:**

| Pesan | Penyebab | Cara Menangani |
| :--- | :--- | :--- |
| `[Teks pesan error 1]` | [Penyebab terjadinya error] | [Langkah konkret mengatasi error] |
| `[Teks pesan error 2]` | [Penyebab terjadinya error] | [Langkah konkret mengatasi error] |

*(Standar minimal: sertakan minimal 2 pesan error yang relevan pada setiap halaman panduan tugas bila memungkinkan.)*

**Lihat juga:** [Nomor & Judul Topik Terkait] *(contoh: `2.4 Membatalkan transaksi`)*
```

---

## 8. Uji Kelayakan & Checklist Verifikasi Akhir

Sebelum user manual dinyatakan selesai, lakukan dua tahap validasi berikut:

### A. Uji Pengalaman Pengguna (*Peer / Blind Usability Test*)
- Berikan dokumen kepada rekan/penguji yang belum familiar dengan alurnya (*peer review* / tukar antar kelompok).
- **Pertanyaan Uji:** *"Bisakah pengguna baru mengikuti seluruh langkah tanpa perlu bertanya?"* Jika masih ada kebingungan, perjelas langkah atau tambahkan tangkapan layar UI.

### B. Checklist Verifikasi Wajib
- [ ] **Susunan Berbasis Tugas:** Topik disusun per tugas (*task-based*), bukan per daftar menu.
- [ ] **Langkah Inti Bernomor & Singkat:** Langkah inti hanya memuat alur wajib dengan kalimat ringkas (maks 1–2 kalimat per langkah), terpisah dari opsi/tautan alternatif.
- [ ] **Bebas Jargon Teknis:** Tidak ada nama kelas, variabel, atau istilah kode untuk panduan pengguna akhir.
- [ ] **Akurat Sesuai Alur & Target Pengguna:** Kredensial sesuai alur nyata (hanya **Username atau Email umum**, bukan Student ID/NIM), ditujukan untuk **semua pengguna** (bukan khusus kampus), dan nama label pada teks/caption 100% seragam dengan UI aktual.
- [ ] **Screenshot (SS) UI Wajib Ada, Fokus & Teranotasi:** Setiap panduan tugas menyertakan SS UI terbaru yang tajam, ter-crop fokus bila berupa banner/elemen kecil, dan penanda (`1 2 3` / `a b` / `OK`) tidak menimpa teks UI penting.
- [ ] **Estetika Minimalis & Full Dark Mode Aplikasi:** Tata letak tenang ala Apple (*whitespace* lega, tanpa *over-carding*), latar gelap `#1E222B` *full-bleed* tanpa margin putih, panel `#282D37`, tepi screenshot *hairline* `#3B4150` tanpa shadow keruh, aksen `#FA6144`, `#FFFFFF`/`#D1D5DB` teks, `#10B981` sukses, dan `#EF4444` error.
- [ ] **Sinkron dengan Rilis & UI:** Seluruh tangkapan layar (SS) dan langkah sesuai dengan versi UI terbaru (tidak memakai SS lama/usang).

---

## 9. Anti-Patterns (Hal yang Dilarang)
- **DILARANG** menyusun panduan tugas hanya berupa teks tanpa menyertakan tangkapan layar (SS) dari antarmuka (UI) aktual, memakai SS buram/terpotong tanpa bingkai, atau menggunakan SS versi lama yang tidak cocok dengan UI saat ini.
- **DILARANG** menulis petunjuk secara bertele-tele, mengulang informasi yang sama di banyak tempat, atau mencampur tautan alternatif ke dalam nomor langkah inti.
- **DILARANG** menyebut istilah internal kode (nama widget/class/key storage) di dalam panduan *end user*.
- **DILARANG** meminta pengguna menyiapkan atau menginput data yang tidak didukung alur sistem (misal: menyuruh menyiapkan NIM / Student ID saat form hanya menerima **Username atau Email umum**), atau membatasi target pengguna seolah hanya untuk kalangan kampus.
- **DILARANG** memperkecil screenshot seluruh layar untuk elemen kecil (seperti banner notifikasi) hingga tulisannya sulit dibaca, serta **DILARANG** menempatkan penanda anotasi di atas teks UI penting.
- **DILARANG** memberi `box-shadow` dengan blur lebar/keruh pada gambar screenshot PDF; gunakan tepi *hairline* tipis yang bersih (`1px solid`).
- **DILARANG** membuat halaman penuh teks padat (*wall of text*) tanpa jarak/whitespace, tabel, atau penekanan visual (*callout*) sehingga membosankan dibaca.
- **DILARANG** menggunakan kombinasi warna terlalu ramai/norak atau gaya visual antar halaman yang tidak konsisten.
- **DILARANG** menyusun bab berdasarkan struktur menu aplikasi (misal: *"Bab 1 Menu File, Bab 2 Menu Edit"*), wajib berbasis tugas pengguna.
- **DILARANG** membuat subbab hingga level 4 ke bawah (`1.2.3.4.5`).
- **DILARANG** menulis langkah operasional dalam bentuk paragraf panjang tanpa penomoran.
- **DILARANG** mencantumkan kode atau pesan error tanpa menjelaskan penyebab dan langkah penanganannya.
- **DILARANG** menggabungkan panduan *end-user*, admin, dan instalasi teknis ke dalam satu dokumen raksasa pada perangkat lunak berskala besar.
