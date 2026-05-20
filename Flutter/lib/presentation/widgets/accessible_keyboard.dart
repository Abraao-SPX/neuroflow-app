import 'package:flutter/material.dart';

class AccessibleKeyboard extends StatelessWidget {
  final Function(String) onCharacterPressed;

  const AccessibleKeyboard({super.key, required this.onCharacterPressed});

  bool _isVowel(String char) {
    return ['A', 'E', 'I', 'O', 'U'].contains(char);
  }

  bool _isNumber(String char) {
    return RegExp(r'[0-9]').hasMatch(char);
  }

  Color _getKeyColor(String char, bool isSpace) {
    if (isSpace) return Colors.deepPurple.shade100; // Espaço
    if (_isNumber(char)) return Colors.green.shade100; // Números
    if (_isVowel(char)) return Colors.blue.shade100; // Vogais
    return Colors.white; // Consoantes
  }

  @override
  Widget build(BuildContext context) {
    final List<String> characters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'ESPAÇO',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          itemCount: characters.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final char = characters[index];
            final isSpace = char == 'ESPAÇO';

            return Material(
              color: _getKeyColor(char, isSpace),
              borderRadius: BorderRadius.circular(16),
              elevation: 3,
              shadowColor: Colors.black26,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onCharacterPressed(isSpace ? ' ' : char),
                // Semântica melhorada com agrupamentos lógicos
                child: Semantics(
                  label: isSpace
                      ? 'Tecla de Espaço'
                      : _isNumber(char)
                      ? 'Número $char'
                      : 'Letra $char',
                  button: true,
                  child: Center(
                    child: Text(
                      isSpace ? 'Espaço' : char,
                      style: TextStyle(
                        fontSize: isSpace ? 20 : 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
