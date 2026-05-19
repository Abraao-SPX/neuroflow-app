const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/sequelize');
const UserModel = require('./UserModel');

class CheckinModel extends Model {}

CheckinModel.init({
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    usuarioId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        field: 'usuario_id',
        references: {
            model: UserModel,
            key: 'id'
        },
        onDelete: 'CASCADE'
    },
    humor: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    dataCheckin: {
        type: DataTypes.DATEONLY,
        field: 'data_checkin',
        defaultValue: DataTypes.NOW
    }
}, {
    sequelize,
    modelName: 'Checkin',
    tableName: 'checkins',
    timestamps: true
});

UserModel.hasMany(CheckinModel, {
    foreignKey: {
        name: 'usuarioId',
        field: 'usuario_id'
    },
    as: 'checkins'
});

CheckinModel.belongsTo(UserModel, {
    foreignKey: {
        name: 'usuarioId',
        field: 'usuario_id'
    },
    as: 'user'
});

module.exports = CheckinModel;
