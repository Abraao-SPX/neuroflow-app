const TaskModel = require('../models/TaskModel');
const {
    isPlainObject,
    normalizeBoolean,
    normalizeOptionalString,
    normalizeRequiredString,
    parsePositiveInteger
} = require('../utils/validation');

function denyParentWrite(req, res) {
    if (req.userRole !== 'parent') return false;

    res.status(403).json({
        success: false,
        message: 'Responsaveis possuem acesso somente para visualizacao.'
    });
    return true;
}

function normalizeTaskPayload(body, { requireAll = false } = {}) {
    if (!isPlainObject(body)) {
        return { error: 'Corpo da requisicao deve ser um objeto JSON.' };
    }

    const data = {};

    if (body.title !== undefined) {
        const title = normalizeRequiredString(body.title, 'Titulo', { max: 150 });
        if (title.error) return { error: title.error };
        data.title = title.value;
    } else if (requireAll) {
        return { error: 'Titulo e obrigatorio.' };
    }

    if (body.description !== undefined) {
        const description = normalizeOptionalString(body.description, 'Descricao', { max: 5000 });
        if (description.error) return { error: description.error };
        data.description = description.value;
    } else if (requireAll) {
        data.description = null;
    }

    if (body.completed !== undefined) {
        const completed = normalizeBoolean(body.completed, 'Completed');
        if (completed.error) return { error: completed.error };
        data.completed = completed.value;
    } else if (requireAll) {
        return { error: 'Completed e obrigatorio.' };
    }

    if (Object.keys(data).length === 0) {
        return { error: 'Nenhum campo valido para atualizar.' };
    }

    return { data };
}

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
                message: 'Erro interno ao processar requisicao.'
            });
        }
    }

    static async getTaskById(req, res) {
        try {
            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const taskId = parsePositiveInteger(req.params.id);
            if (!taskId) {
                return res.status(400).json({ success: false, message: 'ID da tarefa invalido.' });
            }

            const task = await TaskModel.findById(taskId, req.userId);
            if (!task) {
                return res.status(404).json({ success: false, message: 'Tarefa nao encontrada.' });
            }

            return res.status(200).json({
                success: true,
                data: task
            });
        } catch (error) {
            console.error('[TaskController] Erro ao buscar tarefa:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async createTask(req, res) {
        try {
            if (denyParentWrite(req, res)) return;

            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const { data, error } = normalizeTaskPayload(req.body);
            if (error && error !== 'Nenhum campo valido para atualizar.') {
                return res.status(400).json({ success: false, message: error });
            }

            if (!data?.title) {
                return res.status(400).json({ success: false, message: 'Titulo e obrigatorio.' });
            }

            const newTask = await TaskModel.create({
                userId: req.userId,
                title: data.title,
                description: data.description ?? null
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

    static async replaceTask(req, res) {
        try {
            if (denyParentWrite(req, res)) return;

            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const taskId = parsePositiveInteger(req.params.id);
            if (!taskId) {
                return res.status(400).json({ success: false, message: 'ID da tarefa invalido.' });
            }

            const { data, error } = normalizeTaskPayload(req.body, { requireAll: true });
            if (error) {
                return res.status(400).json({ success: false, message: error });
            }

            const updatedTask = await TaskModel.update(taskId, req.userId, data);

            if (!updatedTask) {
                return res.status(404).json({ success: false, message: 'Tarefa nao encontrada.' });
            }

            return res.status(200).json({
                success: true,
                message: 'Tarefa substituida com sucesso!',
                data: updatedTask
            });
        } catch (error) {
            console.error('[TaskController] Erro ao substituir tarefa:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async updateTask(req, res) {
        try {
            if (denyParentWrite(req, res)) return;

            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const taskId = parsePositiveInteger(req.params.id);
            if (!taskId) {
                return res.status(400).json({ success: false, message: 'ID da tarefa invalido.' });
            }

            const { data, error } = normalizeTaskPayload(req.body);
            if (error) {
                return res.status(400).json({ success: false, message: error });
            }

            const updatedTask = await TaskModel.update(taskId, req.userId, data);

            if (!updatedTask) {
                return res.status(404).json({ success: false, message: 'Tarefa nao encontrada.' });
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
            if (denyParentWrite(req, res)) return;

            if (!req.userId) {
                return res.status(401).json({ success: false, message: 'Acesso negado.' });
            }

            const taskId = parsePositiveInteger(req.params.id);
            if (!taskId) {
                return res.status(400).json({ success: false, message: 'ID da tarefa invalido.' });
            }

            const isDeleted = await TaskModel.delete(taskId, req.userId);

            if (!isDeleted) {
                return res.status(404).json({ success: false, message: 'Tarefa nao encontrada.' });
            }

            return res.status(204).send();
        } catch (error) {
            console.error('[TaskController] Erro ao deletar tarefa:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }
}

module.exports = TaskController;
