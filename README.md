# Aplikasi All-in-One Berbasis Sistem Cerdas untuk Mempermudah Penjadwalan dan Organisir Mahasiswa

### Kelompok 7 - IMPAL
1. Valen Jhonatan Miceliano Pasaribu (103072400072) - [@LenPakeL](https://github.com/LenPakeL)
2. Habindra Dzaky Alghifari (103072400095) - [@Habhindra](https://github.com/Habhindra)
3. Muhammad Kafi Rijal (103072400016) - [@Kitsusne](https://github.com/Kitsusne)
4. Yoga Perkasa Didik (103072400106) - [@Pvsudbd](https://github.com/Pvsudbd)

---

## 📁 Struktur Repositori

Repository ini menggunakan arsitektur **Monorepo** yang memisahkan antara modul klien (Frontend) dan layanan data (Backend):

```text
Impal-02-07/
├── frontend/               # Aplikasi Klien (Flutter / Dart)
│   ├── assets/             # Fonts, Icons, Images
│   ├── lib/
│   │   ├── core/           # Constants, Network, Services, Theme, Utils
│   │   ├── data/           # Datasources, Models, Repositories
│   │   ├── domain/         # Entities, Repository Interfaces, Use Cases (Fuzzy Mamdani)
│   │   └── presentation/   # UI Features (auth, dashboard, jadwal, tugas, smart_system, todo, notifikasi)
│   ├── test/               # Unit & Widget Testing
│   ├── analysis_options.yaml
│   └── pubspec.yaml
│
├── backend/                # REST API Server
│   ├── config/             # Konfigurasi database & environment
│   ├── controllers/        # Request handlers per modul
│   ├── database/           # Migrations & seeders database MySQL
│   ├── middleware/         # Autentikasi JWT Bearer token
│   ├── models/             # Entity/ORM models (mahasiswa, matakuliah, tugas, dll.)
│   ├── routes/             # Routing endpoint RESTful API
│   └── services/           # Logika bisnis tambahan
│
├── .gitignore              # Git ignore rules untuk Flutter & Backend
└── SKPL - IMPAL KELOMPOK 7.pdf
```
