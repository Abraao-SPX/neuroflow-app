import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Olá, Bem-vindo!"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Como você está hoje?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // CARD DO QUIZ / DIAGNÓSTICO DIÁRIO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check-in de Bem-estar",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Responda 5 perguntas rápidas para entender seu nível de estresse agora.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Aqui levaria para a tela do Quiz
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                    ),
                    child: const Text("Começar Quiz"),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text(
              "Suas Atividades",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            // LISTA DE EXEMPLO (CRUD NO FUTURO)
            Expanded(
              child: ListView(
                children: [
                  _buildActivityItem(Icons.wb_sunny_outlined, "Rotina Matinal", "08:00"),
                  _buildActivityItem(Icons.mediation, "Pausa para Respiração", "14:30"),
                  _buildActivityItem(Icons.nightlight_round, "Higiene do Sono", "21:00"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar os itens da lista
  Widget _buildActivityItem(IconData icon, String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4F46E5)),
        title: Text(title),
        trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}