---
id: "REQ-006"
title: "Endpoint Custom Task Tags & Filter Label Tugas (Personal, College, Team)"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "MEDIUM"
date_created: "2026-11-19"
target_module: "tasks"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Frontend Flutter telah mengimplementasikan fitur **Custom Task Tags (Smart Labels)** melalui `TaskTagRepository` yang sinkron di:
1. Tombol `+ Add Tag` pada Dashboard Home (Mobile `HomeCategoriesSection` & Desktop `DesktopOngoingTasksSection`) dan Halaman Tasks (`TaskPage` & `DesktopTasksManagementView`).
2. Multi-select tag picker pada seluruh form pembuatan & edit tugas (`CreateTaskPage`, `DesktopPersonalTaskModal`, `CreateTaskTeamPage`, `DesktopTeamTaskModal`).

Untuk menjaga pemisahan bersih dari **Course Grading Rubrics (`REQ-005`)**, tag berperan murni sebagai label filter berwarna tanpa memengaruhi perhitungan bobot nilai Mamdani.

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/tags`
Mengambil daftar tag bawaan & custom tag milik pengguna.
```json
{
  "success": true,
  "message": "Task tags retrieved successfully",
  "data": [
    {
      "id": "tag_figma",
      "label": "Figma",
      "background_color": 4286024683,
      "text_color": 4280166763,
      "is_default": true
    }
  ],
  "error": null
}
```

### 2. POST `/api/v1/tags` & DELETE `/api/v1/tags/:id`
- Validasi Backend: Tolak nama kosong, panjang > 24 karakter, duplikat (case-insensitive), kata tercadang (`all`, `college`, `personal`, `team`, `completed`), maupun nama yang persis sama dengan Course aktif milik pengguna.

### 3. Payload `tags` pada `/api/v1/tasks` & `/api/v1/team-tasks`
Menyertakan array `tags` (label & warna) agar tugas tim dan tugas personal/kuliah dapat difilter lintas perangkat.
