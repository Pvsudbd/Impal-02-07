const express = require('express');
const router = express.Router();
const { login, register, getMe } = require('../../controllers/auth/authController');
const authMiddleware = require('../../middleware/auth/authMiddleware');

// POST /api/auth/register
router.post('/register', register);

// POST /api/auth/login
router.post('/login', login);

// GET /api/auth/me  ← protected, butuh token
router.get('/me', authMiddleware, getMe);

module.exports = router;
