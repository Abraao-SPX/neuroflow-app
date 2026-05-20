import 'package:flutter/material.dart';

class AccessibleKeyboard extends StatelessWidget {
  final Function(String) onCharacterPressed;
  final bool isCompact;

  const AccessibleKeyboard({
    super.key,
    required this.onCharacterPressed,
    this.isCompact = false,
  });

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
        final compactByHeight = isCompact || constraints.maxHeight < 280;
        final width = constraints.maxWidth;
        final crossAxisCount = compactByHeight
            ? width < 520
                ? 6
                : width < 760
                    ? 8
                    : 10
            : null;
        final maxCrossAxisExtent = compactByHeight ? null : 98.0;
        final childAspectRatio = compactByHeight ? 1.95 : 1.18;
        final spacing = compactByHeight ? 6.0 : 8.0;

        return GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: characters.length,
          physics: compactByHeight
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          gridDelegate: crossAxisCount != null
              ? SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                )
              : SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent!,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
          itemBuilder: (context, index) {
            final char = characters[index];
            final isSpace = char == 'ESPAÇO';

            return Material(
              color: _getKeyColor(char, isSpace),
              borderRadius: BorderRadius.circular(compactByHeight ? 12 : 16),
              elevation: compactByHeight ? 1.5 : 2,
              shadowColor: Colors.black26,
              child: InkWell(
                borderRadius: BorderRadius.circular(compactByHeight ? 12 : 16),
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
                        fontSize: compactByHeight
                            ? (isSpace ? 13 : 22)
                            : (isSpace ? 20 : 32),
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
