'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('Usuarios');
    if (table.status) {
      return;
    }

    await queryInterface.addColumn('Usuarios', 'status', {
      type: Sequelize.STRING(20),
      allowNull: false,
      defaultValue: 'active'
    });
  },

  async down(queryInterface) {
    const table = await queryInterface.describeTable('Usuarios');
    if (!table.status) {
      return;
    }

    await queryInterface.removeColumn('Usuarios', 'status');
  }
};
