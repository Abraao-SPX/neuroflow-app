require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sequelize = require('./src/config/sequelize');
require('./src/models/UserModel');
require('./src/models/TaskSequelizeModel');
const ensureAuthSchema = require('./src/database/ensureAuthSchema');
const { getJwtSecret, getTokenExpiration } = require('./src/config/auth');
const authMiddleware = require('./src/middlewares/authMiddleware');
const AuthController = require('./src/controllers/AuthController');
const taskRoutes = require('./src/routes/taskRoutes');
const authRoutes = require('./src/routes/authRoutes');
const adminRoutes = require('./src/routes/adminRoutes');

const app = express();
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/tasks', taskRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.get('/protected', authMiddleware, AuthController.protected);

const PORT = process.env.PORT || 3000;

async function startServer() {
    try {
        getJwtSecret();
        getTokenExpiration();
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
