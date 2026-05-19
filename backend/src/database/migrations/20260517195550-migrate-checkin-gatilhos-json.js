'use strict';

function normalizeJsonTriggers(value) {
  if (!value) return [];

  let parsed = value;
  if (typeof value === 'string') {
    try {
      parsed = JSON.parse(value);
    } catch (error) {
      return [];
    }
  }

  if (!Array.isArray(parsed)) {
    return [];
  }

  return [...new Set(parsed
    .filter((item) => typeof item === 'string')
    .map((item) => item.trim())
    .filter(Boolean))];
}

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('checkins');
    if (!table.gatilhos) {
      return;
    }

    const [rows] = await queryInterface.sequelize.query(
      'SELECT id, gatilhos FROM checkins WHERE gatilhos IS NOT NULL'
    );

    for (const row of rows) {
      const triggerNames = normalizeJsonTriggers(row.gatilhos);
      for (const name of triggerNames) {
        await queryInterface.sequelize.query(
          'INSERT IGNORE INTO Gatilhos (nome, icone) VALUES (?, NULL)',
          { replacements: [name] }
        );

        const [triggerRows] = await queryInterface.sequelize.query(
          'SELECT id FROM Gatilhos WHERE nome = ? LIMIT 1',
          { replacements: [name] }
        );

        if (!triggerRows[0]) continue;

        await queryInterface.sequelize.query(
          'INSERT IGNORE INTO CheckinGatilhos (checkin_id, gatilho_id) VALUES (?, ?)',
          { replacements: [row.id, triggerRows[0].id] }
        );
      }
    }

    await queryInterface.removeColumn('checkins', 'gatilhos');
  },

  async down(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('checkins');
    if (!table.gatilhos) {
      await queryInterface.addColumn('checkins', 'gatilhos', {
        type: Sequelize.JSON,
        allowNull: true
      });
    }
  }
};
