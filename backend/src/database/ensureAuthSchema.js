const { DataTypes } = require('sequelize');

async function ensureAuthSchema(sequelize) {
    const queryInterface = sequelize.getQueryInterface();

    await sequelize.query(`
        SET SESSION sql_mode = REPLACE(
            REPLACE(@@SESSION.sql_mode, 'NO_ZERO_IN_DATE', ''),
            'NO_ZERO_DATE',
            ''
        )
    `);

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

    await sequelize.query(`
        UPDATE Usuarios
        SET updated_at = CASE
            WHEN created_at IS NULL OR CAST(created_at AS CHAR) = '0000-00-00 00:00:00'
            THEN NOW()
            ELSE created_at
        END
        WHERE updated_at IS NULL
           OR CAST(updated_at AS CHAR) = '0000-00-00 00:00:00'
    `);

    await sequelize.query(`
        UPDATE Usuarios
        SET created_at = NOW()
        WHERE created_at IS NULL
           OR CAST(created_at AS CHAR) = '0000-00-00 00:00:00'
    `);

    if (table.username) {
        const indexes = await queryInterface.showIndex('Usuarios');
        const usernameUniqueIndexes = indexes.filter((index) => {
            return index.unique && index.fields.some((field) => field.attribute === 'username');
        });

        for (const index of usernameUniqueIndexes) {
            await queryInterface.removeIndex('Usuarios', index.name);
        }
    }
}

module.exports = ensureAuthSchema;
