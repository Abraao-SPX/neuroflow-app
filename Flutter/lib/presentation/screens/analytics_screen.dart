import 'package:flutter/material.dart';
import '../../data/services/checkin_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar histórico: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBody = Color(0xFFFDF9F0);

    return Scaffold(
      backgroundColor: bgBody,
      appBar: AppBar(
        title: const Text('Histórico de Dias'),
        backgroundColor: const Color(0xFFD1E3E7),
        foregroundColor: const Color(0xFF4A6572),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checkins.isEmpty
          ? const Center(child: Text('Nenhum check-in registrado ainda.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _checkins.length,
              itemBuilder: (context, index) {
                final item = _checkins[index];
                final date =
                    item['data_checkin'] ??
                    item['createdAt']?.substring(0, 10) ??
                    '';
                final humor = item['humor'];
                final List gatilhos = item['gatilhos'] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data: $date',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Humor: $humor',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (gatilhos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Gatilhos enfrentados:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          ...gatilhos.map((g) => Text('• $g')),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
