const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
    // Busca o token no cabeçalho "Authorization: Bearer <token>"
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(401).json({ success: false, message: 'Acesso negado. Token não fornecido.' });
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
        // A mesma secret_key que usamos no UserModel, carregada do .env
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_secret_key_change_in_production');
        req.userId = decoded.id; // Pendura o ID do usuário na requisição para o Controller saber quem é
        req.userRole = decoded.role; // Pendura a role (user/admin) para uso dos middlewares de autorização
        return next(); // Libera a catraca
    } catch (err) {
        return res.status(401).json({ success: false, message: 'Token inválido ou expirado.' });
    }
};

module.exports = authMiddleware;