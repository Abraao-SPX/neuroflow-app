import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/password_reset_session.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _tokenSent = false;
  final Color primaryColor = const Color(0xFF4F46E5);

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
      _tokenSent = true;
      if (pendingReset.token != null && pendingReset.token!.isNotEmpty) {
        _tokenController.text = pendingReset.token!;
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
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRequestToken() async {
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
          _tokenSent = true;
          // Automagicamente preenchemos o token para MVP
          if (result['token'] != null) {
            _tokenController.text = result['token'];

            // Exibir Modal de Simulação de Email para o Avaliador
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('📧 Caixa de Entrada (Simulação)'),
                content: Text(
                  'Este é um ambiente MVP. Na vida real o usuário receberia um email.\n\n'
                  'Token gerado:\n${result['token']}\n\n'
                  'O campo já foi preenchido automaticamente para você testar a troca.',
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
          SnackBar(content: Text(result['message'] ?? 'Instruções enviadas!')),
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
    if (_tokenController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha o token e a nova senha.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.resetPassword(
        _tokenController.text,
        _passwordController.text,
      );

      if (mounted) {
        await _clearPendingReset();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Senha atualizada!')),
        );
        Navigator.pop(context); // Voltar para login
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recuperar Senha",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _tokenSent
                  ? "Insira o token e sua nova senha"
                  : "Insira seu e-mail para receber as instruções",
            ),
            const SizedBox(height: 40),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 20),

            if (!_tokenSent) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleRequestToken,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar Instruções',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ] else ...[
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'Token de Recuperação',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleResetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Salvar Nova Senha',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
