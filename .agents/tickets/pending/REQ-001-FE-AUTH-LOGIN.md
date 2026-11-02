---
id: "REQ-001"
title: "Endpoint Login, Register & Session Verification (JWT Bearer)"
requester: "FE_FLUTTER"
category: "API_ENDPOINT"
status: "PENDING"
priority: "HIGH"
date_created: "2026-10-28"
target_module: "employees"
target_dev: "DEV_1_VALEN"
---

## 📌 Ringkasan Kebutuhan
Komponen UI autentikasi Flutter (`LoginPage`, `RegisterPage`, `VerificationCodePage`, `ResetPasswordPage`) membutuhkan endpoint standar Dart Frog dengan PostgreSQL untuk pendaftaran akun mahasiswa, autentikasi sesi via JWT Bearer Token, dan verifikasi profil pengguna aktif.

## 🛠️ Spesifikasi REST API

### 1. POST `/api/v1/auth/login`
- **Auth**: Public
- **Request Body**:
  ```json
  {
    "username": "jarvis@student.telkomuniversity.ac.id",
    "password": "Password123!"
  }
  ```
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "token": "eyJhbGciOi...",
      "user": {
        "id": "usr_01",
        "name": "Jarvis",
        "email": "jarvis@student.telkomuniversity.ac.id",
        "role": "student"
      }
    },
    "error": null
  }
  ```

### 2. POST `/api/v1/auth/register`
- **Auth**: Public
- **Request Body**:
  ```json
  {
    "name": "Jarvis",
    "email": "jarvis@student.telkomuniversity.ac.id",
    "password": "Password123!"
  }
  ```
- **Expected Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "id": "usr_01",
      "name": "Jarvis",
      "email": "jarvis@student.telkomuniversity.ac.id"
    },
    "error": null
  }
  ```

### 3. GET `/api/v1/auth/profile`
- **Auth**: `Authorization: Bearer <jwt_token>`
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Profile fetched successfully",
    "data": {
      "id": "usr_01",
      "name": "Jarvis",
      "email": "jarvis@student.telkomuniversity.ac.id",
      "role": "student"
    },
    "error": null
  }
  ```

