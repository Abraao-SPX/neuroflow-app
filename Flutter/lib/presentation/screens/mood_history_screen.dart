import 'package:flutter/material.dart';

import '../../data/services/checkin_service.dart';
import '../widgets/custom_drawer.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  List<dynamic> _checkins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckins();
  }

  Future<void> _loadCheckins() async {
    try {
      final data = await CheckinService.listarCheckins();
      if (!mounted) return;
      setState(() {
        _checkins = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar humores: $e')));
    }
  }

  String _readMood(dynamic item) {
    if (item is! Map) return 'Sem registro';
    final value = item['humor']?.toString().trim();
    return value == null || value.isEmpty ? 'Sem registro' : value;
  }

  String _moodEmoji(String mood) {
    final normalized = mood.toLowerCase();
    if (normalized.contains('ansioso')) return '😰';
    if (normalized.contains('estress')) return '😤';
    if (normalized.contains('otimo') || normalized.contains('ótimo')) {
      return '😊';
    }
    if (normalized.contains('normal')) return '😐';
    if (normalized.contains('cansado')) return '😔';
    if (normalized.contains('triste')) return '😞';
    return '🙂';
  }

  List<MapEntry<String, int>> _buildMoodEntries() {
    final counts = <String, int>{};

    for (final checkin in _checkins) {
      final mood = _readMood(checkin);
      counts[mood] = (counts[mood] ?? 0) + 1;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });

    return entries;
  }

  String _formatDateTime(dynamic dateStr, dynamic createdAt) {
    final createdText = createdAt?.toString();
    if (createdText == null || createdText.isEmpty) {
      return dateStr?.toString() ?? '';
    }

    try {
      final date = DateTime.parse(createdText).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year as $hour:$minute';
    } catch (_) {
      return dateStr?.toString() ?? createdText;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgHeader = Color(0xFFD1E3E7);
    const Color bgBody = Color(0xFFFDF9F0);
    const Color textColor = Color(0xFF4A6572);

    final entries = _buildMoodEntries();

    return Scaffold(
      backgroundColor: bgBody,
      endDrawer: const CustomDrawer(),
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
              color: bgHeader,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Humores',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: textColor,
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
                : _checkins.isEmpty
                ? const Center(child: Text('Nenhum humor registrado ainda.'))
                : RefreshIndicator(
                    onRefresh: _loadCheckins,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _MoodSummaryTable(
                          entries: entries,
                          total: _checkins.length,
                          textColor: textColor,
                          moodEmoji: _moodEmoji,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Registros recentes',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._checkins.map((item) {
                          final mood = _readMood(item);
                          final date = item is Map
                              ? _formatDateTime(
                                  item['data_checkin'],
                                  item['createdAt'],
                                )
                              : '';

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: textColor.withValues(alpha: 0.18),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: bgHeader,
                                child: Text(_moodEmoji(mood)),
                              ),
                              title: Text(
                                mood,
                                style: const TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(date),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MoodSummaryTable extends StatelessWidget {
  const _MoodSummaryTable({
    required this.entries,
    required this.total,
    required this.textColor,
    required this.moodEmoji,
  });

  final List<MapEntry<String, int>> entries;
  final int total;
  final Color textColor;
  final String Function(String mood) moodEmoji;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mood_outlined, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Como voce estava se sentindo',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Resumo dos humores registrados',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FixedColumnWidth(70),
                2: FixedColumnWidth(72),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E3E7).withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  children: const [
                    _MoodTableHeader('Humor'),
                    _MoodTableHeader('Qtd.'),
                    _MoodTableHeader('%'),
                  ],
                ),
                for (final entry in entries)
                  TableRow(
                    children: [
                      _MoodTableCell(
                        '${moodEmoji(entry.key)} ${entry.key}',
                        alignRight: false,
                      ),
                      _MoodTableCell('${entry.value}x'),
                      _MoodTableCell(
                        total == 0
                            ? '0%'
                            : '${((entry.value / total) * 100).round()}%',
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodTableHeader extends StatelessWidget {
  const _MoodTableHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF4A6572),
          fontSize: 12,
        ),
        textAlign: text == 'Humor' ? TextAlign.left : TextAlign.right,
      ),
    );
  }
}

class _MoodTableCell extends StatelessWidget {
  const _MoodTableCell(this.text, {this.alignRight = true});

  final String text;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF4A6572),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}
