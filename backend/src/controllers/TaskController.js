const TaskModel = require('../models/TaskModel');

class TaskController {
    static async getTasks(req, res) {
        try {
            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const tasks = await TaskModel.getAllByUser(req.userId);
            return res.status(200).json({
                success: true,
                data: tasks
            });
        } catch (error) {
            console.error('[TaskController] Erro ao buscar tarefas:', error);
            return res.status(500).json({ 
                success: false, 
                message: 'Erro interno ao processar requisição.' 
            });
        }
    }

    static async createTask(req, res) {
        try {
            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const { title, description } = req.body;
            
            // Guard clause de validação
            if (!title || String(title).trim().length === 0) {
                return res.status(400).json({ success: false, message: 'O título da tarefa é obrigatório.' });
            }

            const newTask = await TaskModel.create({
                userId: req.userId,
                title: String(title).trim(),
                description
            });
            
            return res.status(201).json({
                success: true,
                message: 'Tarefa criada com sucesso!',
                data: newTask
            });
        } catch (error) {
            console.error('[TaskController] Erro ao criar tarefa:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async updateTask(req, res) {
        try {
            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const { id } = req.params;
            const taskId = Number.parseInt(id, 10);

            if (Number.isNaN(taskId)) {
                return res.status(400).json({ success: false, message: 'ID da tarefa invalido.' });
            }

            const { title, description, completed } = req.body;
            const taskData = {};

            if (title !== undefined) {
                if (!title || String(title).trim().length === 0) {
                    return res.status(400).json({ success: false, message: 'O titulo nao pode estar vazio.' });
                }
                taskData.title = String(title).trim();
            }

            if (description !== undefined) {
                taskData.description = description;
            }

            if (completed !== undefined) {
                const normalizedCompleted = (() => {
                    if (completed === true || completed === 'true' || completed === 1 || completed === '1') {
                        return true;
                    }
                    if (completed === false || completed === 'false' || completed === 0 || completed === '0') {
                        return false;
                    }
                    return null;
                })();

                if (normalizedCompleted === null) {
                    return res.status(400).json({ success: false, message: 'Campo completed invalido.' });
                }

                taskData.completed = normalizedCompleted;
            }

            if (Object.keys(taskData).length === 0) {
                return res.status(400).json({ success: false, message: 'Nenhum campo valido para atualizar.' });
            }

            const updatedTask = await TaskModel.update(taskId, req.userId, taskData);
            
            if (!updatedTask) {
                return res.status(404).json({ success: false, message: 'Tarefa não encontrada.' });
            }

            return res.status(200).json({
                success: true,
                message: 'Tarefa atualizada com sucesso!',
                data: updatedTask
            });
        } catch (error) {
            console.error('[TaskController] Erro ao atualizar tarefa:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async deleteTask(req, res) {
        try {
            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const { id } = req.params;
            const taskId = Number.parseInt(id, 10);

            if (Number.isNaN(taskId)) {
                return res.status(400).json({ success: false, message: 'ID da tarefa invalido.' });
            }

            const isDeleted = await TaskModel.delete(taskId, req.userId);
            
            if (!isDeleted) {
                return res.status(404).json({ success: false, message: 'Tarefa não encontrada.' });
            }

            return res.status(200).json({
                success: true,
                message: 'Tarefa deletada com sucesso.'
            });
        } catch (error) {
            console.error('[TaskController] Erro ao deletar tarefa:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }
}

module.exports = TaskController;
