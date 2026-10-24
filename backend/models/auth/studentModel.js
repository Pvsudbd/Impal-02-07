const db = require('../../config/db');

// Cari student berdasarkan email
const findByEmail = async (email) => {
  const [rows] = await db.query(
    'SELECT * FROM student WHERE email = ? LIMIT 1',
    [email]
  );
  return rows[0] || null;
};

// Cari student berdasarkan id_student
const findById = async (idStudent) => {
  const [rows] = await db.query(
    'SELECT id_student, name, email, created_at FROM student WHERE id_student = ? LIMIT 1',
    [idStudent]
  );
  return rows[0] || null;
};

// Buat student baru (UUID dari luar)
const create = async ({ idStudent, name, email, passwordHash }) => {
  await db.query(
    'INSERT INTO student (id_student, name, email, password_hash) VALUES (?, ?, ?, ?)',
    [idStudent, name, email, passwordHash]
  );
  return idStudent;
};

module.exports = { findByEmail, findById, create };
