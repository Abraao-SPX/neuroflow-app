import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoadingParent = false;
  bool _isSendingCode = false;
  bool _isConfirming = false;
  bool _obscurePassword = true;
  Map<String, dynamic>? _parentStatus;

  static const Color _primaryColor = Color(0xFF1A434E);
  static const Color _accentColor = Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    _loadParentStatus();
  }

  @override
  void dispose() {
    _parentEmailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadParentStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isParent) return;

    setState(() => _isLoadingParent = true);
    try {
      final status = await AuthService.getParentAccessStatus();
      if (!mounted) return;
      setState(() {
        _parentStatus = status;
        final email = status['parentEmail']?.toString() ?? '';
        if (email.isNotEmpty) {
          _parentEmailController.text = email;
        }
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoadingParent = false);
    }
  }

  Future<void> _sendCode() async {
    final email = _parentEmailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Informe o e-mail do responsavel.');
      return;
    }

    setState(() => _isSendingCode = true);
    try {
      await AuthService.requestParentAccessCode(email);
      if (!mounted) return;
      _showMessage('Codigo enviado para o e-mail do responsavel.');
      await _loadParentStatus();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _confirmParent() async {
    final email = _parentEmailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || code.isEmpty || password.isEmpty) {
      _showMessage('Preencha e-mail, codigo e senha.');
      return;
    }

    if (password != _confirmPasswordController.text) {
      _showMessage('As senhas nao conferem.');
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final result = await AuthService.confirmParentAccess(
        email: email,
        code: code,
        password: password,
      );
      if (!mounted) return;
      _showMessage(result['message'] ?? 'Responsavel verificado.');
      _codeController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      await _loadParentStatus();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final child = authProvider.child;
    final isParent = authProvider.isParent;

    final String userName =
        user?['username'] ?? user?['name'] ?? 'Carregando...';
    final String userEmail = user?['email'] ?? 'Carregando...';
    final String childName =
        child?['username'] ?? child?['name'] ?? 'Filho vinculado';
    final String childEmail = child?['email'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F0),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/perfil.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(color: Color(0xFFFDF9F0));
              },
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.white.withValues(alpha: 0.18)),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.eco,
                size: 250,
                color: Colors.green.withValues(alpha: 0.2),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: _primaryColor,
                          size: 30,
                        ),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const Text(
                          'Perfil',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        Text(
                          isParent
                              ? 'Acesso de responsavel'
                              : 'Gerencie suas informacoes',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildAccountCard(
                          title: isParent ? 'Sua conta' : 'Sua conta',
                          description: isParent
                              ? 'Voce esta usando um acesso verificado de responsavel.'
                              : 'Esta e sua conta. Suas informacoes sao pessoais e intransferiveis.',
                          fields: [
                            _ProfileFieldData(
                              'Nome / Usuario',
                              userName,
                              Icons.person_outline,
                            ),
                            _ProfileFieldData(
                              'E-mail',
                              userEmail,
                              Icons.mail_outline,
                            ),
                          ],
                        ),
                        if (isParent) ...[
                          const SizedBox(height: 18),
                          _buildAccountCard(
                            title: 'Filho vinculado',
                            description:
                                'As tabelas e registros exibidos no app pertencem a este usuario.',
                            icon: Icons.family_restroom,
                            fields: [
                              _ProfileFieldData(
                                'Nome / Usuario',
                                childName,
                                Icons.person_outline,
                              ),
                              if (childEmail.isNotEmpty)
                                _ProfileFieldData(
                                  'E-mail',
                                  childEmail,
                                  Icons.mail_outline,
                                ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 18),
                          _buildParentAccessCard(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required String title,
    required String description,
    required List<_ProfileFieldData> fields,
    IconData icon = Icons.psychology,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFEAEBFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 54, color: const Color(0xFF4F46E5)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, fontSize: 14),
          ),
          const SizedBox(height: 24),
          for (final field in fields)
            _buildProfileField(
              field.label,
              field.value,
              field.icon,
              _accentColor,
            ),
        ],
      ),
    );
  }

  Widget _buildParentAccessCard() {
    final verified = _parentStatus?['verified'] == true;
    final statusEmail = _parentStatus?['parentEmail']?.toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E3E7).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.verified_user, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Acesso dos pais',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verified
                ? 'Responsavel verificado. Ele ja pode entrar com o proprio e-mail e senha.'
                : 'Informe o e-mail do responsavel. Ele recebera um codigo para criar senha e acompanhar seus dados.',
            style: const TextStyle(color: Colors.black54, height: 1.35),
          ),
          if (statusEmail != null && statusEmail.isNotEmpty) ...[
            const SizedBox(height: 10),
            Chip(
              avatar: Icon(
                verified ? Icons.check_circle : Icons.schedule,
                size: 18,
                color: verified ? Colors.green : Colors.orange,
              ),
              label: Text(
                verified
                    ? 'Verificado: $statusEmail'
                    : 'Pendente: $statusEmail',
              ),
              backgroundColor: const Color(0xFFF8FAFC),
            ),
          ],
          const SizedBox(height: 18),
          if (_isLoadingParent)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildTextInput(
              controller: _parentEmailController,
              label: 'E-mail do responsavel',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              enabled: !verified,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: verified || _isSendingCode ? null : _sendCode,
                icon: _isSendingCode
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_isSendingCode ? 'Enviando...' : 'Enviar codigo'),
              ),
            ),
            if (!verified) ...[
              const SizedBox(height: 18),
              _buildTextInput(
                controller: _codeController,
                label: 'Codigo recebido',
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextInput(
                controller: _passwordController,
                label: 'Senha do responsavel',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextInput(
                controller: _confirmPasswordController,
                label: 'Confirmar senha',
                icon: Icons.lock_reset_outlined,
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isConfirming ? null : _confirmParent,
                  icon: _isConfirming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(
                    _isConfirming ? 'Confirmando...' : 'Validar e criar senha',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFE5E7EB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldData {
  const _ProfileFieldData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
