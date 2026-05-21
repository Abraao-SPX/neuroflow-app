const jwt = require('jsonwebtoken');
const { getJwtSecret } = require('../config/auth');
const UserModel = require('../models/UserModel');

const authMiddleware = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(401).json({ success: false, message: 'Acesso negado. Token nao fornecido.' });
    }

    const parts = authHeader.split(' ');

    if (parts.length !== 2) {
        return res.status(401).json({ success: false, message: 'Erro no token.' });
    }

    const [scheme, token] = parts;

    if (!/^Bearer$/i.test(scheme)) {
        return res.status(401).json({ success: false, message: 'Token mal formatado.' });
    }

    try {
        const decoded = jwt.verify(token, getJwtSecret(), {
            algorithms: ['HS256']
        });

        if (!decoded?.id) {
            return res.status(403).json({ success: false, message: 'Token invalido.' });
        }

        const user = await UserModel.findByPk(decoded.id, {
            attributes: ['id', 'username', 'email', 'role', 'status']
        });

        if (!user) {
            return res.status(403).json({ success: false, message: 'Token invalido.' });
        }

        if (user.status === 'banned') {
            return res.status(403).json({ success: false, message: 'Conta banida.' });
        }

        req.user = user.toSafeJSON();
        req.userId = decoded.id;
        req.userRole = user.role;
        return next();
    } catch (err) {
        return res.status(403).json({ success: false, message: 'Token invalido ou expirado.' });
    }
};

module.exports = authMiddleware;
