import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/usuario.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/tarefas_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Recupera o tema salvo antes de desenhar a primeira tela.
  themeNotifier.value = await PreferencesService().carregarTema();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Minhas Tarefas',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modo,
          home: const AuthGate(),
          routes: {
            '/home': (_) => const HomeScreen(),
            '/tarefas': (_) => const TarefasScreen(),
            '/configuracoes': (_) => const ConfiguracoesScreen(),
            '/sobre': (_) => const SobreScreen(),
          },
        );
      },
    );
  }
}

/// Decide entre login e home. O Firebase restaura a sessão sozinho.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usuario?>(
      stream: AuthService().usuarioStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.hasData ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
