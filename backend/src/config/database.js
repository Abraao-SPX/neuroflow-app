require('dotenv').config();
const { buildSequelizeCliConfig } = require('./databaseOptions');

module.exports = {
  development: buildSequelizeCliConfig(process.env.DB_NAME || 'neuroflow_db'),
  test: buildSequelizeCliConfig(process.env.DB_TEST_NAME || 'neuroflow_db_test'),
  production: buildSequelizeCliConfig(process.env.DB_NAME)
};
