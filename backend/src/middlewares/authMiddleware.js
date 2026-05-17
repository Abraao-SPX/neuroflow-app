const jwt = require('jsonwebtoken');
const { getJwtSecret } = require('../config/auth');

const authMiddleware = (req, res, next) => {
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
        const decoded = jwt.verify(token, getJwtSecret());
        req.user = {
            id: decoded.id,
            username: decoded.username,
            role: decoded.role
        };
        req.userId = decoded.id;
        req.userRole = decoded.role;
        return next();
    } catch (err) {
        return res.status(403).json({ success: false, message: 'Token invalido ou expirado.' });
    }
};

module.exports = authMiddleware;
