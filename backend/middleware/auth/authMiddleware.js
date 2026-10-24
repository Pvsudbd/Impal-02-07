const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Format: "Bearer <token>"

  if (!token) {
    return res.status(401).json({
      status: 'error',
      message: 'Akses ditolak. Token tidak ditemukan.',
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.student = decoded;
    next();
  } catch (error) {
    return res.status(403).json({
      status: 'error',
      message: 'Token tidak valid atau sudah expired.',
    });
  }
};

module.exports = authMiddleware;
