import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4F46E5);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView( // Permite rolar se o teclado abrir
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bem-vindo de volta",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Faça login para continuar no NeuroFlow"),
            const SizedBox(height: 40),

            // CAMPO DE E-MAIL
            const TextField(
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // CAMPO DE SENHA
            const TextField(
              obscureText: true, // Esconde os caracteres da senha
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            
            const SizedBox(height: 30),

            // BOTÃO ENTRAR
            ElevatedButton(
              onPressed: () {
                // No futuro, aqui validaremos o login com o Back-end
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),

            const SizedBox(height: 20),

            // BOTÃO PARA IR PARA CADASTRO
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Não tem uma conta? Cadastre-se"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}