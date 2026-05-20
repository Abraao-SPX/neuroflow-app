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
        final shouldStretch = isCompact &&
            constraints.maxHeight > 520 &&
            width >= 320 &&
            width < 760;

        if (shouldStretch) {
          const columns = 6;
          final rows = <List<String>>[
            characters.sublist(0, 6),
            characters.sublist(6, 12),
            characters.sublist(12, 18),
            characters.sublist(18, 24),
            characters.sublist(24, 30),
            characters.sublist(30, 36),
            ['ESPAÇO'],
          ];
          final rowSpacing = spacing;
          final availableHeight =
              constraints.maxHeight - rowSpacing * (rows.length - 1);
          final spaceRowHeight = (availableHeight * 0.62 / rows.length)
              .clamp(48.0, 76.0)
              .toDouble();
          final keyHeight =
              (availableHeight - spaceRowHeight) / (rows.length - 1);

          return Column(
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                SizedBox(
                  height: rowIndex == rows.length - 1
                      ? spaceRowHeight
                      : keyHeight,
                  child: Row(
                    children: [
                      for (var index = 0; index < rows[rowIndex].length; index++)
                        Expanded(
                          flex: rows[rowIndex][index] == 'ESPAÇO' ? columns : 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == rows[rowIndex].length - 1
                                  ? 0
                                  : spacing,
                            ),
                            child: _KeyboardKey(
                              char: rows[rowIndex][index],
                              isCompact: false,
                              onPressed: onCharacterPressed,
                              color: _getKeyColor(
                                rows[rowIndex][index],
                                rows[rowIndex][index] == 'ESPAÇO',
                              ),
                              isNumber: _isNumber(rows[rowIndex][index]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (rowIndex != rows.length - 1) SizedBox(height: rowSpacing),
              ],
            ],
          );
        }

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

            return _KeyboardKey(
              char: char,
              isCompact: compactByHeight,
              onPressed: onCharacterPressed,
              color: _getKeyColor(char, isSpace),
              isNumber: _isNumber(char),
            );
          },
        );
      },
    );
  }
}

class _KeyboardKey extends StatelessWidget {
  final String char;
  final bool isCompact;
  final Function(String) onPressed;
  final Color color;
  final bool isNumber;

  const _KeyboardKey({
    required this.char,
    required this.isCompact,
    required this.onPressed,
    required this.color,
    required this.isNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isSpace = char == 'ESPAÇO';

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
      elevation: isCompact ? 1.5 : 2,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        onTap: () => onPressed(isSpace ? ' ' : char),
        child: Semantics(
          label: isSpace
              ? 'Tecla de Espaço'
              : isNumber
              ? 'Número $char'
              : 'Letra $char',
          button: true,
          child: Center(
            child: Text(
              isSpace ? 'Espaço' : char,
              style: TextStyle(
                fontSize: isCompact
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
  }
}
