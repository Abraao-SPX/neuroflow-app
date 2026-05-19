const { Op } = require('sequelize');
const sequelize = require('../config/sequelize');
const CheckinModel = require('../models/CheckinModel');
require('../models/CheckinTriggerModel');
const TriggerModel = require('../models/TriggerModel');
const {
    isPlainObject,
    normalizeDateOnly,
    normalizeRequiredString,
    parsePositiveInteger
} = require('../utils/validation');

function normalizeTriggers(value) {
    if (!Array.isArray(value)) {
        return { error: 'Gatilhos deve ser um array.' };
    }

    if (value.length > 30) {
        return { error: 'Gatilhos deve ter no maximo 30 itens.' };
    }

    const ids = [];
    const names = [];

    for (const item of value) {
        if (typeof item === 'number' && Number.isInteger(item) && item > 0) {
            ids.push(item);
            continue;
        }

        const normalized = normalizeRequiredString(item, 'Cada gatilho', { max: 50 });
        if (normalized.error) {
            return { error: normalized.error };
        }
        names.push(normalized.value);
    }

    return {
        value: {
            ids: [...new Set(ids)],
            names: [...new Set(names)]
        }
    };
}

function normalizeCheckinPayload(body, { requireAll = false } = {}) {
    if (!isPlainObject(body)) {
        return { error: 'Corpo da requisicao deve ser um objeto JSON.' };
    }

    const data = {};
    const relationshipData = {};

    if (body.humor !== undefined) {
        const humor = normalizeRequiredString(body.humor, 'Humor', { max: 50 });
        if (humor.error) return { error: humor.error };
        data.humor = humor.value;
    } else if (requireAll) {
        return { error: 'Humor e obrigatorio.' };
    }

    if (body.gatilhos !== undefined) {
        const gatilhos = normalizeTriggers(body.gatilhos);
        if (gatilhos.error) return { error: gatilhos.error };
        relationshipData.triggers = gatilhos.value;
    } else if (requireAll) {
        relationshipData.triggers = { ids: [], names: [] };
    }

    if (body.dataCheckin !== undefined) {
        const dataCheckin = normalizeDateOnly(body.dataCheckin, 'Data do check-in');
        if (dataCheckin.error) return { error: dataCheckin.error };
        data.dataCheckin = dataCheckin.value;
    }

    if (Object.keys(data).length === 0 && relationshipData.triggers === undefined) {
        return { error: 'Nenhum campo valido para atualizar.' };
    }

    return { data, relationshipData };
}

async function resolveTriggers(normalizedTriggers, transaction) {
    if (!normalizedTriggers) {
        return null;
    }

    const { ids, names } = normalizedTriggers;
    if (ids.length === 0 && names.length === 0) {
        return [];
    }

    const triggers = await TriggerModel.findAll({
        where: {
            [Op.or]: [
                ids.length ? { id: ids } : null,
                names.length ? { nome: names } : null
            ].filter(Boolean)
        },
        transaction
    });

    const foundIds = new Set(triggers.map((trigger) => trigger.id));
    const foundNames = new Set(triggers.map((trigger) => trigger.nome));
    const missingIds = ids.filter((id) => !foundIds.has(id));
    const missingNames = names.filter((name) => !foundNames.has(name));

    if (missingIds.length || missingNames.length) {
        return {
            error: `Gatilhos inexistentes: ${[...missingIds, ...missingNames].join(', ')}.`
        };
    }

    return triggers;
}

function mapCheckin(checkin) {
    const plain = checkin.toJSON ? checkin.toJSON() : checkin;
    const triggers = plain.triggers || [];

    return {
        id: plain.id,
        usuarioId: plain.usuarioId,
        humor: plain.humor,
        dataCheckin: plain.dataCheckin,
        data_checkin: plain.dataCheckin,
        createdAt: plain.createdAt,
        updatedAt: plain.updatedAt,
        gatilhos: triggers.map((trigger) => trigger.nome),
        gatilhoIds: triggers.map((trigger) => trigger.id)
    };
}

async function findUserCheckin(checkinId, userId, transaction) {
    return CheckinModel.findOne({
        where: {
            id: checkinId,
            usuarioId: userId
        },
        include: [{
            model: TriggerModel,
            as: 'triggers',
            through: { attributes: [] }
        }],
        transaction
    });
}

class CheckinController {
    static async create(req, res) {
        const transaction = await sequelize.transaction();

        try {
            const usuarioId = req.user.id;
            const { data, relationshipData, error } = normalizeCheckinPayload(req.body, { requireAll: true });

            if (error) {
                await transaction.rollback();
                return res.status(400).json({ success: false, message: error });
            }

            const triggers = await resolveTriggers(relationshipData.triggers, transaction);
            if (triggers?.error) {
                await transaction.rollback();
                return res.status(400).json({ success: false, message: triggers.error });
            }

            const checkin = await CheckinModel.create({
                usuarioId,
                ...data
            }, { transaction });

            await checkin.setTriggers(triggers, { transaction });
            await transaction.commit();

            const savedCheckin = await findUserCheckin(checkin.id, usuarioId);
            return res.status(201).json({ success: true, message: 'Check-in salvo com sucesso!', data: mapCheckin(savedCheckin) });
        } catch (error) {
            await transaction.rollback();
            console.error('Erro ao salvar check-in:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao salvar check-in.' });
        }
    }

    static async getMyCheckins(req, res) {
        try {
            const usuarioId = req.user.id;
            const checkins = await CheckinModel.findAll({
                where: { usuarioId },
                include: [{
                    model: TriggerModel,
                    as: 'triggers',
                    through: { attributes: [] }
                }],
                order: [['data_checkin', 'DESC'], ['createdAt', 'DESC']]
            });
            return res.status(200).json({ success: true, data: checkins.map(mapCheckin) });
        } catch (error) {
            console.error('Erro ao buscar check-ins:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao buscar check-ins.' });
        }
    }

    static async getById(req, res) {
        try {
            const checkinId = parsePositiveInteger(req.params.id);
            if (!checkinId) {
                return res.status(400).json({ success: false, message: 'ID do check-in invalido.' });
            }

            const checkin = await findUserCheckin(checkinId, req.user.id);

            if (!checkin) {
                return res.status(404).json({ success: false, message: 'Check-in nao encontrado.' });
            }

            return res.status(200).json({ success: true, data: mapCheckin(checkin) });
        } catch (error) {
            console.error('Erro ao buscar check-in:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao buscar check-in.' });
        }
    }

    static async replace(req, res) {
        return CheckinController.persistUpdate(req, res, {
            requireAll: true,
            successMessage: 'Check-in substituido com sucesso!'
        });
    }

    static async update(req, res) {
        return CheckinController.persistUpdate(req, res, {
            requireAll: false,
            successMessage: 'Check-in atualizado com sucesso!'
        });
    }

    static async persistUpdate(req, res, { requireAll, successMessage }) {
        const transaction = await sequelize.transaction();

        try {
            const checkinId = parsePositiveInteger(req.params.id);
            if (!checkinId) {
                await transaction.rollback();
                return res.status(400).json({ success: false, message: 'ID do check-in invalido.' });
            }

            const { data, relationshipData, error } = normalizeCheckinPayload(req.body, { requireAll });
            if (error) {
                await transaction.rollback();
                return res.status(400).json({ success: false, message: error });
            }

            const checkin = await findUserCheckin(checkinId, req.user.id, transaction);
            if (!checkin) {
                await transaction.rollback();
                return res.status(404).json({ success: false, message: 'Check-in nao encontrado.' });
            }

            if (Object.keys(data).length > 0) {
                await checkin.update(data, { transaction });
            }

            if (relationshipData.triggers !== undefined) {
                const triggers = await resolveTriggers(relationshipData.triggers, transaction);
                if (triggers?.error) {
                    await transaction.rollback();
                    return res.status(400).json({ success: false, message: triggers.error });
                }
                await checkin.setTriggers(triggers, { transaction });
            }

            await transaction.commit();

            const updatedCheckin = await findUserCheckin(checkinId, req.user.id);
            return res.status(200).json({ success: true, message: successMessage, data: mapCheckin(updatedCheckin) });
        } catch (error) {
            await transaction.rollback();
            console.error('Erro ao atualizar check-in:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao atualizar check-in.' });
        }
    }

    static async delete(req, res) {
        try {
            const checkinId = parsePositiveInteger(req.params.id);
            if (!checkinId) {
                return res.status(400).json({ success: false, message: 'ID do check-in invalido.' });
            }

            const deletedCount = await CheckinModel.destroy({
                where: {
                    id: checkinId,
                    usuarioId: req.user.id
                }
            });

            if (deletedCount === 0) {
                return res.status(404).json({ success: false, message: 'Check-in nao encontrado.' });
            }

            return res.status(204).send();
        } catch (error) {
            console.error('Erro ao deletar check-in:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao deletar check-in.' });
        }
    }
}

module.exports = CheckinController;
