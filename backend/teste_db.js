const mysql = require('mysql2/promise');

const senhas = ['', 'root', 'password', '12345', 'mysql', 'admin', '123456'];

async function testarSenhas() {
    console.log('🔍 Testando conexões com MySQL...\n');
    
    for (const senha of senhas) {
        try {
            const pool = mysql.createPool({
                host: 'localhost',
                user: 'root',
                password: senha,
                database: 'mysql',
                waitForConnections: true,
                connectionLimit: 1,
                queueLimit: 0
            });
            
            const conn = await pool.getConnection();
            conn.release();
            
            console.log(`✅ SENHA FUNCIONOU: "${senha}"`);
            console.log(`\nAtualize o .env com:\nDB_PASSWORD=${senha}\n`);
            process.exit(0);
        } catch (err) {
            console.log(`❌ Falhou com senha: "${senha}"`);
        }
    }
    
    console.log('\n⚠️ Nenhuma senha funcionou. MySQL pode não estar rodando.');
    process.exit(1);
}

testarSenhas();
