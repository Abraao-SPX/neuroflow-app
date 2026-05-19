const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/AuthController');
const authMiddleware = require('../middlewares/authMiddleware');
const createRateLimiter = require('../middlewares/rateLimitMiddleware');

const authWriteLimiter = createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 20
});
const loginLimiter = createRateLimiter({
    windowMs: 15 * 60 * 1000,
    max: 10,
    message: 'Muitas tentativas de login. Tente novamente mais tarde.'
});
const passwordResetLimiter = createRateLimiter({
    windowMs: 60 * 60 * 1000,
    max: 5,
    message: 'Muitas tentativas de recuperacao de senha. Tente novamente mais tarde.'
});
const refreshLimiter = createRateLimiter({
    windowMs: 60 * 1000,
    max: 30
});

router.post('/register', authWriteLimiter, AuthController.register);
router.post('/login', loginLimiter, AuthController.login);
router.post('/refresh', refreshLimiter, AuthController.refresh);
router.get('/me', authMiddleware, AuthController.protected);
router.post('/logout', AuthController.logout);
router.post('/forgot-password', passwordResetLimiter, AuthController.forgotPassword);
router.post('/reset-password', passwordResetLimiter, AuthController.resetPassword);

module.exports = router;
