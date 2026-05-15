const jwt = require('jsonwebtoken');
const db = require('../config/db');

class UserModel {
    static async create(user) {
        // Mapeando "name" para "username" e "password" para "senha" no banco, conforme seu schema.sql
        const query = 'INSERT INTO Usuarios (username, email, senha) VALUES (?, ?, ?)';
        const [result] = await db.execute(query, [user.name, user.email, user.password]);
        
        return { 
            id: result.insertId, 
            name: user.name, 
            email: user.email, 
            role: user.role || 'user' 
        };
    }

    static async findByEmail(email) {
        // Ajustando as colunas retornadas do SQL (senha as password, username as name) 
        // para manter compatibilidade com o Controller
        const query = 'SELECT id, username as name, email, senha as password FROM Usuarios WHERE email = ?';
        const [rows] = await db.execute(query, [email]);
        return rows[0]; 
    }

    static generateMockToken(user) {
        // Gerando Token com a senha secreta do .env
        return jwt.sign(
            { id: user.id, email: user.email, role: user.role || 'user' }, 
            process.env.JWT_SECRET || 'secret_key_provisoria_para_mock', 
            { expiresIn: '1h' }
        );
    }
}

module.exports = UserModel;
