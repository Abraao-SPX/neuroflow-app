'use strict';

async function addIndexIfMissing(queryInterface, tableName, fields, options) {
  const indexes = await queryInterface.showIndex(tableName);
  const exists = indexes.some((index) => index.name === options.name);
  if (!exists) {
    await queryInterface.addIndex(tableName, fields, options);
  }
}

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    await addIndexIfMissing(queryInterface, 'Tarefas', ['usuario_id'], {
      name: 'tarefas_usuario_id_idx'
    });

    await addIndexIfMissing(queryInterface, 'RefreshTokens', ['usuario_id'], {
      name: 'refresh_tokens_usuario_id_idx'
    });

    await addIndexIfMissing(queryInterface, 'checkins', ['usuario_id'], {
      name: 'checkins_usuario_id_idx'
    });

    await addIndexIfMissing(queryInterface, 'checkins', ['usuario_id', 'data_checkin'], {
      name: 'checkins_usuario_data_idx'
    });

    await addIndexIfMissing(queryInterface, 'CheckinGatilhos', ['gatilho_id'], {
      name: 'checkin_gatilhos_gatilho_id_idx'
    });
  },

  async down(queryInterface) {
    await queryInterface.removeIndex('Tarefas', 'tarefas_usuario_id_idx');
    await queryInterface.removeIndex('RefreshTokens', 'refresh_tokens_usuario_id_idx');
    await queryInterface.removeIndex('checkins', 'checkins_usuario_id_idx');
    await queryInterface.removeIndex('checkins', 'checkins_usuario_data_idx');
    await queryInterface.removeIndex('CheckinGatilhos', 'checkin_gatilhos_gatilho_id_idx');
  }
};
