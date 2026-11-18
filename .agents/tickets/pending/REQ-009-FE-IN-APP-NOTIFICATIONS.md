---
id: "REQ-009"
title: "Endpoint In-App Notifications Feed & Mark-As-Read"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "MEDIUM"
date_created: "2026-11-19"
target_module: "notifications"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Komponen UI pusat notifikasi Mobile (`NotifikasiPage`) dan Desktop (`DesktopNotificationPopover` pada `DesktopTopHeader`, serta badge unread real-time di `NotificationBellButton`) membutuhkan endpoint untuk mengambil riwayat notifikasi in-app dan menandai notifikasi sebagai telah dibaca (`Mark Read`).

Tiket ini melengkapi `REQ-004` (yang khusus mengatur konfigurasi dan cron scheduler *Daily Morning Briefing*).

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/notifications`
Mengambil daftar notifikasi in-app pengguna beserta total belum terbaca (`unread_count`).
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Query Params (Opsional)**: `category=all|deadline|lecture|team|ai_system`, `limit=50`
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Notifications retrieved successfully",
    "data": {
      "unread_count": 3,
      "items": [
        {
          "id": "notif-1",
          "category": "deadline",
          "category_label": "UBXCCB2 • IMPAL",
          "status_tag": "Due in 4 Hours",
          "title": "Submission: SKPL Document & Group 7 Model Diagram",
          "description": "Submission deadline on Telkom University LMS portal closes tonight at 23:59 WIB.",
          "action_label": "View Task →",
          "action_type": "view_task",
          "target_id": "task_1",
          "is_read": false,
          "created_at": "2026-10-24T09:15:00+07:00"
        }
      ]
    },
    "error": null
  }
  ```

### 2. PATCH `/api/v1/notifications/:id/read`
Menandai satu notifikasi sebagai sudah dibaca saat kartu diketuk/diekspansi.

### 3. PATCH `/api/v1/notifications/read-all`
Menandai seluruh notifikasi pengguna sebagai sudah dibaca (dipanggil oleh tombol `Mark Read` di Mobile `NotifikasiPage` & Desktop `DesktopNotificationPopover`).
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "All notifications marked as read",
    "data": { "unread_count": 0 },
    "error": null
  }
  ```
