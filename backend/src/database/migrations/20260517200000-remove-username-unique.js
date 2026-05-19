'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    const indexes = await queryInterface.showIndex('Usuarios');
    const usernameUniqueIndexes = indexes.filter((index) => {
      return index.unique && index.fields.some((field) => field.attribute === 'username');
    });

    for (const index of usernameUniqueIndexes) {
      await queryInterface.removeIndex('Usuarios', index.name);
    }
  },

  async down(queryInterface) {
    const indexes = await queryInterface.showIndex('Usuarios');
    const hasUsernameIndex = indexes.some((index) => index.name === 'usuarios_username_unique');

    if (!hasUsernameIndex) {
      await queryInterface.addIndex('Usuarios', ['username'], {
        unique: true,
        name: 'usuarios_username_unique'
      });
    }
  }
};
