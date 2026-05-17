import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/accessible_keyboard.dart';

class AlphabetBoardScreen extends StatefulWidget {
  const AlphabetBoardScreen({super.key});

  @override
  State<AlphabetBoardScreen> createState() => _AlphabetBoardScreenState();
}

class _AlphabetBoardScreenState extends State<AlphabetBoardScreen> {
  String _currentText = "";

  @override
  void initState() {
    super.initState();
    // Força a orientação horizontal (paisagem) conforme o requisito
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Restaura as orientações permitidas ao sair da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _onCharacterPressed(String char) {
    setState(() {
      _currentText += char;
    });
  }

  void _onBackspace() {
    if (_currentText.isNotEmpty) {
      setState(() {
        _currentText = _currentText.substring(0, _currentText.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _currentText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cores suaves para reduzir sobrecarga sensorial
    const backgroundColor = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Prancha de Comunicação'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Área do Visor
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _currentText.isEmpty
                              ? "Digite algo..."
                              : _currentText,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: _currentText.isEmpty
                                ? Colors.grey.shade400
                                : Colors.black87,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Parede divisória visual
                    Container(
                      height: 50,
                      width: 2,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 12),
                    // Botões com texto e ícone para clareza cognitiva
                    ElevatedButton.icon(
                      onPressed: _currentText.isEmpty ? null : _onBackspace,
                      icon: const Icon(Icons.backspace_rounded, size: 28),
                      label: const Text(
                        "Apagar",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _currentText.isEmpty ? null : _onClear,
                      icon: const Icon(Icons.delete_forever_rounded, size: 28),
                      label: const Text(
                        "Limpar",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Área do Teclado
              Expanded(
                child: AccessibleKeyboard(
                  onCharacterPressed: _onCharacterPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
