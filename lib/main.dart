import 'package:flutter/material.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/editor_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega tema e sessão salvos antes de abrir o app
  await AuthViewModel().carregarPreferencias();

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthViewModel();

    return ListenableBuilder(
      listenable: auth,
      builder: (context, child) {
        return MaterialApp(
          title: 'Edit Doc',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode:
              auth.temaEscuro ? ThemeMode.dark : ThemeMode.light,
          initialRoute: auth.estaLogado ? '/home' : '/',
          routes: {
            '/': (context) => const LoginView(),
            '/cadastro': (context) => const CadastroView(),
            '/home': (context) => const HomeView(),
            '/editor': (context) => const EditorView(),
          },
        );
      },
    );
  }
}

