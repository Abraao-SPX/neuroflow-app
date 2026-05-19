const bcrypt = require('bcrypt');
const crypto = require('crypto');
const UserModel = require('../models/UserModel');
const RefreshTokenModel = require('../models/RefreshTokenModel');
const { isMailConfigured, sendPasswordResetEmail } = require('../services/emailService');
const {
    isUniqueConstraintError,
    normalizeEmail,
    normalizeRequiredString,
    validatePassword
} = require('../utils/validation');

function getResetTokenExpirationMs() {
    const minutes = Number.parseInt(process.env.RESET_TOKEN_EXPIRATION_MINUTES || '5', 10);
    return (Number.isNaN(minutes) ? 5 : minutes) * 60 * 1000;
}

function generateResetCode() {
    return crypto.randomInt(100000, 1000000).toString();
}

class AuthController {
    static async register(req, res) {
        try {
            const usernameResult = normalizeRequiredString(req.body.username || req.body.name, 'Username', { min: 3, max: 100 });
            if (usernameResult.error) {
                return res.status(400).json({ success: false, message: usernameResult.error });
            }

            const emailResult = normalizeEmail(req.body.email, { required: true });
            if (emailResult.error) {
                return res.status(400).json({ success: false, message: emailResult.error });
            }

            const passwordResult = validatePassword(req.body.password, 'Password');
            if (passwordResult.error) {
                return res.status(400).json({ success: false, message: passwordResult.error });
            }

            const username = usernameResult.value;
            const email = emailResult.value;
            const password = passwordResult.value;

            const [usernameExists, emailExists] = await Promise.all([
                UserModel.findByUsername(username),
                UserModel.findByEmail(email)
            ]);

            if (usernameExists) {
                return res.status(409).json({ success: false, message: 'Username ja esta em uso.' });
            }

            if (emailExists) {
                return res.status(409).json({ success: false, message: 'E-mail ja esta em uso.' });
            }

            const newUser = await UserModel.create({
                username,
                email,
                password,
                role: 'user'
            });
            const token = UserModel.generateAccessToken(newUser);
            const refreshToken = await RefreshTokenModel.issueForUser(newUser);

            return res.status(201).json({
                success: true,
                message: 'Usuario cadastrado com sucesso!',
                token,
                accessToken: token,
                refreshToken,
                user: newUser.toSafeJSON()
            });
        } catch (error) {
            if (isUniqueConstraintError(error)) {
                return res.status(409).json({ success: false, message: 'Usuario ou e-mail ja esta em uso.' });
            }

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
            const refreshToken = await RefreshTokenModel.issueForUser(user);

            return res.status(200).json({
                success: true,
                message: 'Login realizado com sucesso.',
                token,
                accessToken: token,
                refreshToken,
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
            const emailResult = normalizeEmail(email, { required: true });
            if (emailResult.error) {
                return res.status(400).json({ success: false, message: emailResult.error });
            }

            const user = await UserModel.findByEmail(emailResult.value);
            if (!user) {
                return res.status(200).json({ success: true, message: 'Se o e-mail estiver cadastrado, as instrucoes foram enviadas.' });
            }

            const token = generateResetCode();
            const expires = new Date(Date.now() + getResetTokenExpirationMs());
            await UserModel.updateResetToken(user.id, token, expires);

            const response = { success: true, message: 'Se o e-mail estiver cadastrado, as instrucoes foram enviadas.' };
            if (isMailConfigured()) {
                await sendPasswordResetEmail({
                    to: user.email,
                    token,
                    expires
                });
            }

            return res.status(200).json(response);
        } catch (error) {
            console.error('[AuthController] Erro em forgotPassword:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async resetPassword(req, res) {
        try {
            const { token, newPassword } = req.body;
            if (!token || !newPassword) {
                return res.status(400).json({ success: false, message: 'Codigo e nova password sao obrigatorios.' });
            }

            const passwordResult = validatePassword(newPassword, 'Nova password');
            if (passwordResult.error) {
                return res.status(400).json({ success: false, message: passwordResult.error });
            }

            const user = await UserModel.findByResetToken(token);
            if (!user) {
                return res.status(400).json({ success: false, message: 'Codigo invalido ou expirado.' });
            }

            await UserModel.updatePassword(user.id, passwordResult.value);

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

    static async refresh(req, res) {
        try {
            const { refreshToken } = req.body;
            if (!refreshToken) {
                return res.status(400).json({ success: false, message: 'Refresh token e obrigatorio.' });
            }

            const session = await RefreshTokenModel.rotate(refreshToken);
            if (!session) {
                return res.status(401).json({ success: false, message: 'Refresh token invalido ou expirado.' });
            }

            return res.status(200).json({
                success: true,
                token: session.accessToken,
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: session.user.toSafeJSON()
            });
        } catch (error) {
            console.error('[AuthController] Erro em refresh:', error);
            return res.status(401).json({ success: false, message: 'Refresh token invalido ou expirado.' });
        }
    }

    static async logout(req, res) {
        const { refreshToken } = req.body || {};
        if (refreshToken) {
            await RefreshTokenModel.revoke(refreshToken);
        }

        return res.status(200).json({
            success: true,
            message: 'Logout realizado.'
        });
    }
}

module.exports = AuthController;
