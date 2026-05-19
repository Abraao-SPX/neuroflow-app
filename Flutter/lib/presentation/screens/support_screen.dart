import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgHeader = Color(0xFFD1E3E7); // Azul claro do topo
    const Color bgBody = Color(0xFFFDF9F0); // Bege claro do fundo
    const Color primaryBlue = Color(0xFF0052CC); // Azul dos ícones e botão

    return Scaffold(
      backgroundColor: bgBody,
      endDrawer: const CustomDrawer(),
      body: Column(
        children: [
          // CABEÇALHO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: bgHeader,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Apoio e Conexão',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Color(0xFF003366),
                          size: 30,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD PRINCIPAL CVV
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: primaryBlue,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'CVV',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Centro de Valorização da Vida',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SEÇÃO "COMO FALAR COM ELES"
                  const Text(
                    'Como falar com eles:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  _buildContactItem(
                    Icons.phone_in_talk,
                    'Ligue 188 - Ligação gratuita',
                    primaryBlue,
                  ),
                  _buildContactItem(
                    Icons.back_hand,
                    'Linha de Escuta (0800...) - Horário Comercial',
                    primaryBlue,
                  ),
                  _buildContactItem(
                    Icons.language,
                    'Acesse cvv.org.br',
                    primaryBlue,
                  ),

                  const SizedBox(height: 40),

                  // BOTÃO LIGAR AGORA
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica para abrir o discador do celular
                    },
                    icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                    label: const Text(
                      'Ligar agora (188)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os itens de contato
  Widget _buildContactItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
