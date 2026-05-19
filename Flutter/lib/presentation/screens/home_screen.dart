import 'package:flutter/material.dart';
import '../../data/services/checkin_service.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  // 1. Mudamos para StatefulWidget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Variáveis para guardar o estado (o que foi selecionado)
  String selectedMood = ''; // Guarda apenas um humor
  List<String> selectedTriggers = []; // Guarda vários gatilhos

  @override
  Widget build(BuildContext context) {
    const Color bgHeader = Color(0xFFD1E3E7);
    const Color bgBody = Color(0xFFFDF9F0);
    const Color selectedGreen = Color(0xFFB4E1B5);

    return Scaffold(
      backgroundColor: bgBody,
      endDrawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: bgHeader,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Daily Check-in',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6572),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xFF4A6572),
                            size: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como você está se sentindo hoje?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),

                  // --- LISTA DE GATILHOS ---
                  _buildTriggerItem(
                    Icons.wb_sunny_outlined,
                    'Luz do dia excessiva',
                  ),
                  _buildTriggerItem(
                    Icons.volume_up_outlined,
                    'Ruídos e Barulhos',
                  ),
                  _buildTriggerItem(
                    Icons.assignment_outlined,
                    'Excesso de tarefas',
                  ),
                  _buildTriggerItem(
                    Icons.front_hand_outlined,
                    'Toques indesejados',
                  ),
                  _buildTriggerItem(
                    Icons.psychology_outlined,
                    'Dificuldade de concentração',
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {
                      if (selectedMood.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecione um humor primeiro!'),
                          ),
                        );
                        return;
                      }

                      try {
                        await CheckinService.salvarCheckin(
                          selectedMood,
                          selectedTriggers,
                        );

                        if (!mounted) return;

                        // Limpar o form após salvar
                        setState(() {
                          selectedMood = '';
                          selectedTriggers.clear();
                        });

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sucesso!'),
                            content: const Text('Check-in salvo com sucesso!'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Erro'),
                            content: Text('Erro ao salvar: $e'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1E3E7),
                      foregroundColor: const Color(0xFF4A6572),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Salvar Check-in",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNÇÕES AUXILIARES COM LÓGICA DE CLIQUE ---

  Widget _buildMoodItem(String label, String emoji, Color activeColor) {
    bool isSelected = selectedMood == label;

    return GestureDetector(
      // Detecta o toque
      onTap: () {
        setState(() {
          selectedMood = label; // Atualiza a tela
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor
                  : Colors.white, // Muda a cor se selecionado
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected
                    ? Colors.green.withValues(alpha: 0.5)
                    : Colors.black12,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerItem(IconData icon, String label) {
    bool isSelected = selectedTriggers.contains(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedTriggers.remove(label); // Desmarca se já estiver marcado
            } else {
              selectedTriggers.add(label); // Marca se estiver desmarcado
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFB4E1B5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4A6572)),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
