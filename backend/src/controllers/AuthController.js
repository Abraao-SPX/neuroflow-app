const bcrypt = require('bcrypt');
const crypto = require('crypto');
const UserModel = require('../models/UserModel');
const RefreshTokenModel = require('../models/RefreshTokenModel');
const {
    isMailConfigured,
    sendParentVerificationEmail,
    sendPasswordResetEmail
} = require('../services/emailService');
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

function getParentCodeExpirationMs() {
    const minutes = Number.parseInt(process.env.PARENT_CODE_EXPIRATION_MINUTES || '10', 10);
    return (Number.isNaN(minutes) ? 10 : minutes) * 60 * 1000;
}

function buildParentStatus(user) {
    return {
        parentEmail: user.parentEmail,
        verified: Boolean(user.parentVerifiedAt && user.parentUserId),
        verifiedAt: user.parentVerifiedAt,
        parentUserId: user.parentUserId
    };
}

async function buildAuthResponse(user, message) {
    const token = UserModel.generateAccessToken(user);
    const refreshToken = await RefreshTokenModel.issueForUser(user);
    const safeUser = user.toSafeJSON();

    if (user.role === 'parent' && user.parentChildId) {
        const child = await UserModel.findByPk(user.parentChildId, {
            attributes: ['id', 'username', 'email', 'role', 'status']
        });
        if (child) {
            safeUser.child = child.toSafeJSON();
        }
    }

    return {
        success: true,
        message,
        token,
        accessToken: token,
        refreshToken,
        user: safeUser
    };
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

            const emailExists = await UserModel.findByEmail(email);
            if (emailExists) {
                return res.status(409).json({ success: false, message: 'E-mail ja esta em uso.' });
            }

            const newUser = await UserModel.create({
                username,
                email,
                password,
                role: 'user'
            });
            const response = await buildAuthResponse(newUser, 'Usuario cadastrado com sucesso!');
            return res.status(201).json(response);
        } catch (error) {
            if (isUniqueConstraintError(error)) {
                return res.status(409).json({ success: false, message: 'E-mail ja esta em uso.' });
            }

            console.error('[AuthController] Erro no registro:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async login(req, res) {
        try {
            const { password } = req.body;
            const email = req.body.email ? String(req.body.email).trim().toLowerCase() : '';

            if (!email || !password) {
                return res.status(400).json({ success: false, message: 'E-mail e password sao obrigatorios.' });
            }

            const emailResult = normalizeEmail(email, { required: true });
            if (emailResult.error) {
                return res.status(400).json({ success: false, message: emailResult.error });
            }

            const user = await UserModel.findByEmail(emailResult.value);

            if (!user) {
                return res.status(401).json({ success: false, message: 'Credenciais inválidas' });
            }

            if (user.status === 'banned') {
                return res.status(403).json({ success: false, message: 'Conta banida. Entre em contato com o suporte.' });
            }

            const isPasswordValid = await bcrypt.compare(password, user.password);
            if (!isPasswordValid) {
                return res.status(401).json({ success: false, message: 'Credenciais inválidas' });
            }

            const response = await buildAuthResponse(user, 'Login realizado com sucesso.');
            return res.status(200).json(response);
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

    static async getParentAccessStatus(req, res) {
        try {
            if (req.userRole === 'parent') {
                return res.status(403).json({ success: false, message: 'Responsavel nao pode configurar outro responsavel.' });
            }

            const user = await UserModel.findByPk(req.user.id);
            if (!user) {
                return res.status(404).json({ success: false, message: 'Usuario nao encontrado.' });
            }

            return res.status(200).json({ success: true, data: buildParentStatus(user) });
        } catch (error) {
            console.error('[AuthController] Erro ao buscar responsavel:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async requestParentAccessCode(req, res) {
        try {
            if (req.userRole === 'parent') {
                return res.status(403).json({ success: false, message: 'Responsavel nao pode configurar outro responsavel.' });
            }

            const emailResult = normalizeEmail(req.body.email, { required: true });
            if (emailResult.error) {
                return res.status(400).json({ success: false, message: emailResult.error });
            }

            const child = await UserModel.findByPk(req.user.id);
            if (!child) {
                return res.status(404).json({ success: false, message: 'Usuario nao encontrado.' });
            }

            if (child.parentUserId && child.parentVerifiedAt) {
                return res.status(409).json({ success: false, message: 'Este usuario ja possui um responsavel verificado.' });
            }

            if (emailResult.value === child.email) {
                return res.status(400).json({ success: false, message: 'Use um e-mail diferente do e-mail do usuario.' });
            }

            const existingUser = await UserModel.findByEmail(emailResult.value);
            if (existingUser && (existingUser.role !== 'parent' || existingUser.parentChildId !== child.id)) {
                return res.status(409).json({ success: false, message: 'Este e-mail ja esta em uso.' });
            }

            const code = generateResetCode();
            const expires = new Date(Date.now() + getParentCodeExpirationMs());
            await UserModel.updateParentVerification(child.id, emailResult.value, code, expires);

            const response = {
                success: true,
                message: 'Codigo enviado para o e-mail do responsavel.'
            };

            if (isMailConfigured()) {
                await sendParentVerificationEmail({
                    to: emailResult.value,
                    childName: child.username,
                    code,
                    expires
                });
            }

            return res.status(200).json(response);
        } catch (error) {
            console.error('[AuthController] Erro ao solicitar responsavel:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
    }

    static async confirmParentAccessCode(req, res) {
        try {
            if (req.userRole === 'parent') {
                return res.status(403).json({ success: false, message: 'Responsavel nao pode configurar outro responsavel.' });
            }

            const emailResult = normalizeEmail(req.body.email, { required: true });
            if (emailResult.error) {
                return res.status(400).json({ success: false, message: emailResult.error });
            }

            const code = req.body.code ? String(req.body.code).trim() : '';
            if (!/^\d{6}$/.test(code)) {
                return res.status(400).json({ success: false, message: 'Codigo deve conter 6 numeros.' });
            }

            const passwordResult = validatePassword(req.body.password, 'Senha do responsavel');
            if (passwordResult.error) {
                return res.status(400).json({ success: false, message: passwordResult.error });
            }

            const child = await UserModel.findByPk(req.user.id);
            if (!child) {
                return res.status(404).json({ success: false, message: 'Usuario nao encontrado.' });
            }

            if (child.parentUserId && child.parentVerifiedAt) {
                return res.status(409).json({ success: false, message: 'Este usuario ja possui um responsavel verificado.' });
            }

            const codeHash = UserModel.hashVerificationCode(code);
            if (
                child.parentEmail !== emailResult.value ||
                child.parentVerificationCode !== codeHash ||
                !child.parentVerificationExpires ||
                child.parentVerificationExpires <= new Date()
            ) {
                return res.status(400).json({ success: false, message: 'Codigo invalido ou expirado.' });
            }

            let parent = await UserModel.findByEmail(emailResult.value);
            if (parent && (parent.role !== 'parent' || parent.parentChildId !== child.id)) {
                return res.status(409).json({ success: false, message: 'Este e-mail ja esta em uso.' });
            }

            if (!parent) {
                parent = await UserModel.create({
                    username: `Responsavel de ${child.username}`,
                    email: emailResult.value,
                    password: passwordResult.value,
                    role: 'parent',
                    parentChildId: child.id
                });
            } else {
                parent.password = passwordResult.value;
                parent.parentChildId = child.id;
                await parent.save();
            }

            child.parentUserId = parent.id;
            child.parentVerifiedAt = new Date();
            child.parentVerificationCode = null;
            child.parentVerificationExpires = null;
            await child.save();

            return res.status(200).json({
                success: true,
                message: 'Responsavel verificado com sucesso.',
                data: buildParentStatus(child)
            });
        } catch (error) {
            if (isUniqueConstraintError(error)) {
                return res.status(409).json({ success: false, message: 'Este e-mail ja esta em uso.' });
            }

            console.error('[AuthController] Erro ao confirmar responsavel:', error);
            return res.status(500).json({ success: false, message: 'Erro interno do servidor.' });
        }
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

            const safeUser = session.user.toSafeJSON();
            if (session.user.role === 'parent' && session.user.parentChildId) {
                const child = await UserModel.findByPk(session.user.parentChildId, {
                    attributes: ['id', 'username', 'email', 'role', 'status']
                });
                if (child) {
                    safeUser.child = child.toSafeJSON();
                }
            }

            return res.status(200).json({
                success: true,
                token: session.accessToken,
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: safeUser
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
