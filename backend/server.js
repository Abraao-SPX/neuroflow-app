require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sequelize = require('./src/config/sequelize');
require('./src/models/UserModel');
require('./src/models/TaskSequelizeModel');
require('./src/models/RefreshTokenModel');
require('./src/models/CheckinModel'); // Model de check-in
const ensureAuthSchema = require('./src/database/ensureAuthSchema');
const {
    getJwtSecret,
    getRefreshTokenExpiration,
    getRefreshTokenSecret,
    getTokenExpiration
} = require('./src/config/auth');
const authMiddleware = require('./src/middlewares/authMiddleware');
const AuthController = require('./src/controllers/AuthController');
const taskRoutes = require('./src/routes/taskRoutes');
const authRoutes = require('./src/routes/authRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const checkinRoutes = require('./src/routes/checkinRoutes'); // Rotas de check-in

const app = express();
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/tasks', taskRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/checkins', checkinRoutes); // Rota base de check-in
app.get('/protected', authMiddleware, AuthController.protected);

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        getJwtSecret();
        getTokenExpiration();
        getRefreshTokenSecret();
        getRefreshTokenExpiration();
        await sequelize.authenticate();
        await ensureAuthSchema(sequelize);
        await sequelize.sync();

        app.listen(PORT, () => {
            console.log(`Servidor rodando na porta ${PORT}`);
        });
    } catch (error) {
        console.error('Erro ao inicializar o servidor:', error.message);
        process.exit(1);
    }
}

startServer();
