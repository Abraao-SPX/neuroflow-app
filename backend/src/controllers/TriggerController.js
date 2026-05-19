const TriggerModel = require('../models/TriggerModel');
const {
    isPlainObject,
    isUniqueConstraintError,
    normalizeOptionalString,
    normalizeRequiredString,
    parsePositiveInteger
} = require('../utils/validation');

function normalizeTriggerPayload(body, { requireAll = false } = {}) {
    if (!isPlainObject(body)) {
        return { error: 'Corpo da requisicao deve ser um objeto JSON.' };
    }

    const data = {};

    if (body.nome !== undefined || body.name !== undefined) {
        const nome = normalizeRequiredString(body.nome ?? body.name, 'Nome do gatilho', { max: 50 });
        if (nome.error) return { error: nome.error };
        data.nome = nome.value;
    } else if (requireAll) {
        return { error: 'O nome do gatilho e obrigatorio.' };
    }

    if (body.icone !== undefined || body.icon !== undefined) {
        const icone = normalizeOptionalString(body.icone ?? body.icon, 'Icone', { max: 50 });
        if (icone.error) return { error: icone.error };
        data.icone = icone.value;
    } else if (requireAll) {
        data.icone = null;
    }

    if (Object.keys(data).length === 0) {
        return { error: 'Nenhum campo valido para atualizar.' };
    }

    return { data };
}

function toResponse(trigger) {
    return {
        id: trigger.id,
        nome: trigger.nome,
        name: trigger.nome,
        icone: trigger.icone,
        icon: trigger.icone
    };
}

class TriggerController {
    static async getAll(req, res) {
        try {
            const triggers = await TriggerModel.findAll({
                order: [['nome', 'ASC']]
            });

            return res.status(200).json({
                success: true,
                data: triggers.map(toResponse)
            });
        } catch (error) {
            console.error('[TriggerController] Erro ao buscar gatilhos:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao buscar gatilhos.' });
        }
    }

    static async getById(req, res) {
        try {
            const triggerId = parsePositiveInteger(req.params.id);
            if (!triggerId) {
                return res.status(400).json({ success: false, message: 'ID do gatilho invalido.' });
            }

            const trigger = await TriggerModel.findByPk(triggerId);
            if (!trigger) {
                return res.status(404).json({ success: false, message: 'Gatilho nao encontrado.' });
            }

            return res.status(200).json({ success: true, data: toResponse(trigger) });
        } catch (error) {
            console.error('[TriggerController] Erro ao buscar gatilho:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao buscar gatilho.' });
        }
    }

    static async create(req, res) {
        try {
            const { data, error } = normalizeTriggerPayload(req.body, { requireAll: true });
            if (error) {
                return res.status(400).json({ success: false, message: error });
            }

            const trigger = await TriggerModel.create(data);
            return res.status(201).json({
                success: true,
                message: 'Gatilho criado com sucesso.',
                data: toResponse(trigger)
            });
        } catch (error) {
            if (isUniqueConstraintError(error)) {
                return res.status(409).json({ success: false, message: 'Gatilho ja cadastrado.' });
            }

            console.error('[TriggerController] Erro ao criar gatilho:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao criar gatilho.' });
        }
    }

    static async replace(req, res) {
        return TriggerController.persistUpdate(req, res, {
            requireAll: true,
            successMessage: 'Gatilho substituido com sucesso.'
        });
    }

    static async update(req, res) {
        return TriggerController.persistUpdate(req, res, {
            requireAll: false,
            successMessage: 'Gatilho atualizado com sucesso.'
        });
    }

    static async persistUpdate(req, res, { requireAll, successMessage }) {
        try {
            const triggerId = parsePositiveInteger(req.params.id);
            if (!triggerId) {
                return res.status(400).json({ success: false, message: 'ID do gatilho invalido.' });
            }

            const { data, error } = normalizeTriggerPayload(req.body, { requireAll });
            if (error) {
                return res.status(400).json({ success: false, message: error });
            }

            const trigger = await TriggerModel.findByPk(triggerId);
            if (!trigger) {
                return res.status(404).json({ success: false, message: 'Gatilho nao encontrado.' });
            }

            await trigger.update(data);
            return res.status(200).json({
                success: true,
                message: successMessage,
                data: toResponse(trigger)
            });
        } catch (error) {
            if (isUniqueConstraintError(error)) {
                return res.status(409).json({ success: false, message: 'Gatilho ja cadastrado.' });
            }

            console.error('[TriggerController] Erro ao atualizar gatilho:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao atualizar gatilho.' });
        }
    }

    static async delete(req, res) {
        try {
            const triggerId = parsePositiveInteger(req.params.id);
            if (!triggerId) {
                return res.status(400).json({ success: false, message: 'ID do gatilho invalido.' });
            }

            const deletedCount = await TriggerModel.destroy({
                where: { id: triggerId }
            });

            if (deletedCount === 0) {
                return res.status(404).json({ success: false, message: 'Gatilho nao encontrado.' });
            }

            return res.status(204).send();
        } catch (error) {
            console.error('[TriggerController] Erro ao deletar gatilho:', error);
            return res.status(500).json({ success: false, message: 'Erro interno ao deletar gatilho.' });
        }
    }
}

module.exports = TriggerController;
