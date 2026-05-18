const express = require('express');
const router = express.Router();
const CheckinController = require('../controllers/CheckinController');
const authMiddleware = require('../middlewares/authMiddleware');

router.use(authMiddleware);

router.post('/', CheckinController.create);
router.get('/', CheckinController.getMyCheckins);

module.exports = router;
