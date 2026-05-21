'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('Usuarios');

    if (!table.parent_email) {
      await queryInterface.addColumn('Usuarios', 'parent_email', {
        type: Sequelize.STRING,
        allowNull: true
      });
    }

    if (!table.parent_verification_code) {
      await queryInterface.addColumn('Usuarios', 'parent_verification_code', {
        type: Sequelize.STRING,
        allowNull: true
      });
    }

    if (!table.parent_verification_expires) {
      await queryInterface.addColumn('Usuarios', 'parent_verification_expires', {
        type: Sequelize.DATE,
        allowNull: true
      });
    }

    if (!table.parent_verified_at) {
      await queryInterface.addColumn('Usuarios', 'parent_verified_at', {
        type: Sequelize.DATE,
        allowNull: true
      });
    }

    if (!table.parent_user_id) {
      await queryInterface.addColumn('Usuarios', 'parent_user_id', {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'Usuarios',
          key: 'id'
        },
        onDelete: 'SET NULL',
        onUpdate: 'CASCADE'
      });
    }

    if (!table.parent_child_id) {
      await queryInterface.addColumn('Usuarios', 'parent_child_id', {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'Usuarios',
          key: 'id'
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE'
      });
    }
  },

  async down(queryInterface) {
    const table = await queryInterface.describeTable('Usuarios');

    if (table.parent_child_id) {
      await queryInterface.removeColumn('Usuarios', 'parent_child_id');
    }

    if (table.parent_user_id) {
      await queryInterface.removeColumn('Usuarios', 'parent_user_id');
    }

    if (table.parent_verified_at) {
      await queryInterface.removeColumn('Usuarios', 'parent_verified_at');
    }

    if (table.parent_verification_expires) {
      await queryInterface.removeColumn('Usuarios', 'parent_verification_expires');
    }

    if (table.parent_verification_code) {
      await queryInterface.removeColumn('Usuarios', 'parent_verification_code');
    }

    if (table.parent_email) {
      await queryInterface.removeColumn('Usuarios', 'parent_email');
    }
  }
};
