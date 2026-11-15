import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../themes/app_theme.dart';
import '../widgets/drawer_menu.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const DrawerMenu(rotaAtual: '/configuracoes'),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, modo, _) => ListView(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Tema escuro'),
              subtitle: Text(modo == ThemeMode.dark ? 'Ativado' : 'Desativado'),
              value: modo == ThemeMode.dark,
              onChanged: (escuro) async {
                final novo = escuro ? ThemeMode.dark : ThemeMode.light;
                themeNotifier.value = novo;
                await PreferencesService().salvarTema(novo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
