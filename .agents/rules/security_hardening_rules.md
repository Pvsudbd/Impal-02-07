# 🛡️ Frontend Security & Hardening Rules
<!-- Lokasi Resmi: .agents/rules/security_hardening_rules.md -->

Dokumen ini mendefinisikan standar keamanan siber (*cybersecurity*), proteksi data sensitif, pencegahan injeksi, dan kepatuhan OWASP Mobile Top 10 untuk seluruh komponen frontend aplikasi **IMPAL**.

---

## 1. Tujuan & Lingkup Penggunaan
- Seluruh penyimpanan data lokal (Auth tokens, preferensi sesi, database SQLite/Hive).
- Seluruh formulir input teks dan penanganan payload API.
- Seluruh jaringan komunikasi HTTP/REST dan pengelolaan rahasia (*secrets management*).
- Diaudit dan diawasi langsung oleh **Flutter AppSec & Cybersecurity Auditor (Subagent 7)**.

---

## 2. Standar Penyimpanan Aman (Zero Insecure Storage)

### A. Larangan SharedPreferences untuk Data Rahasia
`SharedPreferences` di Android disimpan dalam file XML teks polos (`/data/data/<package>/shared_prefs/*.xml`) yang dapat dibaca seketika di perangkat ber-root atau melalui backup ADB.

| Tipe Data | Media Penyimpanan yang Wajib | Keterangan |
| :--- | :--- | :--- |
| **Token JWT (Bearer Token)** | `flutter_secure_storage` | Terenkripsi Android Keystore & iOS Keychain |
| **Refresh Token & Auth Secret** | `flutter_secure_storage` | Terenkripsi Android Keystore & iOS Keychain |
| **Password / PIN / OTP** | Dilarang disimpan persisten | Hanya di memori sesi aktif jika diperlukan |
| **Preferensi UI (Theme, Language)** | `SharedPreferences` | Boleh karena tidak berisiko keamanan |

### B. Implementasi Baku `SecureStorageHelper`
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> clearAuth() async {
    await _storage.delete(key: 'jwt_token');
  }
}
```

---

## 3. Pencegahan Injeksi & Sanitasi Input (Anti-Injection & Sanitization)

### A. Local SQL Injection Prevention (`sqflite` / `drift`)
Jika menggunakan database SQLite lokal untuk cache offline atau mutasi:
- **DILARANG KERAS**: Menggabungkan input pengguna langsung ke dalam string query SQL.
  ```dart
  // ❌ VULNERABLE: Rentan Local SQL Injection
  final result = await db.rawQuery("SELECT * FROM tasks WHERE title = '$inputTitle'");
  ```
- **WAJIB**: Menggunakan parameter binding dengan tanda tanya `?`.
  ```dart
  // ✅ SECURE: Menggunakan Parameter Binding
  final result = await db.rawQuery(
    "SELECT * FROM tasks WHERE title = ?",
    [inputTitle],
  );
  ```

### B. Sanitasi & Batasan Formulir Input
- **Batasan Panjang Input:** Seluruh `TextField` wajib memasang `maxLength` untuk mencegah payload berukuran gigantis (*buffer exhaustion / denial of service lokal*).
- **Trimming:** Selalu bersihkan whitespace berlebih dengan `.trim()` sebelum diproses atau dikirim.
- **Karakter Terlarang:** Bersihkan karakter kontrol berbahaya atau strip tag HTML/Script jika teks akan dirender kembali di UI/WebView.

---

## 4. Proteksi Rahasia & Anti-Decompile (Secrets Management)

1. **Dilarang Hardcoded Secrets:**
   - Dilarang menuliskan API Key rahasia, secret signing token, atau private key langsung di dalam berkas `.dart`.
   - Gunakan environment variables via `String.fromEnvironment('API_KEY')` saat build (`flutter build --dart-define=API_KEY=xxx`) atau paket konfigurasi aman.
2. **Kompilasi Rilis Terobfuskasi:**
   - Saat build release APK/AAB, wajib menyertakan flag obfuscation agar kode Dart AOT tidak mudah dibaca lewat decompilation:
     ```bash
     flutter build appbundle --obfuscate --split-debug-info=./debug_symbols
     ```

---

## 5. Larangan Logging Data Sensitif di Production (Zero Log Leaks)

- **DILARANG**: Membiarkan pemanggilan `print()` mencetak response JSON utuh, token JWT, nomor telepon, atau data privat pengguna.
- **WAJIB**: Logging hanya boleh aktif pada mode debug:
  ```dart
  import 'package:flutter/foundation.dart';

  void secureLog(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }
  ```

---

## 6. Keamanan Jaringan & Enforce HTTPS (Transport Security)

1. **HTTPS Enforcement:** Seluruh endpoint produksi wajib menggunakan protokol `https://`.
2. **Cleartext Traffic Restriction:** Pada `android/app/src/main/AndroidManifest.xml`, pastikan `android:usesCleartextTraffic="false"` untuk build rilis.
3. **Session Invalidation on Logout:** Saat pengguna menekan Logout, bersihkan seluruh cache token di memori dan storage lokal, lalu batalkan sesi aktif.

---

## 📌 Checklist Audit Keamanan (OWASP Mobile Quick Checklist)

Sebelum merilis fitur atau merging pull request, pastikan lulus 5 poin ini:
- [ ] 1. Apakah ada token/password yang tersimpan di `SharedPreferences`? *(Harus 0)*
- [ ] 2. Apakah ada query database lokal dengan konkatenasi string mentah? *(Harus 0)*
- [ ] 3. Apakah ada `print()` yang mencetak payload token atau data sensitif? *(Harus 0)*
- [ ] 4. Apakah semua form input memiliki validasi tipe dan batas panjang karakter? *(Wajib Ya)*
- [ ] 5. Apakah URL API menggunakan protokol terenkripsi HTTPS? *(Wajib Ya)*
