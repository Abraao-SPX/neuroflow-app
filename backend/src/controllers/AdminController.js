const db = require('../config/db');

class AdminController {
    static async getAllUsers(req, res) {
        try {
            const query = `
                SELECT id, username AS name, email, role, created_at
                FROM Usuarios
                ORDER BY created_at DESC
            `;
            const [users] = await db.execute(query);
            return res.status(200).json({ success: true, data: users });
        } catch (error) {
            console.error('[AdminController] Erro ao buscar usuarios:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao buscar usuarios.'
            });
        }
    }

    static async deleteUser(req, res) {
        try {
            const userId = Number.parseInt(req.params.id, 10);

            if (Number.isNaN(userId)) {
                return res.status(400).json({
                    success: false,
                    message: 'ID de usuario invalido.'
                });
            }

            if (req.userId === userId) {
                return res.status(400).json({
                    success: false,
                    message: 'O administrador nao pode apagar a propria conta logada.'
                });
            }

            const [users] = await db.execute(
                'SELECT id FROM Usuarios WHERE id = ? LIMIT 1',
                [userId]
            );
            if (users.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'Usuario nao encontrado.'
                });
            }

            await db.execute('DELETE FROM Tarefas WHERE usuario_id = ?', [userId]);
            await db.execute('DELETE FROM Usuarios WHERE id = ?', [userId]);

            return res.status(200).json({ success: true, message: 'Conta apagada com sucesso.' });
        } catch (error) {
            console.error('[AdminController] Erro ao apagar usuario:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao apagar usuario.'
            });
        }
    }
}

module.exports = AdminController;
