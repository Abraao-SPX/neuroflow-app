const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/sequelize');
const UserModel = require('./UserModel');

class TaskSequelizeModel extends Model {}

TaskSequelizeModel.init(
    {
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
        titulo: {
            type: DataTypes.STRING(150),
            allowNull: false
        },
        descricao: {
            type: DataTypes.TEXT,
            allowNull: true
        },
        concluida: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: false
        }
    },
    {
        sequelize,
        modelName: 'Task',
        tableName: 'Tarefas'
    }
);

UserModel.hasMany(TaskSequelizeModel, {
    foreignKey: {
        name: 'usuarioId',
        field: 'usuario_id'
    },
    as: 'tasks'
});

TaskSequelizeModel.belongsTo(UserModel, {
    foreignKey: {
        name: 'usuarioId',
        field: 'usuario_id'
    },
    as: 'user'
});

module.exports = TaskSequelizeModel;
