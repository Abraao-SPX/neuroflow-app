import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/password_reset_session.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _codeSent = false;
  bool _obscurePassword = true;
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color backgroundColor = const Color.fromARGB(255, 184, 212, 218);
  final Color textColor = const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _restorePendingReset();
  }

  Future<void> _restorePendingReset() async {
    final pendingReset = await PasswordResetSession.restore();
    if (!mounted || pendingReset == null) return;

    setState(() {
      _emailController.text = pendingReset.email;
      _codeSent = true;
      if (pendingReset.token != null && pendingReset.token!.isNotEmpty) {
        _codeController.text = pendingReset.token!;
      }
    });
  }

  Future<void> _savePendingReset(Map<String, dynamic> result) async {
    final token = result['token'];
    await PasswordResetSession.save(
      email: _emailController.text,
      token: token is String ? token : null,
    );
  }

  Future<void> _clearPendingReset() async {
    await PasswordResetSession.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRequestCode() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira seu e-mail.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.forgotPassword(_emailController.text);
      if (mounted) {
        await _savePendingReset(result);
        if (!mounted) return;
        setState(() {
          _codeSent = true;
          if (result['token'] != null) {
            _codeController.text = result['token'];

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Caixa de Entrada'),
                content: Text(
                  'Este e um ambiente MVP. Na vida real o usuario receberia um email.\n\n'
                  'Codigo gerado:\n${result['token']}\n\n'
                  'O campo ja foi preenchido automaticamente para voce testar a troca.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK, continuar'),
                  ),
                ],
              ),
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Instrucoes enviadas!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleResetPassword() async {
    if (_codeController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha o codigo e a nova senha.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.resetPassword(
        _codeController.text,
        _passwordController.text,
      );

      if (mounted) {
        await _clearPendingReset();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Senha atualizada!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleUseAnotherEmail() async {
    await _clearPendingReset();
    if (!mounted) return;

    setState(() {
      _codeSent = false;
      _codeController.clear();
      _passwordController.clear();
      _errorMessage = null;
    });
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? counterText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF516069)),
      suffixIcon: suffixIcon,
      counterText: counterText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 42,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF24404A).withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _codeSent
                                    ? Icons.lock_reset_outlined
                                    : Icons.mark_email_unread_outlined,
                                color: primaryColor,
                                size: 38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _codeSent ? 'Criar nova senha' : 'Recuperar senha',
                            style: TextStyle(
                              fontSize: 29,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _codeSent
                                ? 'Informe o codigo recebido e escolha uma nova senha.'
                                : 'Informe seu e-mail para receber as instrucoes de recuperacao.',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.68),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 26),
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE1E6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFB7C4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFDC2626),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (!_codeSent) ...[
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_isLoading) _handleRequestCode();
                              },
                              decoration: _fieldDecoration(
                                label: 'E-mail',
                                icon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryColor
                                      .withValues(alpha: 0.45),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _handleRequestCode,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.4,
                                        ),
                                      )
                                    : const Text(
                                        'Enviar codigo',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ] else ...[
                            TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: _fieldDecoration(
                                label: 'Codigo de recuperacao',
                                icon: Icons.key_outlined,
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_isLoading) _handleResetPassword();
                              },
                              decoration: _fieldDecoration(
                                label: 'Nova senha',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF516069),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryColor
                                      .withValues(alpha: 0.45),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _handleResetPassword,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.4,
                                        ),
                                      )
                                    : const Text(
                                        'Salvar nova senha',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleUseAnotherEmail,
                                child: Text(
                                  'Usar outro e-mail',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        'Voltar ao login',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w600,
                        ),
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
