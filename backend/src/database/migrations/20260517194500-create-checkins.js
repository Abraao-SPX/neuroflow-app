'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      await queryInterface.describeTable('checkins');
      return;
    } catch (error) {
      // Table does not exist yet.
    }

    await queryInterface.createTable('checkins', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      usuario_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Usuarios',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      humor: {
        type: Sequelize.STRING(50),
        allowNull: false
      },
      data_checkin: {
        type: Sequelize.DATEONLY,
        allowNull: false,
        defaultValue: Sequelize.literal('(CURRENT_DATE)')
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    await queryInterface.addIndex('checkins', ['usuario_id'], {
      name: 'checkins_usuario_id_idx'
    });
    await queryInterface.addIndex('checkins', ['usuario_id', 'data_checkin'], {
      name: 'checkins_usuario_data_idx'
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('checkins');
  }
};
