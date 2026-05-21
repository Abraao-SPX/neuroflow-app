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

    static async updateUser(req, res) {
        const transaction = await sequelize.transaction();

        try {
            const userId = Number.parseInt(req.params.id, 10);
            const { role, status } = req.body;

            if (Number.isNaN(userId) || userId <= 0) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'ID de usuario invalido.'
                });
            }

            if (role === undefined && status === undefined) {
                await transaction.rollback();
                return res.status(400).json({
                    success: false,
                    message: 'Nenhum campo informado para atualizacao.'
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

            let updated = false;

            // Atualiza status (ban/active)
            if (status !== undefined) {
                if (status !== 'active' && status !== 'banned') {
                    await transaction.rollback();
                    return res.status(400).json({
                        success: false,
                        message: 'Status invalido. Valores permitidos: active, banned.'
                    });
                }

                if (req.userId === userId && status === 'banned') {
                    await transaction.rollback();
                    return res.status(400).json({
                        success: false,
                        message: 'O administrador nao pode banir a propria conta logada.'
                    });
                }

                if (user.role === 'admin' && status === 'banned') {
                    await transaction.rollback();
                    return res.status(400).json({
                        success: false,
                        message: 'Contas administrativas nao podem ser banidas.'
                    });
                }

                if (user.status !== status) {
                    user.status = status;
                    updated = true;

                    if (status === 'banned') {
                        await RefreshTokenModel.destroy({ where: { userId }, transaction });
                    }
                }
            }

            // Atualiza role
            if (role !== undefined) {
                if (role !== 'admin' && role !== 'user' && role !== 'parent') {
                    await transaction.rollback();
                    return res.status(400).json({
                        success: false,
                        message: 'Role invalida. Valores permitidos: admin, user, parent.'
                    });
                }

                if (user.status === 'banned' && role === 'admin') {
                    await transaction.rollback();
                    return res.status(400).json({
                        success: false,
                        message: 'Reative o usuario antes de torna-lo administrador.'
                    });
                }
                
                if (user.role !== role) {
                    user.role = role;
                    updated = true;
                }
            }

            if (updated) {
                await user.save({ transaction });
            }

            await transaction.commit();

            return res.status(200).json({
                success: true,
                message: 'Usuario atualizado com sucesso.',
                data: mapUser(user)
            });
        } catch (error) {
            await transaction.rollback();

            console.error('[AdminController] Erro ao atualizar usuario:', error);
            return res.status(500).json({
                success: false,
                message: 'Erro interno ao atualizar usuario.'
            });
        }
    }
}

module.exports = AdminController;
