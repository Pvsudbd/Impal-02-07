---
id: "REQ-004"
title: "Endpoint & Scheduler Push Notifikasi Daily Morning Briefing"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-10-29"
target_module: "schedules"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Modul Profil Mahasiswa (`ProfilePage`) dan pengaturan pengingat (`DailyBriefingSettingsModal`) telah mengimplementasikan fitur kustomisasi **Daily Morning Briefing**:
1. Pengguna dapat menentukan jam pengiriman laporan pagi otomatis (misal: `07:00 WIB` via time picker).
2. Pengguna dapat memilah topik agenda yang ingin disertakan (`personal_tasks`, `lecture_schedule`, `external_schedule`, `team_tasks`, `team_meetings`).
3. Pengguna dapat memilih format rendering notifikasi pada layar kunci ponsel:
   - **`detailed` (Recommended)**: Menampilkan nama agenda spesifik, jam, dan poin rincian agenda (*InboxStyle / BigTextStyle*) tanpa harus membuka aplikasi.
   - **`compact`**: Menampilkan ringkasan minimal berupa jumlah total agenda hari ini (misal: *"Anda memiliki 3 agenda terjadwal hari ini"*).

Agar notifikasi ini dapat diterima pengguna di ponsel tanpa membuka aplikasi, tim Backend (Dart Frog & PostgreSQL) membutuhkan:
- Endpoint penyimpanan & pembacaan preferensi briefing pengguna (`/api/v1/schedules/daily-briefing`).
- Layanan background scheduler / cron worker harian yang mengeksekusi pengiriman Push Notification (FCM / WebPush) sesuai jam yang dipilih pengguna.

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/schedules/daily-briefing`
Mengambil konfigurasi preferensi morning briefing pengguna yang sedang login.

* **Headers**: `Authorization: Bearer <jwt_token>`
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Daily briefing preferences retrieved successfully",
    "data": {
      "user_id": "usr_01",
      "enabled": true,
      "delivery_time": "07:00",
      "timezone": "WIB",
      "format": "detailed",
      "topics": [
        "personal_tasks",
        "lecture_schedule",
        "external_schedule",
        "team_tasks",
        "team_meetings"
      ]
    },
    "error": null
  }
  ```

---

### 2. PUT `/api/v1/schedules/daily-briefing`
Memperbarui konfigurasi preferensi morning briefing pengguna.

* **Headers**: `Authorization: Bearer <jwt_token>`
* **Request Body (JSON)**:
  ```json
  {
    "enabled": true,
    "delivery_time": "07:00",
    "timezone": "WIB",
    "format": "detailed",
    "topics": [
      "personal_tasks",
      "lecture_schedule",
      "external_schedule",
      "team_tasks"
    ]
  }
  ```
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Daily briefing preferences updated successfully",
    "data": {
      "user_id": "usr_01",
      "enabled": true,
      "delivery_time": "07:00",
      "timezone": "WIB",
      "format": "detailed",
      "topics": [
        "personal_tasks",
        "lecture_schedule",
        "external_schedule",
        "team_tasks"
      ],
      "updated_at": "2026-10-29T16:45:00Z"
    },
    "error": null
  }
  ```

---

### 3. POST `/api/v1/schedules/daily-briefing/trigger` (Worker / Diagnostic)
Endpoint untuk memicu proses kompilasi agenda hari ini dan pengiriman push notification ke device token pengguna (digunakan oleh cron scheduler backend atau tombol uji coba).

* **Headers**: `Authorization: Bearer <jwt_token>`
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Morning briefing notification dispatched",
    "data": {
      "notification_id": "notif_brf_991",
      "user_id": "usr_01",
      "format": "detailed",
      "payload": {
        "title": "☀️ Morning Briefing • 3 Agenda Hari Ini",
        "body": "Kuliah RPL (08:30 WIB) & Deadline Laporan AI (Due 23:59 WIB)",
        "expanded_lines": [
          "📚 Kuliah: Rekayasa Perangkat Lunak (08:30 - Ruang B3)",
          "📝 Tugas: Laporan AI Mamdani (Deadline 23:59 WIB)",
          "👥 Rapat: Sync Frontend Kelompok 7 (19:00 WIB)"
        ]
      },
      "sent_at": "2026-10-29T07:00:00Z"
    },
    "error": null
  }
  ```

---

## 📝 Catatan Tambahan untuk Backend Engineer (Valen / Dev 1)
1. **Fallback Saat Tidak Ada Agenda:** Jika semua topik kosong pada hari tersebut, kirimkan pesan motivasi: *"Semangat pagi! Tidak ada agenda mendesak hari ini. Nikmati harimu!"*
2. **Format Compact Payload:** Jika `format: "compact"`, properti `expanded_lines` ditiadakan dan teks `body` cukup: *"Anda memiliki 3 agenda terjadwal hari ini (1 Kuliah, 1 Tugas, 1 Rapat Tim)."*

