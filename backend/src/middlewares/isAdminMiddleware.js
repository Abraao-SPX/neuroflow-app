const isAdminMiddleware = (req, res, next) => {
    // Verifica se a role do usuário no token é admin
    if (req.userRole && req.userRole === 'admin') {
        return next();
    }
    
    return res.status(403).json({ 
        success: false, 
        message: 'Acesso negado. Ação restrita apenas para administradores.' 
    });
};

module.exports = isAdminMiddleware;