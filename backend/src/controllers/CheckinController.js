const CheckinModel = require('../models/CheckinModel');

class CheckinController {
    static async create(req, res) {
        try {
            const { humor, gatilhos } = req.body;
            const usuarioId = req.user.id;

            if (!humor) {
                return res.status(400).json({ message: 'O campo humor é obrigatório.' });
            }

            const checkin = await CheckinModel.create({
                usuarioId,
                humor,
                gatilhos: gatilhos || []
            });

            return res.status(201).json({ message: 'Check-in salvo com sucesso!', data: checkin });
        } catch (error) {
            console.error('Erro ao salvar check-in:', error);
            return res.status(500).json({ message: 'Erro interno ao salvar check-in.' });
        }
    }

    static async getMyCheckins(req, res) {
        try {
            const usuarioId = req.user.id;
            const checkins = await CheckinModel.findAll({
                where: { usuarioId },
                order: [['data_checkin', 'DESC'], ['createdAt', 'DESC']]
            });
            return res.status(200).json({ data: checkins });
        } catch (error) {
            console.error('Erro ao buscar check-ins:', error);
            return res.status(500).json({ message: 'Erro interno ao buscar check-ins.' });
        }
    }
}

module.exports = CheckinController;
