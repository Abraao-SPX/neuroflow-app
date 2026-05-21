import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../data/services/checkin_service.dart';
import '../widgets/custom_drawer.dart';

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  List<dynamic> _checkins = [];
  final Set<int> _deletingCheckinIds = {};
  bool _isLoading = true;

  static const List<Color> _chartColors = [
    Color(0xFFE7BE8C),
    Color(0xFF9EB6C8),
    Color(0xFF9B87C9),
    Color(0xFFB4D9A7),
    Color(0xFFE49A8F),
    Color(0xFF87C9C1),
  ];

  @override
  void initState() {
    super.initState();
    _loadCheckins();
  }

  Future<void> _loadCheckins() async {
    try {
      final data = await CheckinService.listarCheckins();
      // Podemos filtrar aqui só para a última semana, ou exibir todos de forma amigável
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
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar resumo: $e')));
    }
  }

  int? _readCheckinId(dynamic item) {
    if (item is! Map) return null;

    final id = item['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);

    return null;
  }

  Future<void> _deleteCheckin(dynamic item) async {
    final checkinId = _readCheckinId(item);
    if (checkinId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o registro.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apagar registro?'),
          content: const Text('Esse check-in será removido do resumo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingCheckinIds.add(checkinId);
    });

    try {
      await CheckinService.apagarCheckin(checkinId);

      if (!mounted) return;
      setState(() {
        _checkins.removeWhere(
          (checkin) => _readCheckinId(checkin) == checkinId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro apagado com sucesso.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao apagar registro: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingCheckinIds.remove(checkinId);
        });
      }
    }
  }

  List<String> _uniqueStrings(dynamic value) {
    if (value is! List) return [];

    final seen = <String>{};
    final result = <String>[];
    for (final item in value) {
      final text = item.toString().trim();
      if (text.isEmpty || seen.contains(text)) continue;
      seen.add(text);
      result.add(text);
    }

    return result;
  }

  String _readOtherDiscomfort(dynamic item) {
    if (item is! Map) return '';
    final value = item['outroIncomodo'] ?? item['outro_incomodo'];
    return value?.toString().trim() ?? '';
  }

  List<_TriggerSlice> _buildTriggerSlices() {
    final counts = <String, int>{};

    for (final checkin in _checkins) {
      if (checkin is! Map) continue;

      for (final trigger in _uniqueStrings(checkin['gatilhos'])) {
        counts[trigger] = (counts[trigger] ?? 0) + 1;
      }

      if (_readOtherDiscomfort(checkin).isNotEmpty) {
        counts['Outros'] = (counts['Outros'] ?? 0) + 1;
      }
    }

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });

    return [
      for (var i = 0; i < entries.length; i++)
        _TriggerSlice(
          label: entries[i].key,
          value: entries[i].value,
          color: _chartColors[i % _chartColors.length],
        ),
    ];
  }

  String _formatDateTime(String? dateStr, String? createdAt) {
    if (createdAt == null) return dateStr ?? '';
    try {
      final date = DateTime.parse(createdAt).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year às $hour:$minute';
    } catch (_) {
      return dateStr ?? createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgHeader = Color(0xFFD1E3E7);
    const Color bgBody = Color(0xFFFDF9F0);
    const Color textColor = Color(0xFF4A6572);

    return Scaffold(
      backgroundColor: bgBody,
      endDrawer: const CustomDrawer(),
      body: Column(
        children: [
          // CABEÇALHO PADRÃO
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
                  'Resumo da Semana',
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
                ? const Center(child: Text('Nenhum dado registrado na semana.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _checkins.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _WeeklyTriggersChart(
                          slices: _buildTriggerSlices(),
                          textColor: textColor,
                        );
                      }

                      final item = _checkins[index - 1];
                      final formattedDate = _formatDateTime(
                        item['data_checkin'],
                        item['createdAt'],
                      );
                      final humor = item['humor'];
                      final gatilhos = _uniqueStrings(item['gatilhos']);
                      final outroIncomodo = _readOtherDiscomfort(item);
                      final checkinId = _readCheckinId(item);
                      final isDeleting =
                          checkinId != null &&
                          _deletingCheckinIds.contains(checkinId);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: textColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: isDeleting
                                        ? const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : IconButton(
                                            tooltip: 'Apagar registro',
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () =>
                                                _deleteCheckin(item),
                                          ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                'Como estava se sentindo: $humor',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (gatilhos.isNotEmpty ||
                                  outroIncomodo.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Text(
                                  'O que estava incomodando:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...gatilhos.map(
                                  (g) => Text(
                                    '• $g',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                if (outroIncomodo.isNotEmpty) ...[
                                  const Text(
                                    'Outros',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF3E8),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      outroIncomodo,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TriggerSlice {
  const _TriggerSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class _WeeklyTriggersChart extends StatelessWidget {
  const _WeeklyTriggersChart({required this.slices, required this.textColor});

  final List<_TriggerSlice> slices;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.value);

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
                const Icon(Icons.pie_chart_outline, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O que mais incomodou',
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
              'Resumo dos gatilhos registrados nesta semana',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            if (slices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Nenhum incômodo registrado ainda.',
                    style: TextStyle(color: textColor.withValues(alpha: 0.75)),
                  ),
                ),
              )
            else ...[
              Center(
                child: SizedBox(
                  width: 240,
                  height: 220,
                  child: CustomPaint(painter: _PieChartPainter(slices)),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (final slice in slices)
                    _ChartLegendItem(
                      slice: slice,
                      total: total,
                      textColor: textColor,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({
    required this.slice,
    required this.total,
    required this.textColor,
  });

  final _TriggerSlice slice;
  final int total;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((slice.value / total) * 100).round();

    return SizedBox(
      width: 145,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: slice.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${slice.label} · ${slice.value}x · $percent%',
              style: TextStyle(color: textColor, fontSize: 12, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter(this.slices);

  final List<_TriggerSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2 - 4);
    final radius = math.min(size.width, size.height) * 0.38;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, radius * 0.16),
        width: radius * 1.95,
        height: radius * 1.62,
      ),
      shadowPaint,
    );

    for (final slice in slices) {
      final sweepAngle = (slice.value / total) * math.pi * 2;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      if (sweepAngle > 0.32) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelOffset = Offset(
          center.dx + math.cos(labelAngle) * radius * 0.56,
          center.dy + math.sin(labelAngle) * radius * 0.56,
        );
        _drawValue(canvas, labelOffset, slice.value.toString());
      }

      startAngle += sweepAngle;
    }

    final glossPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.02),
        ],
        stops: const [0.15, 1],
      ).createShader(rect);
    canvas.drawCircle(
      center.translate(-radius * 0.18, -radius * 0.22),
      radius,
      glossPaint,
    );
  }

  void _drawValue(Canvas canvas, Offset center, String value) {
    final shadowPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          color: Color(0x55000000),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    shadowPainter.paint(
      canvas,
      center -
          Offset(shadowPainter.width / 2 - 1, shadowPainter.height / 2 - 2),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
