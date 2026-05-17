const isAdminMiddleware = (req, res, next) => {
    const role = req.user?.role || req.userRole;

    if (role === 'admin') {
        return next();
    }

    return res.status(403).json({
        success: false,
        message: 'Acesso negado. Acao restrita apenas para administradores.'
    });
};

module.exports = isAdminMiddleware;
