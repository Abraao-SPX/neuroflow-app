import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/alphabet_board_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..initAuth(),
      child: MaterialApp(
        title: 'NeuroFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (!authProvider.isLoggedIn) {
              return const OnboardingScreen();
            }

            if (authProvider.user?['role'] == 'admin') {
              return const AdminDashboardScreen();
            }

            return const HomeScreen();
          },
        ),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/alphabet': (context) => const AlphabetBoardScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/admin_dashboard': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}
