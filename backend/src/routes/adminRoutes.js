const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/AdminController');
const authMiddleware = require('../middlewares/authMiddleware');
const isAdminMiddleware = require('../middlewares/isAdminMiddleware');

// Protege todas as rotas com token válido e verifica se é admin
router.use(authMiddleware);
router.use(isAdminMiddleware);

router.get('/users', AdminController.getAllUsers);
router.patch('/users/:id/ban', AdminController.setUserBanStatus);
router.patch('/users/:id/admin', AdminController.promoteUserToAdmin);
router.delete('/users/:id', AdminController.deleteUser);

module.exports = router;
