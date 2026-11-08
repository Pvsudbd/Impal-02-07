---
id: "REQ-002"
title: "Endpoint CRUD Schedules & Presensi Mahasiswa"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-10-28"
target_module: "attendances"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Komponen UI jadwal presensi (`SchedulePage`, `ScheduleFormPage`, `HomePage` horizontal carousel) membutuhkan integrasi dengan PostgreSQL untuk mengambil data jadwal kuliah/kegiatan, menambah jadwal baru, dan memperbarui status kehadiran.

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/schedules`
- **Auth**: `Authorization: Bearer <jwt_token>`
- **Query Params**: `date=YYYY-MM-DD` (opsional, filter tanggal)
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Schedules retrieved successfully",
    "data": [
      {
        "id": "sch_01",
        "title": "UBXCCB2 - BAHASA INDONESIA",
        "type": "Lecture",
        "location": "KTT B-106 • SSIF-04-REG-GAB02",
        "date": "2026-10-28",
        "start_time": "09:30",
        "end_time": "11:30",
        "repeat_weekly": true,
        "notes": "Kuliah tatap muka"
      }
    ],
    "error": null
  }
  ```

### 2. POST `/api/v1/schedules`
- **Auth**: `Authorization: Bearer <jwt_token>`
- **Request Body**:
  ```json
  {
    "title": "Struktur Data & Algoritma",
    "type": "Lecture",
    "location": "KU3.02.01",
    "date": "2026-10-29",
    "start_time": "08:30",
    "end_time": "10:30",
    "repeat_weekly": true,
    "notes": "Pertemuan ke-7"
  }
  ```
- **Expected Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Schedule created successfully",
    "data": {
      "id": "sch_02",
      "title": "Struktur Data & Algoritma"
    },
    "error": null
  }
  ```

