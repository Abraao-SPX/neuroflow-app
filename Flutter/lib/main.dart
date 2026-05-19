import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/support_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/weekly_summary_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),

      builder: (context, child) {
        return Container(
          color: const Color(0xFFE5E7EB), // Fundo suave para telas maiores
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ), // Redimensiona e limita o layout para parecer app mobile
              child: ClipRect(child: child!),
            ),
          ),
        );
      },

      home: const OnboardingScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/support': (context) => const SupportScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/weekly': (context) => const WeeklySummaryScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
