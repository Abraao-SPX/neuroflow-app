const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/sequelize');
const CheckinModel = require('./CheckinModel');
const TriggerModel = require('./TriggerModel');

class CheckinTriggerModel extends Model {}

CheckinTriggerModel.init(
    {
        checkinId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            field: 'checkin_id',
            references: {
                model: CheckinModel,
                key: 'id'
            },
            onDelete: 'CASCADE'
        },
        gatilhoId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            field: 'gatilho_id',
            references: {
                model: TriggerModel,
                key: 'id'
            },
            onDelete: 'CASCADE'
        }
    },
    {
        sequelize,
        modelName: 'CheckinTrigger',
        tableName: 'CheckinGatilhos',
        timestamps: false
    }
);

CheckinModel.belongsToMany(TriggerModel, {
    through: CheckinTriggerModel,
    foreignKey: {
        name: 'checkinId',
        field: 'checkin_id'
    },
    otherKey: {
        name: 'gatilhoId',
        field: 'gatilho_id'
    },
    as: 'triggers'
});

TriggerModel.belongsToMany(CheckinModel, {
    through: CheckinTriggerModel,
    foreignKey: {
        name: 'gatilhoId',
        field: 'gatilho_id'
    },
    otherKey: {
        name: 'checkinId',
        field: 'checkin_id'
    },
    as: 'checkins'
});

module.exports = CheckinTriggerModel;
