---
id: "REQ-007"
title: "Endpoint CRUD Tasks (Personal & College) + Completion Toggle"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-11-19"
target_module: "tasks"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Layar pengelolaan tugas Mobile & Desktop (`HomePage`, `TaskPage`, `DesktopTasksManagementView`, `CreateTaskPage`, `EditTaskPage`, `DesktopPersonalTaskModal`) membutuhkan endpoint REST penuh untuk membaca daftar tugas personal & kuliah, membuat tugas baru, memperbarui detail tugas, menghapus tugas, dan mengubah status selesai (`is_completed`).

Seluruh skema ini kompatibel dan melengkapi ekstensi bobot rubrik pada `REQ-005` serta label `tags` pada `REQ-006`.

---

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/tasks`
Mengambil daftar seluruh tugas personal & kuliah milik pengguna.
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Query Params (Opsional)**:
  * `type`: `all | today | upcoming | overdue | completed`
  * `category`: `all | college | personal`
  * `priority`: `high | medium | low`
  * `tag`: string label tag (case-insensitive)
  * `q`: keyword pencarian (`title` / `course` / `notes`)
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Tasks retrieved successfully",
    "data": [
      {
        "id": "task_1",
        "title": "IMPAL Architecture Analysis",
        "subtitle": "Deliverable Sprint 2",
        "priority": "high",
        "deadline_date": "2026-10-11T23:59:00+07:00",
        "course": "SSIF-04-REG • Software Testing & Implementation",
        "is_college_task": true,
        "is_automatic_weight": true,
        "rubric_course_id": "course_impal",
        "rubric_component_id": "comp_impal_uts",
        "rubric_component_name": "Midterm (UTS)",
        "grade_weight_percent": 20,
        "is_alert_enabled": true,
        "is_completed": false,
        "notes": "Include ERD & sequence diagram.",
        "tags": [
          {
            "label": "Figma",
            "background_color": 4286024683,
            "text_color": 4280166763
          }
        ],
        "created_at": "2026-09-30T10:00:00+07:00"
      }
    ],
    "error": null
  }
  ```

### 2. POST `/api/v1/tasks`
Membuat tugas personal atau kuliah baru.
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Request Body**:
  ```json
  {
    "title": "Design Wireframe & Backend API",
    "subtitle": null,
    "priority": "high",
    "deadline_date": "2026-10-15T23:59:00+07:00",
    "course": "SSIF-04-REG • Software Testing & Implementation",
    "is_college_task": true,
    "is_automatic_weight": true,
    "rubric_course_id": "course_impal",
    "rubric_component_id": "comp_impal_quiz",
    "rubric_component_name": "Quiz",
    "grade_weight_percent": 15,
    "is_alert_enabled": true,
    "notes": "",
    "tag_labels": ["Figma", "Backend"]
  }
  ```
* **Expected Response (201 Created)**: Mengembalikan object task lengkap dalam envelope `{success, message, data, error}`.

### 3. PUT `/api/v1/tasks/:id`
Memperbarui detail tugas (termasuk ganti mata kuliah, komponen rubrik, priority manual/otomatis, tags, alert, atau notes).
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Expected Response (200 OK)**: Mengembalikan object task terbaru dalam envelope standar.

### 4. PATCH `/api/v1/tasks/:id/complete`
Toggle status selesai (`is_completed`) untuk tombol quick-complete pada Home, Tasks Page, & Desktop Task Grid.
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Request Body**:
  ```json
  {
    "is_completed": true
  }
  ```

### 5. DELETE `/api/v1/tasks/:id`
Menghapus tugas personal/kuliah milik pengguna (`403` jika tugas tim yang tidak dimiliki/assigned read-only).
* **Headers**: `Authorization: Bearer <jwt_token>`
* **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Task deleted successfully",
    "data": { "id": "task_1" },
    "error": null
  }
  ```
