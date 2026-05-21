import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_drawer.dart';

class RegulationPlanScreen extends StatefulWidget {
  const RegulationPlanScreen({super.key});

  @override
  State<RegulationPlanScreen> createState() => _RegulationPlanScreenState();
}

class _RegulationPlanScreenState extends State<RegulationPlanScreen> {
  static const String _completedKey = 'neuroflow_plan_completed';
  static const String _customKey = 'neuroflow_plan_custom';
  static const Color _bgHeader = Color(0xFFD1E3E7);
  static const Color _bgBody = Color(0xFFFDF9F0);
  static const Color _textColor = Color(0xFF4A6572);

  static const List<String> _moods = [
    'Todos',
    'Ansioso',
    'Triste',
    'Cansado',
    'Normal',
    'Otimo',
  ];

  static const List<_PlanStrategy> _defaultStrategies = [
    _PlanStrategy(
      id: 'ansioso-breath',
      mood: 'Ansioso',
      title: 'Respirar por 2 minutos',
      description: 'Inspire por 4 segundos, segure por 2 e solte por 6.',
      icon: Icons.air,
      color: Color(0xFF87C9C1),
    ),
    _PlanStrategy(
      id: 'ansioso-grounding',
      mood: 'Ansioso',
      title: 'Aterramento 5-4-3-2-1',
      description: 'Nomeie 5 coisas que ve, 4 que toca, 3 que ouve, 2 cheiros e 1 sabor.',
      icon: Icons.touch_app_outlined,
      color: Color(0xFF9EB6C8),
    ),
    _PlanStrategy(
      id: 'triste-contact',
      mood: 'Triste',
      title: 'Mandar mensagem para alguem seguro',
      description: 'Escolha uma pessoa de confianca e envie uma mensagem simples.',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF9B87C9),
    ),
    _PlanStrategy(
      id: 'triste-care',
      mood: 'Triste',
      title: 'Fazer um cuidado pequeno',
      description: 'Beba agua, tome banho ou organize um espaco pequeno.',
      icon: Icons.spa_outlined,
      color: Color(0xFFE7BE8C),
    ),
    _PlanStrategy(
      id: 'cansado-rest',
      mood: 'Cansado',
      title: 'Pausa sem tela',
      description: 'Separe 10 minutos para descansar sem notificacoes.',
      icon: Icons.bedtime_outlined,
      color: Color(0xFFB4D9A7),
    ),
    _PlanStrategy(
      id: 'cansado-priority',
      mood: 'Cansado',
      title: 'Escolher so uma prioridade',
      description: 'Defina a menor tarefa importante e deixe o resto para depois.',
      icon: Icons.flag_outlined,
      color: Color(0xFFE49A8F),
    ),
    _PlanStrategy(
      id: 'normal-check',
      mood: 'Normal',
      title: 'Manter a rotina base',
      description: 'Confira sono, agua, alimentacao e uma pausa no dia.',
      icon: Icons.check_circle_outline,
      color: Color(0xFF87C9C1),
    ),
    _PlanStrategy(
      id: 'otimo-record',
      mood: 'Otimo',
      title: 'Registrar o que ajudou',
      description: 'Anote o que funcionou hoje para repetir em outros dias.',
      icon: Icons.edit_note,
      color: Color(0xFFE7BE8C),
    ),
  ];

  final Set<String> _completedIds = {};
  List<_PlanStrategy> _customStrategies = [];
  String _selectedMood = 'Todos';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];
    final customJson = prefs.getStringList(_customKey) ?? [];

    final customStrategies = <_PlanStrategy>[];
    for (final item in customJson) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is! Map<String, dynamic>) continue;

        final id = decoded['id']?.toString() ?? '';
        final mood = decoded['mood']?.toString() ?? '';
        final title = decoded['title']?.toString() ?? '';
        final description = decoded['description']?.toString() ?? '';
        if (id.isEmpty || mood.isEmpty || title.isEmpty) continue;

        customStrategies.add(
          _PlanStrategy(
            id: id,
            mood: mood,
            title: title,
            description: description,
            icon: Icons.add_task,
            color: const Color(0xFF9EB6C8),
            isCustom: true,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    if (!mounted) return;
    setState(() {
      _completedIds
        ..clear()
        ..addAll(completed);
      _customStrategies = customStrategies;
      _isLoading = false;
    });
  }

  Future<void> _saveCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, _completedIds.toList());
  }

  Future<void> _saveCustomStrategies() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _customStrategies.map((strategy) {
      return jsonEncode({
        'id': strategy.id,
        'mood': strategy.mood,
        'title': strategy.title,
        'description': strategy.description,
      });
    }).toList();

    await prefs.setStringList(_customKey, encoded);
  }

  List<_PlanStrategy> get _visibleStrategies {
    final allStrategies = [..._defaultStrategies, ..._customStrategies];
    if (_selectedMood == 'Todos') return allStrategies;
    return allStrategies
        .where((strategy) => strategy.mood == _selectedMood)
        .toList();
  }

  int get _completedVisibleCount {
    return _visibleStrategies
        .where((strategy) => _completedIds.contains(strategy.id))
        .length;
  }

  Future<void> _toggleStrategy(_PlanStrategy strategy, bool? checked) async {
    setState(() {
      if (checked == true) {
        _completedIds.add(strategy.id);
      } else {
        _completedIds.remove(strategy.id);
      }
    });

    await _saveCompleted();
  }

  Future<void> _addCustomStrategy() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final initialMood = _selectedMood == 'Todos' ? 'Ansioso' : _selectedMood;
    var selectedMood = initialMood;

    final result = await showDialog<_CustomStrategyInput>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova estrategia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMood,
                      decoration: const InputDecoration(labelText: 'Humor'),
                      items: _moods
                          .where((mood) => mood != 'Todos')
                          .map(
                            (mood) => DropdownMenuItem(
                              value: mood,
                              child: Text(mood),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedMood = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'O que fazer',
                        hintText: 'Ex: caminhar 5 minutos',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Detalhes',
                        hintText: 'Explique como essa acao ajuda.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.pop(
                      context,
                      _CustomStrategyInput(
                        mood: selectedMood,
                        title: title,
                        description: descriptionController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (result == null) return;

    final strategy = _PlanStrategy(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      mood: result.mood,
      title: result.title,
      description: result.description,
      icon: Icons.add_task,
      color: const Color(0xFF9EB6C8),
      isCustom: true,
    );

    setState(() {
      _customStrategies = [..._customStrategies, strategy];
      _selectedMood = result.mood;
    });

    await _saveCustomStrategies();
  }

  Future<void> _deleteCustomStrategy(_PlanStrategy strategy) async {
    setState(() {
      _customStrategies = _customStrategies
          .where((item) => item.id != strategy.id)
          .toList();
      _completedIds.remove(strategy.id);
    });

    await _saveCustomStrategies();
    await _saveCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final visibleStrategies = _visibleStrategies;
    final progress = visibleStrategies.isEmpty
        ? 0.0
        : _completedVisibleCount / visibleStrategies.length;

    return Scaffold(
      backgroundColor: _bgBody,
      endDrawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: _addCustomStrategy,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: Column(
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
              color: _bgHeader,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Meu Plano',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: _textColor,
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                    children: [
                      _ProgressCard(
                        completed: _completedVisibleCount,
                        total: visibleStrategies.length,
                        progress: progress,
                      ),
                      const SizedBox(height: 16),
                      _MoodSelector(
                        moods: _moods,
                        selectedMood: _selectedMood,
                        onSelected: (mood) {
                          setState(() {
                            _selectedMood = mood;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Estrategias para hoje',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (visibleStrategies.isEmpty)
                        const _EmptyPlanCard()
                      else
                        ...visibleStrategies.map(
                          (strategy) => _StrategyCard(
                            strategy: strategy,
                            isCompleted: _completedIds.contains(strategy.id),
                            onChanged: (checked) =>
                                _toggleStrategy(strategy, checked),
                            onDelete: strategy.isCustom
                                ? () => _deleteCustomStrategy(strategy)
                                : null,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlanStrategy {
  const _PlanStrategy({
    required this.id,
    required this.mood,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  final String id;
  final String mood;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCustom;
}

class _CustomStrategyInput {
  const _CustomStrategyInput({
    required this.mood,
    required this.title,
    required this.description,
  });

  final String mood;
  final String title;
  final String description;
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _RegulationPlanScreenState._textColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Plano de regulacao',
                    style: TextStyle(
                      color: _RegulationPlanScreenState._textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$completed/$total',
                  style: const TextStyle(
                    color: _RegulationPlanScreenState._textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              total == 0
                  ? 'Adicione sua primeira estrategia personalizada.'
                  : 'Marque o que voce conseguiu fazer hoje.',
              style: TextStyle(
                color: _RegulationPlanScreenState._textColor.withValues(
                  alpha: 0.75,
                ),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                backgroundColor: const Color(0xFFD1E3E7),
                color: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.moods,
    required this.selectedMood,
    required this.onSelected,
  });

  final List<String> moods;
  final String selectedMood;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mood in moods)
          ChoiceChip(
            label: Text(mood),
            selected: selectedMood == mood,
            onSelected: (_) => onSelected(mood),
            selectedColor: const Color(0xFFD1E3E7),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedMood == mood
                  ? _RegulationPlanScreenState._textColor
                  : _RegulationPlanScreenState._textColor.withValues(
                      alpha: 0.75,
                    ),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: _RegulationPlanScreenState._textColor.withValues(
                alpha: selectedMood == mood ? 0.28 : 0.14,
              ),
            ),
          ),
      ],
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({
    required this.strategy,
    required this.isCompleted,
    required this.onChanged,
    required this.onDelete,
  });

  final _PlanStrategy strategy;
  final bool isCompleted;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _RegulationPlanScreenState._textColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: strategy.color.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(strategy.icon, color: _RegulationPlanScreenState._textColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF9F0),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          strategy.mood,
                          style: const TextStyle(
                            color: _RegulationPlanScreenState._textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (strategy.isCustom) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Seu',
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strategy.title,
                    style: TextStyle(
                      color: _RegulationPlanScreenState._textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (strategy.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      strategy.description,
                      style: TextStyle(
                        color: _RegulationPlanScreenState._textColor
                            .withValues(alpha: 0.76),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Checkbox(
                  value: isCompleted,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: onChanged,
                ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Remover estrategia',
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
  const _EmptyPlanCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _RegulationPlanScreenState._textColor.withValues(alpha: 0.18),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'Nenhuma estrategia nesse filtro. Toque em Adicionar para criar uma.',
          style: TextStyle(
            color: _RegulationPlanScreenState._textColor,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
