import 'package:flutter/material.dart';
import '../widgets/accessible_keyboard.dart';
import '../widgets/custom_drawer.dart';

class AlphabetBoardScreen extends StatefulWidget {
  const AlphabetBoardScreen({super.key});

  @override
  State<AlphabetBoardScreen> createState() => _AlphabetBoardScreenState();
}

class _AlphabetBoardScreenState extends State<AlphabetBoardScreen> {
  String _currentText = '';

  final Color primaryColor = const Color(0xFF4F46E5);
  final Color backgroundColor = const Color.fromARGB(255, 184, 212, 218);
  final Color textColor = const Color(0xFF1F2937);

  void _onCharacterPressed(String char) {
    setState(() {
      _currentText += char;
    });
  }

  void _onBackspace() {
    if (_currentText.isEmpty) return;

    setState(() {
      _currentText = _currentText.substring(0, _currentText.length - 1);
    });
  }

  void _onClear() {
    setState(() {
      _currentText = '';
    });
  }

  void _onWordPressed(String word) {
    setState(() {
      if (_currentText.isNotEmpty && !_currentText.endsWith(' ')) {
        _currentText += ' $word ';
      } else {
        _currentText += '$word ';
      }
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color color,
    required bool isCompact,
  }) {
    return SizedBox.square(
      dimension: isCompact ? 46 : 52,
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: isCompact ? 22 : 24),
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickWordButton({
    required _QuickWord item,
    required bool isCompact,
  }) {
    return FilledButton.tonalIcon(
      onPressed: () => _onWordPressed(item.word),
      icon: Icon(item.icon, size: isCompact ? 18 : 22),
      label: Text(
        item.word,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isCompact ? 14 : 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: item.color.withValues(alpha: 0.13),
        foregroundColor: item.color,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 14,
          vertical: isCompact ? 8 : 10,
        ),
        minimumSize: Size(0, isCompact ? 42 : 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
          side: BorderSide(
            color: item.color.withValues(alpha: 0.28),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildComposer({required bool isCompact, required bool isLandscape}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(isCompact ? 18 : 22),
        border: Border.all(color: primaryColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _currentText.isEmpty ? 'Digite algo...' : _currentText,
                maxLines: 1,
                style: TextStyle(
                  fontSize: isCompact
                      ? (isLandscape ? 26 : 24)
                      : (isLandscape ? 34 : 30),
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: _currentText.isEmpty
                      ? textColor.withValues(alpha: 0.35)
                      : textColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _buildActionButton(
            icon: Icons.backspace_rounded,
            tooltip: 'Apagar',
            onPressed: _currentText.isEmpty ? null : _onBackspace,
            color: const Color(0xFF4B5563),
            isCompact: isCompact,
          ),
          SizedBox(width: isCompact ? 6 : 8),
          _buildActionButton(
            icon: Icons.delete_forever_rounded,
            tooltip: 'Limpar',
            onPressed: _currentText.isEmpty ? null : _onClear,
            color: const Color(0xFFDC2626),
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickWords({required bool isCompact}) {
    return SizedBox(
      height: isCompact ? 42 : 48,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: _quickWords.length,
        separatorBuilder: (_, _) => SizedBox(width: isCompact ? 6 : 8),
        itemBuilder: (context, index) {
          return _buildQuickWordButton(
            item: _quickWords[index],
            isCompact: isCompact,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      endDrawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Prancha de Comunicação'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          tooltip: 'Voltar para a página principal',
          icon: const Icon(Icons.home_outlined),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Abrir menu',
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        left: false,
        right: false,
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isCompact =
                constraints.maxHeight < 560 || constraints.maxWidth < 1000;
            final outerPadding = isCompact ? 6.0 : 12.0;
            final cardPadding = isCompact ? 12.0 : 20.0;
            final gap = isCompact ? 8.0 : 14.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                outerPadding,
                isCompact ? 4 : 10,
                outerPadding,
                isCompact ? 6 : 16,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(isCompact ? 24 : 28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF24404A).withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (!isCompact) ...[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.record_voice_over_outlined,
                          color: primaryColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _buildComposer(
                      isCompact: isCompact,
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: gap),
                    _buildQuickWords(isCompact: isCompact),
                    SizedBox(height: gap),
                    Expanded(
                      child: AccessibleKeyboard(
                        onCharacterPressed: _onCharacterPressed,
                        isCompact: isCompact,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickWord {
  final String word;
  final IconData icon;
  final Color color;

  const _QuickWord(this.word, this.icon, this.color);
}

const List<_QuickWord> _quickWords = [
  _QuickWord('Sim', Icons.thumb_up_alt_rounded, Colors.green),
  _QuickWord('Não', Icons.thumb_down_alt_rounded, Colors.red),
  _QuickWord('Água', Icons.local_drink_rounded, Colors.blue),
  _QuickWord('Comida', Icons.restaurant_rounded, Colors.orange),
  _QuickWord('Banheiro', Icons.wc_rounded, Colors.blueGrey),
  _QuickWord('Dor', Icons.healing_rounded, Colors.deepPurple),
  _QuickWord('Por favor', Icons.favorite_rounded, Colors.pink),
  _QuickWord('Obrigado', Icons.handshake_rounded, Colors.teal),
];
