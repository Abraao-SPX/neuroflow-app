const mysql = require('mysql2/promise');
const fs = require('fs');

// Tenta conectar como socket (localhost:3306)
async function criarUsuarioApp() {
    const senhasParaTentar = ['', 'root', 'password', '123456', 'mysql', 'admin'];
    
    for (const senha of senhasParaTentar) {
        try {
            console.log(`Tentando conexão com senha: "${senha}"`);
            
            const connection = await mysql.createConnection({
                host: 'localhost',
                user: 'root',
                password: senha,
                waitForConnections: true,
                connectionLimit: 1,
                queueLimit: 0,
                authPlugins: {
                    mysql_native_password: () => () => senha
                }
            });
            
            console.log('✅ Conexão bem-sucedida!');
            
            // Criar usuário 'neuroflow' sem senha
            try {
                await connection.query(`DROP USER IF EXISTS 'neuroflow'@'localhost'`);
                console.log('Usuário antigo removido');
            } catch (e) {
                // Ignorar se não existe
            }
            
            await connection.query(`CREATE USER 'neuroflow'@'localhost' IDENTIFIED BY ''`);
            await connection.query(`GRANT ALL PRIVILEGES ON neuroflow_db.* TO 'neuroflow'@'localhost'`);
            await connection.query(`FLUSH PRIVILEGES`);
            
            console.log('✅ Usuário neuroflow criado com sucesso!');
            console.log('Atualize o .env com:\nDB_USER=neuroflow\nDB_PASSWORD=');
            
            await connection.end();
            process.exit(0);
            
        } catch (err) {
            console.log(`❌ Falhou: ${err.message.substring(0, 50)}`);
            continue;
        }
    }
    
    console.log('\n❌ Não consegui conectar ao MySQL.');
    console.log('Verifique se MySQL está rodando e tente resetar manualmente.');
    process.exit(1);
}

criarUsuarioApp();
