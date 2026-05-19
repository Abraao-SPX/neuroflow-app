const express = require('express');
const router = express.Router();
const TriggerController = require('../controllers/TriggerController');
const authMiddleware = require('../middlewares/authMiddleware');
const isAdminMiddleware = require('../middlewares/isAdminMiddleware');

router.use(authMiddleware);

router.get('/', TriggerController.getAll);
router.get('/:id', TriggerController.getById);
router.post('/', isAdminMiddleware, TriggerController.create);
router.put('/:id', isAdminMiddleware, TriggerController.replace);
router.patch('/:id', isAdminMiddleware, TriggerController.update);
router.delete('/:id', isAdminMiddleware, TriggerController.delete);

module.exports = router;
