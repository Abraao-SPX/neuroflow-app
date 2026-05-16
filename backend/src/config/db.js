const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'neuroflow_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Teste rápido para ver se conecta quando o arquivo é chamado
pool.getConnection()
    .then(conn => {
        console.log('✅ Conexão com o banco de dados MySQL estabelecida com sucesso!');
        conn.release();
    })
    .catch(err => {
        console.error('❌ Erro ao conectar com o banco de dados:', err.message);
    });

module.exports = pool;