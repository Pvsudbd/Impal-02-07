---
id: "REQ-005"
title: "Endpoint Course Grading Rubrics, Team Rubric Sync & Mamdani Fuzzy Calculation"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-11-18"
target_module: "smart_priority"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Frontend Flutter telah mengimplementasikan fitur **Course Grading Rubrics** yang terhubung dua arah dengan:
1. Halaman **Smart Priority (`Mamdani + Course Rubrics`)** (Sidebar Desktop menu ke-5 & Tab ke-2 pada `SmartPriorityPage` Mobile).
2. Form **Create/Edit College Task** (`CreateTaskPage` / `DesktopPersonalTaskModal`), di mana komponen rubrik mata kuliah (misal `Midterm (UTS) 20%`, `Quiz 15%`, `Assignment 15%`) otomatis muncul sebagai kategori penilaian.
3. **Create Team** & **Dashboard Team** (`PopUpCreateTeam`, `DashboardTeamPage`, `DesktopGroupWorkspaceView`, `CreateTaskTeamPage`, `DesktopTeamTaskModal`) untuk sinkronisasi rubrik tugas kelompok (misal `Team Project 30%`) agar tidak bentrok dengan tugas mandiri pada mata kuliah yang sama.

Sesuai pembagian kerja tim, **perhitungan matematis Mamdani Fuzzy Inference (`Fuzzification -> MIN-MAX Rules -> Centroid Defuzzification`) dan penyimpanan rubrik di database PostgreSQL ditangani oleh Backend Dart Frog**.

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/courses/rubrics`
Mengambil daftar mata kuliah beserta komponen rubrik dan relasi tim pengguna.

* **Headers**: `Authorization: Bearer <jwt_token>`
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Course grading rubrics retrieved successfully",
    "data": [
      {
        "id": "course_impal",
        "course_code": "SSIF-04-REG",
        "course_name": "Software Testing & Implementation",
        "credits": 3,
        "components": [
          {
            "id": "comp_impal_uts",
            "name": "Midterm (UTS)",
            "weight_percent": 20,
            "assigned_team_id": null,
            "assigned_team_name": null,
            "is_preset": true
          },
          {
            "id": "comp_impal_team",
            "name": "Team Project",
            "weight_percent": 30,
            "assigned_team_id": "1",
            "assigned_team_name": "IMPAL Team",
            "is_preset": true
          }
        ]
      }
    ],
    "error": null
  }
  ```

### 2. POST/PUT/DELETE `/api/v1/courses/rubrics` & Components
- Menyimpan mata kuliah dan komponen rubrik.
- **Aturan Validasi Backend**: Total `weight_percent` seluruh komponen dalam satu `course_id` **tidak boleh melebihi `100`** (`<= 100`, draft `< 100` diizinkan).

### 3. PUT/DELETE `/api/v1/teams/:teamId/rubric`
Menautkan (atau melepas) sebuah Team ke komponen rubrik mata kuliah tertentu secara dua arah.
* **Request Body (`PUT`)**:
  ```json
  {
    "course_id": "course_impal",
    "component_id": "comp_impal_team"
  }
  ```

### 4. Payload Tambahan pada `/api/v1/tasks` & `/api/v1/team-tasks`
Setiap pembuatan/pembaruan tugas mengirim:
- `rubric_course_id`: `String?`
- `rubric_component_id`: `String?`
- `rubric_component_name`: `String?`
- `grade_weight_percent`: `int?` (`1..100`, hasil pilihan rubrik atau custom override; `null` jika mode manual `High/Medium/Low`)

### 5. GET `/api/v1/smart-priority`
Endpoint perhitungan nyata Mamdani Fuzzy Inference Engine dari semua tugas aktif (Personal/College + Team):
- **Input 1**: `deadline_date` vs waktu sekarang (`Time Left`).
- **Input 2**: `grade_weight_percent` dari komponen rubrik terkait (atau fallback manual).
- **Output**: Daftar terurut skor centroid `z*` (`0-100`), level (`high`/`medium`/`low`), nilai keanggotaan `μ`, dan narasi XAI (`reason_explanation`).
