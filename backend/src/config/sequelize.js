require('dotenv').config();
const { Sequelize } = require('sequelize');
const { buildSequelizeOptions, requiredEnv } = require('./databaseOptions');

const sequelize = new Sequelize(
    requiredEnv('DB_NAME', 'neuroflow_db'),
    requiredEnv('DB_USER', 'root'),
    requiredEnv('DB_PASSWORD', ''),
    buildSequelizeOptions()
);

module.exports = sequelize;
