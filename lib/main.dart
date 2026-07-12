import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/opportunity_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(const ALUConnectApp());
}

class ALUConnectApp extends StatelessWidget {
  const ALUConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<FirebaseService>()),
        ),
        ChangeNotifierProvider<OpportunityProvider>(
          create: (ctx) => OpportunityProvider(ctx.read<FirebaseService>()),
        ),
        ChangeNotifierProvider<ApplicationProvider>(
          create: (ctx) => ApplicationProvider(ctx.read<FirebaseService>()),
        ),
      ],
      child: MaterialApp(
        title: 'ALU Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Watches AuthProvider and swaps between Splash / Login / RootShell.
/// This is the single place routing decisions are made based on auth state,
/// so individual screens never need to know or check "am I logged in".
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) return const SplashScreen();
    if (!auth.isLoggedIn) return const LoginScreen();
    return const RootShell();
  }
}
