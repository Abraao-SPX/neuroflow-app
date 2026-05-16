import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores baseadas na sua imagem
    const Color bgHeader = Color(0xFFD1E3E7); // Verde água do topo
    const Color bgBody = Color(0xFFFDF9F0);   // Bege clarinho do fundo
    const Color selectedGreen = Color(0xFFB4E1B5); // Verde do emoji selecionado

    return Scaffold(
      backgroundColor: bgBody,
      body: SingleChildScrollView( // Adicionado para permitir rolar a tela
        child: Column(
          children: [
            // --- PARTE 1: CABEÇALHO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: const BoxDecoration(
                color: bgHeader,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: const Center(
                child: Text(
                  'Daily Check-in',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A6572),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como você está se sentindo hoje?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- EMOJIS DE HUMOR ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMoodItem('Ótimo', '😊', selectedGreen),
                      _buildMoodItem('Normal', '😐', Colors.white),
                      _buildMoodItem('Cansado', '😔', Colors.white),
                      _buildMoodItem('Triste', '😞', Colors.white),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'O que está te incomodando agora?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- LISTA DE GATILHOS ---
                  _buildTriggerItem(Icons.wb_sunny_outlined, 'Luz do dia excessiva'),
                  _buildTriggerItem(Icons.volume_up_outlined, 'Ruídos e Barulhos'),
                  _buildTriggerItem(Icons.assignment_outlined, 'Excesso de tarefas'),
                  _buildTriggerItem(Icons.front_hand_outlined, 'Toques indesejados'),
                  _buildTriggerItem(Icons.psychology_outlined, 'Dificuldade de concentração'),

                  const SizedBox(height: 30),

                  // --- BOTÃO SALVAR ---
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1E3E7),
                      foregroundColor: const Color(0xFF4A6572),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Salvar Check-in",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20), // Espaço extra no final
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNÇÕES AUXILIARES (Ficam fora do build, mas dentro da classe) ---

  Widget _buildTriggerItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A6572)),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodItem(String label, String emoji, Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
