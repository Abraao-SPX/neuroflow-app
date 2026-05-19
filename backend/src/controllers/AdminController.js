const sequelize = require('../config/sequelize');
const CheckinModel = require('../models/CheckinModel');
const RefreshTokenModel = require('../models/RefreshTokenModel');
const TaskSequelizeModel = require('../models/TaskSequelizeModel');
const UserModel = require('../models/UserModel');

function mapUser(user) {
    return {
        id: user.id,
        name: user.username,
        username: user.username,
        email: user.email,
        role: user.role,
        created_at: user.createdAt
    };
}

class AdminController {
    static async getAllUsers(req, res) {
        try {
            const users = await UserModel.findAll({
                attributes: ['id', 'username', 'email', 'role', 'createdAt'],
                order: [['createdAt', 'DESC']]
            });

            return res.status(200).json({ success: true, data: users.map(mapUser) });
        } catch (error) {
            console.error('[AdminController] Erro ao buscar usuarios:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao buscar usuarios.'
            });
        }
    }

    static async deleteUser(req, res) {
        const transaction = await sequelize.transaction();

        try {
            const userId = Number.parseInt(req.params.id, 10);

            if (Number.isNaN(userId) || userId <= 0) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'ID de usuario invalido.'
                });
            }

            if (req.userId === userId) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'O administrador nao pode apagar a propria conta logada.'
                });
            }

            const user = await UserModel.findByPk(userId, { transaction });
            if (!user) {
                await transaction.rollback();
                return res.status(404).json({
                    success: false,
                    message: 'Usuario nao encontrado.'
                });
            }

            await RefreshTokenModel.destroy({ where: { userId }, transaction });
            await CheckinModel.destroy({ where: { usuarioId: userId }, transaction });
            await TaskSequelizeModel.destroy({ where: { usuarioId: userId }, transaction });
            await user.destroy({ transaction });

            await transaction.commit();

            return res.status(204).send();
        } catch (error) {
            await transaction.rollback();

            console.error('[AdminController] Erro ao apagar usuario:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao apagar usuario.'
            });
        }
    }
}

module.exports = AdminController;
