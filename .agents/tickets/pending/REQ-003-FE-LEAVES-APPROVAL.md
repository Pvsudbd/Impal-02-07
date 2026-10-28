---
id: "REQ-003"
title: "Endpoint Submit Approval Cuti & Izin Mahasiswa"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-10-28"
target_module: "leaves"
target_dev: "DEV_3_LEAVES"
---

## 📌 Ringkasan Kebutuhan
Layar pengajuan dan persetujuan izin/cuti (`LeaveApprovalPage`, modul HRD & Cuti) membutuhkan endpoint untuk memproses status persetujuan atau penolakan pengajuan izin cuti mahasiswa / dosen pembimbing.

## 🛠️ Spesifikasi REST API

### 1. GET `/api/v1/leaves`
- **Auth**: `Authorization: Bearer <jwt_token>`
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Leave requests fetched",
    "data": [
      {
        "id": "lev_01",
        "employee_id": "usr_01",
        "type": "Sick",
        "start_date": "2026-10-29",
        "end_date": "2026-10-30",
        "reason": "Demam",
        "status": "PENDING"
      }
    ],
    "error": null
  }
  ```

### 2. PUT `/api/v1/leaves/approve`
- **Auth**: `Authorization: Bearer <jwt_token>`
- **Request Body**:
  ```json
  {
    "leave_id": "lev_01",
    "status": "APPROVED",
    "notes": "Disetujui untuk istirahat"
  }
  ```
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Leave request approved successfully",
    "data": {
      "leave_id": "lev_01",
      "status": "APPROVED"
    },
    "error": null
  }
  ```

