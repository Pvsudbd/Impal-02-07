const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const Student = require('../../models/auth/studentModel');

// POST /api/auth/login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Email dan password wajib diisi.',
      });
    }

    // Cari student berdasarkan email
    const student = await Student.findByEmail(email);
    if (!student) {
      return res.status(401).json({
        status: 'error',
        message: 'Email atau password salah.',
      });
    }

    // Verifikasi password vs password_hash di database
    const isMatch = await bcrypt.compare(password, student.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        status: 'error',
        message: 'Email atau password salah.',
      });
    }

    // Buat JWT token
    const token = jwt.sign(
      {
        idStudent: student.id_student,
        email: student.email,
        name: student.name,
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      status: 'success',
      message: 'Login berhasil.',
      token,
      user: {
        idStudent: student.id_student,
        name: student.name,
        email: student.email,
      },
    });
  } catch (error) {
    console.error('[AUTH] Login error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan server.',
      detail: error.message,
    });
  }
};

// POST /api/auth/register
const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Semua field wajib diisi (name, email, password).',
      });
    }

    // Cek apakah email sudah terdaftar
    const existing = await Student.findByEmail(email);
    if (existing) {
      return res.status(409).json({
        status: 'error',
        message: 'Email sudah terdaftar.',
      });
    }

    // Generate UUID untuk id_student
    const idStudent = uuidv4();

    // Hash password → simpan sebagai password_hash
    const passwordHash = await bcrypt.hash(password, 10);

    await Student.create({ idStudent, name, email, passwordHash });

    return res.status(201).json({
      status: 'success',
      message: 'Registrasi berhasil.',
      idStudent,
    });
  } catch (error) {
    console.error('[AUTH] Register error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan server.',
      detail: error.message,
    });
  }
};

// GET /api/auth/me  ← protected route
const getMe = async (req, res) => {
  try {
    const student = await Student.findById(req.student.idStudent);
    if (!student) {
      return res.status(404).json({ status: 'error', message: 'User tidak ditemukan.' });
    }
    return res.status(200).json({ status: 'success', user: student });
  } catch (error) {
    return res.status(500).json({ status: 'error', message: error.message });
  }
};

module.exports = { login, register, getMe };
