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
    gatilhos: {
        type: DataTypes.JSON, // Armazena array de gatilhos como JSON
        allowNull: true
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
    timestamps: true // createdAt, updatedAt
});

UserModel.hasMany(CheckinModel, { foreignKey: 'usuario_id' });
CheckinModel.belongsTo(UserModel, { foreignKey: 'usuario_id' });

module.exports = CheckinModel;
