---
id: "REQ-010"
title: "Endpoint Profile Mahasiswa, Upload Avatar & Notification/AI Alert Preferences"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "MEDIUM"
date_created: "2026-11-19"
target_module: "employees"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Halaman & modal profil Mobile/Desktop (`ProfilePage`, `EditProfilePage`, `DesktopProfileSettingsView`, `DesktopEditProfileModal`, `DeadlineAlertSettingsModal`, `DesktopAlertSettingsModal`) membutuhkan endpoint untuk membaca dan memperbarui profil mahasiswa, upload foto profil, serta menyimpan preferensi pengingat kategori & saklar AI Fuzzy/XAI.

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/profile`
Mengambil profil mahasiswa (`full_name`, `student_id`, `major_campus`, `email`, `is_email_verified`, `phone_number`, `group_role`, `bio`, `avatar_url`, statistik ringkas `tasks_done_count`, `tasks_pending_count`, `course_count`, `sks_count`, `on_time_rate_percent`, serta konfigurasi alert & AI).

### 2. PUT `/api/v1/profile`
Memperbarui informasi profil yang dapat diedit pada `EditProfilePage` / `DesktopEditProfileModal`.
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Request Body**:
  ```json
  {
    "full_name": "Yoga Perkasa Didik",
    "phone_number": "+62 812-3456-7890",
    "bio": "Focused on Software Architecture, Fuzzy Logic Engine & Clean Code."
  }
  ```
*(Catatan: `student_id` & `email` kampus bersifat read-only SSO).*

### 3. POST `/api/v1/profile/avatar` (atau lewat `/api/v1/upload` milik `DEV_2_ROYUL`)
Menerima `multipart/form-data` gambar foto profil (`jpg`/`png`, max 5 MB) dan mengembalikan `avatar_url` baru.

### 4. PUT `/api/v1/profile/preferences`
Menyimpan pengaturan granular **Task Deadlines**, **Lecture Schedule**, **External Schedule**, **Team Tasks**, **Team Meetings**, **Sound & Vibration**, serta **AI Fuzzy / XAI** toggles (`UserProfileModel`).
* **Request Body**:
  ```json
  {
    "sound_vibration_enabled": true,
    "is_fuzzy_model_active": true,
    "score_explainability_enabled": true,
    "task_deadline_alerts": {
      "enabled": true,
      "timings": ["H-1 (24 Hours)", "1 Hour"],
      "sound_mode": "vibration_only"
    },
    "lecture_schedule_alerts": {
      "enabled": true,
      "timings": ["30 Minutes", "15 Minutes"],
      "sound_mode": "sound_and_vibrate"
    },
    "external_schedule_alerts": {
      "enabled": true,
      "timings": ["H-1 (24 Hours)", "1 Hour"],
      "sound_mode": "vibration_only"
    },
    "team_task_alerts": {
      "enabled": true,
      "timings": ["H-1 (24 Hours)", "3 Hours"],
      "sound_mode": "sound_and_vibrate"
    },
    "team_meeting_alerts": {
      "enabled": true,
      "timings": ["30 Minutes", "10 Minutes"],
      "sound_mode": "sound_and_vibrate"
    }
  }
  ```
* **Expected Response (200 OK)**: Envelope standar `{ "success": true, "message": "...", "data": { ... }, "error": null }`.
