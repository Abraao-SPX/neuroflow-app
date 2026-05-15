import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF4F46E5); 
    const Color textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // LOGO: Ícone de Cérebro (Psicologia)
              const Icon(
                Icons.psychology_outlined,
                size: 110,
                color: primaryPurple,
              ),
              
              const SizedBox(height: 24),

              // TÍTULO DO APP
              const Text(
                'NeuroFlow',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // SUBTÍTULO / SLOGAN
              const Text(
                'Entenda seus gatilhos.\nCuide da sua mente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // BOTÃO PARA INICIAR
              ElevatedButton(
                onPressed: () {
                  // Comando para ir para a tela de login
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Começar',
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}