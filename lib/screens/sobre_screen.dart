import 'package:flutter/material.dart';

import '../widgets/drawer_menu.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o aplicativo')),
      drawer: const DrawerMenu(rotaAtual: '/sobre'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.task_alt,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Minhas Tarefas',
                style: Theme.of(context).textTheme.headlineSmall),
            const Text('Versão 1.0.0'),
            const SizedBox(height: 16),
            const Text(
                'Aplicativo de gerenciamento de tarefas pessoais desenvolvido '
                'com Flutter, Firebase Authentication e Firebase Realtime '
                'Database para a disciplina de Programação Mobile (P2).'),
          ],
        ),
      ),
    );
  }
}
