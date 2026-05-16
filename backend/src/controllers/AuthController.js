const bcrypt = require('bcrypt');
const UserModel = require('../models/UserModel');

class AuthController {
    static async register(req, res) {
        try {
            const { name, email, password } = req.body;

            // Validação simples (Guard Clauses)
            if (!name || !email || !password) {
                return res.status(400).json({ success: false, message: 'Todos os campos são obrigatórios.' });
            }

            const userExists = await UserModel.findByEmail(email);
            if (userExists) {
                return res.status(409).json({ success: false, message: 'E-mail já está em uso.' });
            }

            // Hash da senha com bcrypt (10 rounds)
            const hashedPassword = await bcrypt.hash(password, 10);
            
            // Por padrão, garantimos que qualquer cadastro via AuthController seja 'user'
            const newUser = await UserModel.create({ name, email, password: hashedPassword, role: 'user' });
            const token = UserModel.generateToken(newUser);

            return res.status(201).json({
                success: true,
                message: 'Usuário cadastrado com sucesso!',
                token: token,
                user: newUser
            });

        } catch (error) {
            console.error('[AuthController] Erro no registro:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async login(req, res) {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                return res.status(400).json({ success: false, message: 'Email e senha são obrigatórios.' });
            }

            const user = await UserModel.findByEmail(email);

            // Verifica se o usuário existe e se a senha está correta
            if (!user) {
                return res.status(401).json({ success: false, message: 'Credenciais inválidas.' });
            }

            // Compara a senha fornecida com o hash armazenado
            const isPasswordValid = await bcrypt.compare(password, user.password);
            if (!isPasswordValid) {
                return res.status(401).json({ success: false, message: 'Credenciais inválidas.' });
            }

            const token = UserModel.generateToken(user);
            delete user.password;

            return res.status(200).json({
                success: true,
                message: 'Login realizado com sucesso.',
                token: token,
                user: user
            });

        } catch (error) {
            console.error('[AuthController] Erro no login:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }
}

module.exports = AuthController;
