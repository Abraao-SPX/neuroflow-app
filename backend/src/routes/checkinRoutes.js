const express = require('express');
const router = express.Router();
const CheckinController = require('../controllers/CheckinController');
const authMiddleware = require('../middlewares/authMiddleware');

router.use(authMiddleware);

router.post('/', CheckinController.create);
router.get('/', CheckinController.getMyCheckins);
router.get('/:id', CheckinController.getById);
router.put('/:id', CheckinController.replace);
router.patch('/:id', CheckinController.update);
router.delete('/:id', CheckinController.delete);

module.exports = router;
