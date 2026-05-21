import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/support_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/mood_history_screen.dart';
import 'presentation/screens/regulation_plan_screen.dart';
import 'presentation/screens/weekly_summary_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/alphabet_board_screen.dart';
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

      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
              ),
            );
          }
          if (authProvider.isLoggedIn) {
            if (authProvider.user?['role'] == 'admin') {
              return const AdminDashboardScreen();
            }
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
        '/support': (context) => const SupportScreen(),
        '/home': (context) => const HomeScreen(),
        '/moods': (context) => const MoodHistoryScreen(),
        '/plan': (context) => const RegulationPlanScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/weekly': (context) => const WeeklySummaryScreen(),
        '/alphabet-board': (context) => const AlphabetBoardScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
