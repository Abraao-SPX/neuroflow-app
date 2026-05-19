'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    try {
      await queryInterface.describeTable('Gatilhos');
      return;
    } catch (error) {
      // Table does not exist yet.
    }

    await queryInterface.createTable('Gatilhos', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      nome: {
        type: Sequelize.STRING(50),
        allowNull: false,
        unique: true
      },
      icone: {
        type: Sequelize.STRING(50),
        allowNull: true
      }
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('Gatilhos');
  }
};
