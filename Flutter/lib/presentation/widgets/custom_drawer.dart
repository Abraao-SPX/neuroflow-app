import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      backgroundColor: const Color(0xFFFDF9F0),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6572),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF4A6572)),
              title: const Text(
                'Perfil',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF4A6572)),
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Color(0xFF4A6572),
              ),
              title: const Text(
                'Resumo Semanal',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/weekly');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.mood,
                color: Color(0xFF4A6572),
              ),
              title: const Text(
                'Humores',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/moods');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.task_alt,
                color: Color(0xFF4A6572),
              ),
              title: const Text(
                'Meu Plano',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/plan');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.support_agent,
                color: Color(0xFF4A6572),
              ),
              title: const Text(
                'Support',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/support');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.accessibility_new,
                color: Color(0xFF4A6572),
              ),
              title: const Text(
                'Acessibilidade',
                style: TextStyle(
                  color: Color(0xFF4A6572),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/alphabet-board');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final navigator = Navigator.of(context);
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
