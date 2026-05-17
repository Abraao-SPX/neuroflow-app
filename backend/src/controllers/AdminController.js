const db = require('../config/db');

class AdminController {
    static async getAllUsers(req, res) {
        try {
            const query = 'SELECT id, username as name, email, role, created_at FROM Usuarios ORDER BY created_at DESC';
            const [users] = await db.execute(query);
            res.status(200).json(users);
        } catch (error) {
            console.error('Erro ao buscar usuários:', error);
            res.status(500).json({ error: 'Erro interno ao buscar usuários.' });
        }
    }

    static async deleteUser(req, res) {
        const { id } = req.params;
        try {
            // First check if user exists
            const checkQuery = 'SELECT id FROM Usuarios WHERE id = ?';
            const [users] = await db.execute(checkQuery, [id]);
            
            if (users.length === 0) {
                return res.status(404).json({ error: 'Usuário não encontrado.' });
            }

            // Remove user's tasks first (or handle cascade delete in sql if configured)
            // It's safer to do it manually if we are not sure about cascade setup
            await db.execute('DELETE FROM Tarefas WHERE usuario_id = ?', [id]);
            
            // Delete user
            const deleteQuery = 'DELETE FROM Usuarios WHERE id = ?';
            await db.execute(deleteQuery, [id]);
            
            res.status(200).json({ message: 'Conta apagada com sucesso.' });
        } catch (error) {
            console.error('Erro ao apagar usuário:', error);
            res.status(500).json({ error: 'Erro interno ao apagar usuário.' });
        }
    }
}

module.exports = AdminController;
