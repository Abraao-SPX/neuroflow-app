const TaskModel = require('../models/TaskModel');

class TaskController {
    static async getTasks(req, res) {
        try {
            const tasks = await TaskModel.getAll();
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
            const { title, description } = req.body;
            
            // Guard clause de validação
            if (!title) {
                return res.status(400).json({ success: false, message: 'O título da tarefa é obrigatório.' });
            }

            const newTask = await TaskModel.create({ title, description });
            
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
            const { id } = req.params;
            const taskData = req.body;

            const updatedTask = await TaskModel.update(id, taskData);
            
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
            const { id } = req.params;
            
            const isDeleted = await TaskModel.delete(id);
            
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
