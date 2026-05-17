import 'dart:async';

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

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..initAuth(),
      child: _SessionLifecycleGuard(
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'NeuroFlow',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
            ),
            useMaterial3: true,
          ),
          home: const OnboardingScreen(),
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
      ),
    );
  }
}

class _SessionLifecycleGuard extends StatefulWidget {
  const _SessionLifecycleGuard({required this.child});

  final Widget child;

  @override
  State<_SessionLifecycleGuard> createState() => _SessionLifecycleGuardState();
}

class _SessionLifecycleGuardState extends State<_SessionLifecycleGuard>
    with WidgetsBindingObserver {
  bool _sessionClosedByExit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        _sessionClosedByExit = true;
        unawaited(authProvider.logout());
      }
      return;
    }

    if (state == AppLifecycleState.resumed && _sessionClosedByExit) {
      _sessionClosedByExit = false;
      rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
