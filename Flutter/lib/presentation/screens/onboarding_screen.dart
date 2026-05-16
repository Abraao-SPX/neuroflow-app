import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no seu design (Roxo suave e moderno)
    const Color primaryPurple = Color(0xFF4F46E5);
    const Color textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // LOGOTIPO: Ícone de Cérebro/Psicologia (NeuroFlow)
              const Icon(
                Icons.psychology_outlined,
                size: 110,
                color: primaryPurple,
              ),

              const SizedBox(height: 30),

              // TÍTULO
              const Text(
                'NeuroFlow',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 15),

              // SUBTÍTULO
              const Text(
                'Entenda seus gatilhos.\nCuide da sua mente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // BOTÃO COMEÇAR
              ElevatedButton(
                onPressed: () {
                  // Navega para a tela de Login
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
