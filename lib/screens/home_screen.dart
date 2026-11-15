import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _contador(BuildContext c, String rotulo, int valor, IconData icone,
      Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 32),
              const SizedBox(height: 8),
              Text('$valor', style: Theme.of(c).textTheme.headlineMedium),
              Text(rotulo),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioAtual;
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      drawer: const DrawerMenu(rotaAtual: '/home'),
      body: usuario == null
          ? const SizedBox()
          : StreamBuilder<List<Tarefa>>(
              stream: FirebaseService().tarefasStream(usuario.uid),
              builder: (context, snap) {
                final tarefas = snap.data ?? [];
                final concluidas = tarefas.where((t) => t.concluida).length;
                final pendentes = tarefas.length - concluidas;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Olá, ${usuario.nome}!',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(usuario.email),
                    const SizedBox(height: 24),
                    if (snap.hasError)
                      Text('Erro ao carregar tarefas: ${snap.error}')
                    else
                      Row(children: [
                        _contador(context, 'Total', tarefas.length, Icons.list_alt,
                            Colors.indigo),
                        _contador(context, 'Pendentes', pendentes,
                            Icons.pending_actions, Colors.orange),
                        _contador(context, 'Concluídas', concluidas,
                            Icons.check_circle, Colors.green),
                      ]),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.checklist),
                      label: const Text('Ver minhas tarefas'),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/tarefas'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Nova tarefa'),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CadastroTarefaScreen())),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
