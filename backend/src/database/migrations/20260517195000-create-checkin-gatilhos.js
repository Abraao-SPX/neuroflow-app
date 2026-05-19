'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      await queryInterface.describeTable('CheckinGatilhos');
      return;
    } catch (error) {
      // Table does not exist yet.
    }

    await queryInterface.createTable('CheckinGatilhos', {
      checkin_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        references: {
          model: 'checkins',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      gatilho_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        references: {
          model: 'Gatilhos',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      }
    });

    await queryInterface.addIndex('CheckinGatilhos', ['gatilho_id'], {
      name: 'checkin_gatilhos_gatilho_id_idx'
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('CheckinGatilhos');
  }
};
