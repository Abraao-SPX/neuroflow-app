'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('Usuarios');

    if (table.senha && !table.password) {
      await queryInterface.renameColumn('Usuarios', 'senha', 'password');
    }

    await queryInterface.changeColumn('Usuarios', 'username', {
      type: Sequelize.STRING,
      allowNull: false
    });

    await queryInterface.changeColumn('Usuarios', 'email', {
      type: Sequelize.STRING,
      allowNull: true,
      unique: true
    });

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
  },

  async down(queryInterface, Sequelize) {
    const indexes = await queryInterface.showIndex('Usuarios');
    const hasUsernameUnique = indexes.some((index) => index.name === 'usuarios_username_unique');

    if (hasUsernameUnique) {
      await queryInterface.removeIndex('Usuarios', 'usuarios_username_unique');
    }

    const table = await queryInterface.describeTable('Usuarios');

    if (table.password && !table.senha) {
      await queryInterface.renameColumn('Usuarios', 'password', 'senha');
    }

    await queryInterface.changeColumn('Usuarios', 'email', {
      type: Sequelize.STRING,
      allowNull: false,
      unique: true
    });
  }
};
