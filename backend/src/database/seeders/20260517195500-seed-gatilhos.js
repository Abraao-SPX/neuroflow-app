'use strict';

const triggers = [
  { nome: 'Luz do dia excessiva', icone: 'wb_sunny_outlined' },
  { nome: 'Ruídos e Barulhos', icone: 'volume_up_outlined' },
  { nome: 'Excesso de tarefas', icone: 'assignment_outlined' },
  { nome: 'Toques indesejados', icone: 'front_hand_outlined' },
  { nome: 'Dificuldade de concentração', icone: 'psychology_outlined' },
  { nome: 'Barulho', icone: 'volume_up' },
  { nome: 'Luz Forte', icone: 'wb_sunny' },
  { nome: 'Multidão', icone: 'groups' },
  { nome: 'Conversas', icone: 'forum' },
  { nome: 'Cheiros', icone: 'air' },
  { nome: 'Calor', icone: 'thermostat' },
  { nome: 'Vibração', icone: 'vibration' }
];

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert(
      'Gatilhos',
      triggers,
      {
        updateOnDuplicate: ['icone']
      }
    );
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('Gatilhos', {
      nome: triggers.map((trigger) => trigger.nome)
    });
  }
};
