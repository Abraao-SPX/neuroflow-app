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
  bool _isLoading = true;

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
                    itemCount: _checkins.length,
                    itemBuilder: (context, index) {
                      final item = _checkins[index];
                      final formattedDate = _formatDateTime(
                        item['data_checkin'],
                        item['createdAt'],
                      );
                      final humor = item['humor'];
                      final gatilhos = _uniqueStrings(item['gatilhos']);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: textColor.withValues(alpha: 0.2)),
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
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: textColor,
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
                              if (gatilhos.isNotEmpty) ...[
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
