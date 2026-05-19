const TaskSequelizeModel = require('./TaskSequelizeModel');

class TaskModel {
    static _mapInstance(task) {
        if (!task) return null;

        return {
            id: task.id,
            title: task.titulo,
            description: task.descricao,
            completed: Boolean(task.concluida),
            createdAt: task.createdAt,
            updatedAt: task.updatedAt
        };
    }

    static async getAllByUser(userId) {
        const tasks = await TaskSequelizeModel.findAll({
            where: { usuarioId: userId },
            order: [['createdAt', 'DESC'], ['id', 'DESC']]
        });

        return tasks.map(TaskModel._mapInstance);
    }

    static async findById(id, userId) {
        const task = await TaskSequelizeModel.findOne({
            where: {
                id,
                usuarioId: userId
            }
        });

        return TaskModel._mapInstance(task);
    }

    static async create(task) {
        const newTask = await TaskSequelizeModel.create({
            usuarioId: task.userId,
            titulo: task.title,
            descricao: task.description ?? null,
            concluida: false
        });

        return TaskModel._mapInstance(newTask);
    }

    static async update(id, userId, taskData) {
        const task = await TaskSequelizeModel.findOne({
            where: {
                id,
                usuarioId: userId
            }
        });

        if (!task) return null;

        const updateData = {};

        if (taskData.title !== undefined) {
            updateData.titulo = taskData.title;
        }

        if (taskData.description !== undefined) {
            updateData.descricao = taskData.description;
        }

        if (taskData.completed !== undefined) {
            updateData.concluida = taskData.completed;
        }

        if (Object.keys(updateData).length === 0) {
            return null;
        }

        await task.update(updateData);
        return TaskModel._mapInstance(task);
    }

    static async delete(id, userId) {
        const deletedCount = await TaskSequelizeModel.destroy({
            where: {
                id,
                usuarioId: userId
            }
        });

        return deletedCount > 0;
    }
}

module.exports = TaskModel;
