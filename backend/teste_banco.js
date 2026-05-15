async function testAuthentication() {
    const baseUrl = 'http://localhost:3000/api/auth';
    const numAleatorio = Math.floor(Math.random() * 10000);
    const mockUser = {
        name: `Usuario Teste ${numAleatorio}`,
        email: `teste${numAleatorio}@email.com`,
        password: "senhasegura123"
    };

    console.log("-----------------------------------------");
    console.log("🧪 INICIANDO TESTE DO BANCO DE DADOS (MYSQL)");
    console.log("-----------------------------------------\n");

    try {
        // 1. TESTE DE CADASTRO (REGISTER)
        console.log(`[1/2] 📝 Cadastrando usuário '${mockUser.email}'...`);
        const registerRes = await fetch(`${baseUrl}/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(mockUser)
        });
        
        const registerData = await registerRes.json();
        if (registerData.success) {
            console.log("✅ Cadastro realizado com sucesso! Foi salvo no MySQL.");
            console.log(registerData);
        } else {
            console.log("❌ Falha no cadastro:", registerData.message);
            return;
        }

        console.log("\n-----------------------------------------\n");

        // 2. TESTE DE LOGIN
        console.log(`[2/2] 🔑 Realizando login com '${mockUser.email}'...`);
        const loginRes = await fetch(`${baseUrl}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                email: mockUser.email,
                password: mockUser.password
            })
        });

        const loginData = await loginRes.json();
        if (loginData.success) {
            console.log("✅ Login realizado com sucesso! Banco retornou o usuário e validou a senha.");
            console.log("Token gerado:", loginData.token);
        } else {
            console.log("❌ Falha no login:", loginData.message);
        }

    } catch (error) {
        console.error("❌ ERRO NO TESTE! O Servidor Node está rodando?");
        console.error("Erro:", error.message);
    }
}

testAuthentication();