import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/offres_provider.dart';
import 'providers/candidatures_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/candidat/home_screen.dart';
import 'screens/candidat/my_candidatures_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OffresProvider()),
        ChangeNotifierProvider(create: (_) => CandidaturesProvider()),
      ],
      child: MaterialApp(
        title: 'Université - Portail Étudiant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/candidatures': (context) => const MyCandidaturesScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    Future.microtask(() {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Navigate based on user role
        final user = authProvider.currentUser!;
        if (user.isCandidat) {
          return const CandidatHomeScreen();
        } else if (user.isAdmin) {
          return const AdminHomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
