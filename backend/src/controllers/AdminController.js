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
        status: user.status,
        created_at: user.createdAt
    };
}

function buildSummary(users) {
    return users.reduce((summary, user) => {
        summary.total += 1;
        if (user.role === 'admin') summary.admins += 1;
        if (user.status === 'banned') summary.banned += 1;
        if (user.status !== 'banned') summary.active += 1;
        return summary;
    }, {
        total: 0,
        active: 0,
        banned: 0,
        admins: 0
    });
}

function parseBanValue(value) {
    if (value === true || value === 'true' || value === 1 || value === '1') {
        return true;
    }

    if (value === false || value === 'false' || value === 0 || value === '0') {
        return false;
    }

    return null;
}

class AdminController {
    static async getAllUsers(req, res) {
        try {
            const users = await UserModel.findAll({
                attributes: ['id', 'username', 'email', 'role', 'status', 'createdAt'],
                order: [['createdAt', 'DESC']]
            });

            return res.status(200).json({
                success: true,
                data: users.map(mapUser),
                summary: buildSummary(users)
            });
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

    static async setUserBanStatus(req, res) {
        const transaction = await sequelize.transaction();

        try {
            const userId = Number.parseInt(req.params.id, 10);
            const banned = parseBanValue(req.body?.banned);

            if (Number.isNaN(userId) || userId <= 0) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'ID de usuario invalido.'
                });
            }

            if (banned === null) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'O campo banned deve ser booleano.'
                });
            }

            if (req.userId === userId && banned) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'O administrador nao pode banir a propria conta logada.'
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

            if (user.role === 'admin' && banned) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'Contas administrativas nao podem ser banidas por esta tela.'
                });
            }

            user.status = banned ? 'banned' : 'active';
            await user.save({ transaction });

            if (banned) {
                await RefreshTokenModel.destroy({ where: { userId }, transaction });
            }

            await transaction.commit();

            return res.status(200).json({
                success: true,
                message: banned ? 'Usuario banido com sucesso.' : 'Usuario reativado com sucesso.',
                data: mapUser(user)
            });
        } catch (error) {
            await transaction.rollback();

            console.error('[AdminController] Erro ao alterar banimento do usuario:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao alterar banimento do usuario.'
            });
        }
    }

    static async promoteUserToAdmin(req, res) {
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

            const user = await UserModel.findByPk(userId, { transaction });
            if (!user) {
                await transaction.rollback();
                return res.status(404).json({
                    success: false,
                    message: 'Usuario nao encontrado.'
                });
            }

            if (user.status === 'banned') {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'Reative o usuario antes de torna-lo administrador.'
                });
            }

            if (user.role === 'admin') {
                await transaction.commit();
                return res.status(200).json({
                    success: true,
                    message: 'Usuario ja e administrador.',
                    data: mapUser(user)
                });
            }

            user.role = 'admin';
            await user.save({ transaction });

            await transaction.commit();

            return res.status(200).json({
                success: true,
                message: 'Usuario promovido a administrador com sucesso.',
                data: mapUser(user)
            });
        } catch (error) {
            await transaction.rollback();

            console.error('[AdminController] Erro ao promover usuario para admin:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao promover usuario para administrador.'
            });
        }
    }
}

module.exports = AdminController;
