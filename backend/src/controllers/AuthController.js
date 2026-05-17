const bcrypt = require('bcrypt');
const crypto = require('crypto');
const UserModel = require('../models/UserModel');

class AuthController {
    static async register(req, res) {
        try {
            const password = req.body.password;
            const username = String(req.body.username || req.body.name || '').trim();
            const email = req.body.email ? String(req.body.email).trim().toLowerCase() : null;

            if (!username || !password) {
                return res.status(400).json({ success: false, message: 'Username e password sao obrigatorios.' });
            }

            const usernameExists = await UserModel.findByUsername(username);
            if (usernameExists) {
                return res.status(409).json({ success: false, message: 'Username ja esta em uso.' });
            }

            if (email) {
                const emailExists = await UserModel.findByEmail(email);
                if (emailExists) {
                    return res.status(409).json({ success: false, message: 'E-mail ja esta em uso.' });
                }
            }

            const newUser = await UserModel.create({
                username,
                email,
                password,
                role: 'user'
            });
            const token = UserModel.generateAccessToken(newUser);

            return res.status(201).json({
                success: true,
                message: 'Usuario cadastrado com sucesso!',
                token,
                user: newUser.toSafeJSON()
            });
        } catch (error) {
            console.error('[AuthController] Erro no registro:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async login(req, res) {
        try {
            const { password } = req.body;
            const identifier = String(req.body.username || req.body.email || '').trim();

            if (!identifier || !password) {
                return res.status(400).json({ success: false, message: 'Username/email e password sao obrigatorios.' });
            }

            const user = await UserModel.findByLogin(identifier);

            if (!user) {
                return res.status(401).json({ success: false, message: 'Credenciais inválidas' });
            }

            const isPasswordValid = await bcrypt.compare(password, user.password);
            if (!isPasswordValid) {
                return res.status(401).json({ success: false, message: 'Credenciais inválidas' });
            }

            const token = UserModel.generateAccessToken(user);

            return res.status(200).json({
                success: true,
                message: 'Login realizado com sucesso.',
                token,
                user: user.toSafeJSON()
            });
        } catch (error) {
            console.error('[AuthController] Erro no login:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async forgotPassword(req, res) {
        try {
            const email = req.body.email ? String(req.body.email).trim().toLowerCase() : '';
            if (!email) {
                return res.status(400).json({ success: false, message: 'E-mail e obrigatorio.' });
            }

            const user = await UserModel.findByEmail(email);
            if (!user) {
                return res.status(200).json({ success: true, message: 'Se o e-mail estiver cadastrado, as instrucoes foram enviadas.' });
            }

            const token = crypto.randomBytes(32).toString('hex');
            const expires = new Date(Date.now() + 3600000);

            await UserModel.updateResetToken(user.id, token, expires);

            return res.status(200).json({ success: true, message: 'Se o e-mail estiver cadastrado, as instrucoes foram enviadas.' });
        } catch (error) {
            console.error('[AuthController] Erro em forgotPassword:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async resetPassword(req, res) {
        try {
            const { token, newPassword } = req.body;
            if (!token || !newPassword) {
                return res.status(400).json({ success: false, message: 'Token e nova password sao obrigatorios.' });
            }

            const user = await UserModel.findByResetToken(token);
            if (!user) {
                return res.status(400).json({ success: false, message: 'Token invalido ou expirado.' });
            }

            await UserModel.updatePassword(user.id, newPassword);

            return res.status(200).json({ success: true, message: 'Password atualizada com sucesso.' });
        } catch (error) {
            console.error('[AuthController] Erro em resetPassword:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static protected(req, res) {
        return res.status(200).json({
            success: true,
            message: 'Acesso autorizado.',
            user: req.user
        });
    }

    static logout(req, res) {
        return res.status(200).json({
            success: true,
            message: 'Logout realizado. Remova o token no cliente.'
        });
    }
}

module.exports = AuthController;
