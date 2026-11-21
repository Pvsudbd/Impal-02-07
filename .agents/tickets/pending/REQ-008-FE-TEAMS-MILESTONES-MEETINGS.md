---
id: "REQ-008"
title: "Endpoint Teams Directory, Join Code, Team Tasks, Milestones & Team Meetings"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-11-19"
target_module: "teams"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Modul kolaborasi kelompok Mobile & Desktop (`TeamListPage`, `DesktopGroupDirectoryView`, `PopUpCreateTeam`, `PopUpJoinTeam`, `DashboardTeamPage`, `DesktopGroupWorkspaceView`, `CreateTaskTeamPage`, `DesktopTeamTaskModal`, `PopUpCreateMilestone`, `DesktopMilestoneModal`, `PopUpCreateMeeting`, `DesktopTeamMeetingModal`) membutuhkan endpoint REST untuk pengelolaan tim, anggota, tugas tim, milestone, dan jadwal meeting tim.

Relasi sinkronisasi rubrik tim (`course_id`, `rubric_component_id`) juga mengikuti kontrak `REQ-005`, dan field `tags` mengikuti kontrak `REQ-006`.

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/teams` & POST `/api/v1/teams` & POST `/api/v1/teams/join`
* **`GET /api/v1/teams`**: Mengambil daftar tim pengguna, kategori (`mata_kuliah | projek_mandiri | kompetisi`), progres (`completed_tasks`, `total_tasks`), anggota, kode undangan (`invite_code`), serta recent activity & upcoming deadlines.
* **`POST /api/v1/teams`**: Membuat tim baru.
  ```json
  {
    "name": "IMPAL Team",
    "subtitle": "SSIF-04-REG • Software Testing & Implementation",
    "category": "mata_kuliah",
    "rubric_course_id": "course_impal",
    "rubric_component_id": "comp_impal_team"
  }
  ```
* **`POST /api/v1/teams/join`**: Bergabung ke tim melalui kode undangan (`team_code` / `invite_code`, misal `7X29`).

### 2. GET / POST / PUT / PATCH / DELETE `/api/v1/teams/:teamId/tasks`
Mengelola tugas di dalam tim tertentu (`TeamTaskModel`):
* **Body Create/Update**:
  ```json
  {
    "title": "Implement Auth Controller",
    "priority": "high",
    "assigned_to": "Jarvis",
    "time_range": "23:59 WIB",
    "deadline": "2026-10-14T23:59:00+07:00",
    "description": "JWT Bearer + Refresh flow",
    "is_alert_enabled": true,
    "is_done": false,
    "rubric_component_id": "comp_impal_team",
    "rubric_component_name": "Team Project",
    "grade_weight_percent": 30,
    "tag_labels": ["Code", "Backend"]
  }
  ```
* **`PATCH /api/v1/teams/:teamId/tasks/:taskId/toggle`**: Mengubah status `is_done`.

### 3. GET / POST / PUT / DELETE `/api/v1/teams/:teamId/milestones`
Mengelola `TeamMilestoneModel` (pengelompokan beberapa `task_ids` di bawah general deadline bersama):
```json
{
  "title": "Sprint 2 Deliverable",
  "description": "UI Slicing + Dart Frog Integration",
  "deadline": "2026-10-20T23:59:00+07:00",
  "task_ids": ["tt_1", "tt_2", "tt_3"]
}
```

### 4. GET / POST / PUT / DELETE `/api/v1/teams/:teamId/meetings`
Mengelola jadwal rapat / sinkronisasi tim (`PopUpCreateMeeting` & `DesktopTeamMeetingModal`):
```json
{
  "title": "Sprint 2 Finalization Review",
  "date": "2026-10-18",
  "start_time": "19:30",
  "end_time": "21:00",
  "location_or_link": "Discord Voice / Room KTT B-106",
  "notes": "Review Mamdani & API endpoints"
}
```
* **Seluruh Response** wajib mengikuti envelope `{ "success": true, "message": "...", "data": ..., "error": null }` dengan header `Authorization: Bearer <jwt_token>`.
