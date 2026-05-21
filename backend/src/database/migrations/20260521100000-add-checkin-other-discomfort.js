'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('checkins');
    if (table.outro_incomodo) {
      return;
    }

    await queryInterface.addColumn('checkins', 'outro_incomodo', {
      type: Sequelize.TEXT,
      allowNull: true
    });
  },

  async down(queryInterface) {
    const table = await queryInterface.describeTable('checkins');
    if (!table.outro_incomodo) {
      return;
    }

    await queryInterface.removeColumn('checkins', 'outro_incomodo');
  }
};
