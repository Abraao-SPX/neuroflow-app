import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1A434E); // Azul escuro dos textos
    const Color accentColor = Color(0xFF64B5F6); // Azul claro dos ícones

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F0), // Bege de fundo
      drawer:
          const CustomDrawer(), // Menu lateral que será aberto pelos 3 tracinhos
      body: Stack(
        children: [
          // Decoração de fundo (estilo aquarela/folhas)
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.eco,
                size: 250,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Barra de Topo apenas com o Menu Hambúrguer
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: primaryColor,
                          size: 30,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
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
                            color: primaryColor,
                          ),
                        ),
                        const Text(
                          'Gerencie suas informações',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        const SizedBox(height: 30),

                        // Card Branco Central
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Nuvenzinha (Ícone centralizado)
                              const Icon(
                                Icons.cloud_queue,
                                size: 100,
                                color: Color(0xFFB39DDB), // Roxo suave da nuvem
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Esta é sua conta. Suas informações são pessoais e intransferíveis.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Campos de Informação
                              _buildProfileField(
                                'Nome',
                                'Ana Clara',
                                Icons.person_outline,
                                accentColor,
                              ),
                              _buildProfileField(
                                'Nome de usuário',
                                'anaclara123',
                                Icons.person_outline,
                                accentColor,
                              ),
                              _buildProfileField(
                                'E-mail',
                                'anaclara@email.com',
                                Icons.mail_outline,
                                accentColor,
                              ),
                            ],
                          ),
                        ),
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

  // Função para criar as linhas de input visualmente idênticas à imagem
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
              color: Color(0xFF1A434E),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 15),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
