const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/sequelize');

class TriggerModel extends Model {}

TriggerModel.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        nome: {
            type: DataTypes.STRING(50),
            allowNull: false,
            unique: true
        },
        icone: {
            type: DataTypes.STRING(50),
            allowNull: true
        }
    },
    {
        sequelize,
        modelName: 'Trigger',
        tableName: 'Gatilhos',
        timestamps: false
    }
);

module.exports = TriggerModel;
