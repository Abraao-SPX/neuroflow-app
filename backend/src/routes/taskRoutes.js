const express = require('express');
const router = express.Router();
const TaskController = require('../controllers/TaskController');
const authMiddleware = require('../middlewares/authMiddleware');

// Protegendo OBRIGATORIAMENTE todas as rotas de Tasks com o JWT (authMiddleware)
router.get('/', authMiddleware, TaskController.getTasks);
router.post('/', authMiddleware, TaskController.createTask);
router.put('/:id', authMiddleware, TaskController.updateTask);
router.delete('/:id', authMiddleware, TaskController.deleteTask);

module.exports = router;
