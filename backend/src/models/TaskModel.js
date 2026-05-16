const db = require('../config/db');

class TaskModel {
    static _mapRow(row) {
        return {
            id: row.id,
            title: row.title,
            description: row.description,
            completed: Number(row.completed) === 1,
            createdAt: row.created_at,
            updatedAt: row.updated_at
        };
    }

    static async getAllByUser(userId) {
        const query = `
            SELECT id, titulo AS title, descricao AS description, concluida AS completed, created_at, updated_at
            FROM Tarefas
            WHERE usuario_id = ?
            ORDER BY created_at DESC, id DESC
        `;

        const [rows] = await db.execute(query, [userId]);
        return rows.map(TaskModel._mapRow);
    }

    static async findById(id, userId) {
        const query = `
            SELECT id, titulo AS title, descricao AS description, concluida AS completed, created_at, updated_at
            FROM Tarefas
            WHERE id = ? AND usuario_id = ?
            LIMIT 1
        `;

        const [rows] = await db.execute(query, [id, userId]);
        if (!rows[0]) return null;
        return TaskModel._mapRow(rows[0]);
    }

    static async create(task) {
        const query = `
            INSERT INTO Tarefas (usuario_id, titulo, descricao, concluida)
            VALUES (?, ?, ?, ?)
        `;

        const [result] = await db.execute(query, [
            task.userId,
            task.title,
            task.description ?? null,
            0
        ]);

        return TaskModel.findById(result.insertId, task.userId);
    }

    static async update(id, userId, taskData) {
        const fields = [];
        const values = [];

        if (taskData.title !== undefined) {
            fields.push('titulo = ?');
            values.push(taskData.title);
        }

        if (taskData.description !== undefined) {
            fields.push('descricao = ?');
            values.push(taskData.description);
        }

        if (taskData.completed !== undefined) {
            fields.push('concluida = ?');
            values.push(taskData.completed ? 1 : 0);
        }

        if (fields.length === 0) {
            return null;
        }

        const query = `
            UPDATE Tarefas
            SET ${fields.join(', ')}
            WHERE id = ? AND usuario_id = ?
        `;

        values.push(id, userId);
        const [result] = await db.execute(query, values);

        if (result.affectedRows === 0) {
            return null;
        }

        return TaskModel.findById(id, userId);
    }

    static async delete(id, userId) {
        const query = 'DELETE FROM Tarefas WHERE id = ? AND usuario_id = ?';
        const [result] = await db.execute(query, [id, userId]);
        return result.affectedRows > 0;
    }
}

module.exports = TaskModel;
