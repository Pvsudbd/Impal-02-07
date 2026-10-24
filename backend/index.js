const express = require('express');
const cors = require('cors');
const db = require('./config/db');
require('dotenv').config();

const authRoutes = require('./routes/auth/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);

// ✅ Test route — cek server hidup
app.get('/', (req, res) => {
  res.json({ message: 'Backend Impal-02-07 berjalan!' });
});

// ✅ Test koneksi database
app.get('/test-db', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT 1 + 1 AS hasil');
    res.json({
      status: 'success',
      message: 'Koneksi ke database berhasil!',
      database: process.env.DB_NAME,
      hasil: rows[0].hasil,
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Gagal konek ke database',
      detail: error.message,
    });
  }
});

// ✅ Lihat semua tabel di database
app.get('/tables', async (req, res) => {
  try {
    const [rows] = await db.query('SHOW TABLES');
    res.json({
      status: 'success',
      database: process.env.DB_NAME,
      tables: rows,
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
  console.log(`Test DB: http://localhost:${PORT}/test-db`);
  console.log(`Lihat tabel: http://localhost:${PORT}/tables`);
});
