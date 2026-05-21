import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/checkin_service.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  // 1. Mudamos para StatefulWidget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _MoodOption {
  const _MoodOption(this.label, this.emoji, this.color);

  final String label;
  final String emoji;
  final Color color;
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Variáveis para guardar o estado (o que foi selecionado)
  final TextEditingController _otherDiscomfortController =
      TextEditingController();
  String selectedMood = ''; // Guarda apenas um humor
  List<String> selectedTriggers = []; // Guarda vários gatilhos

  bool _isSaving = false;

  static const List<_MoodOption> _moodOptions = [
    _MoodOption('Ótimo', '😊', Color(0xFFB4D9A7)),
    _MoodOption('Normal', '😐', Color(0xFF9EB6C8)),
    _MoodOption('Cansado', '😔', Color(0xFFE7BE8C)),
    _MoodOption('Triste', '😞', Color(0xFF9B87C9)),
    _MoodOption('Ansioso', '😰', Color(0xFFE49A8F)),
    _MoodOption('Estressado', '😤', Color(0xFFE89F71)),
  ];

  @override
  void dispose() {
    _otherDiscomfortController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCheckin() async {
    if (Provider.of<AuthProvider>(context, listen: false).isParent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Responsaveis possuem acesso somente para visualizacao.',
          ),
        ),
      );
      return;
    }

    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um humor primeiro!')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await CheckinService.salvarCheckin(
        selectedMood,
        selectedTriggers,
        outroIncomodo: _otherDiscomfortController.text,
      );

      if (!mounted) return;

      setState(() {
        selectedMood = '';
        selectedTriggers.clear();
        _otherDiscomfortController.clear();
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seu check-in foi salvo com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/weekly');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgHeader = Color(0xFFD1E3E7);
    const Color bgBody = Color(0xFFFDF9F0);
    final isParent = Provider.of<AuthProvider>(context).isParent;

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
                    'Check-in diário',
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
                    style: TextStyle(
                      color: Color(0xFF1F2933),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (isParent) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF4A6572),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Modo responsavel: voce pode visualizar os registros do filho, mas nao pode criar novos check-ins.',
                              style: TextStyle(color: Color(0xFF4A6572)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 24) / 3;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final mood in _moodOptions)
                            _buildMoodItem(
                              mood.label,
                              mood.emoji,
                              mood.color,
                              width: cardWidth,
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'O que está te incomodando agora?',
                    style: TextStyle(
                      color: Color(0xFF1F2933),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: _otherDiscomfortController,
                    readOnly: isParent,
                    maxLines: 3,
                    maxLength: 500,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Outros',
                      hintText: 'Digite o que mais está te incomodando',
                      prefixIcon: const Icon(
                        Icons.edit_note_outlined,
                        color: Color(0xFF4A6572),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.green.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (isParent)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/weekly');
                      },
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Ver tabelas do filho'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSaveCheckin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6572),
                        disabledBackgroundColor: const Color(0xFFD1E3E7),
                        disabledForegroundColor: const Color(0xFF4A6572),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 8),
                                Text(
                                  "Salvar Check-in",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
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

  Widget _buildMoodItem(
    String label,
    String emoji,
    Color activeColor, {
    required double width,
  }) {
    bool isSelected = selectedMood == label;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Humor $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (Provider.of<AuthProvider>(context, listen: false).isParent) {
            return;
          }

          setState(() {
            selectedMood = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.38)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.9)
                  : Colors.black12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.04),
                blurRadius: isSelected ? 14 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 31)),
              ),
              const SizedBox(height: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF4A6572),
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4A6572),
                      size: 15,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTriggerItem(IconData icon, String label) {
    bool isSelected = selectedTriggers.contains(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (Provider.of<AuthProvider>(context, listen: false).isParent) {
            return;
          }

          setState(() {
            if (isSelected) {
              selectedTriggers.remove(label);
            } else {
              selectedTriggers.add(label);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDFF0DE) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF7DBA84) : Colors.black12,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E3E7).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4A6572)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF1F2933),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        key: ValueKey('selected'),
                        color: Color(0xFF4A8F58),
                        size: 22,
                      )
                    : const Icon(
                        Icons.radio_button_unchecked,
                        key: ValueKey('unselected'),
                        color: Colors.black26,
                        size: 22,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
