const { DataTypes } = require('sequelize');

async function ensureAuthSchema(sequelize) {
    const queryInterface = sequelize.getQueryInterface();

    let table;
    try {
        table = await queryInterface.describeTable('Usuarios');
    } catch (error) {
        return;
    }

    if (table.senha && !table.password) {
        await queryInterface.renameColumn('Usuarios', 'senha', 'password');
        table = await queryInterface.describeTable('Usuarios');
    }

    if (!table.updated_at) {
        await queryInterface.addColumn('Usuarios', 'updated_at', {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW
        });
        table = await queryInterface.describeTable('Usuarios');
    }

    if (table.username) {
        const indexes = await queryInterface.showIndex('Usuarios');
        const hasUsernameUnique = indexes.some((index) => {
            return index.unique && index.fields.some((field) => field.attribute === 'username');
        });

        if (!hasUsernameUnique) {
            await queryInterface.addIndex('Usuarios', ['username'], {
                unique: true,
                name: 'usuarios_username_unique'
            });
        }
    }
}

module.exports = ensureAuthSchema;
