import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';

class DrawerMenu extends StatelessWidget {
  final String rotaAtual;
  const DrawerMenu({super.key, required this.rotaAtual});

  void _ir(BuildContext context, String rota) {
    Navigator.pop(context); // fecha o drawer
    if (rota != rotaAtual) Navigator.pushReplacementNamed(context, rota);
  }

  Future<void> _sair(BuildContext context) async {
    Navigator.pop(context);
    await AuthService().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  Widget _item(BuildContext c, IconData icone, String texto, String rota) =>
      ListTile(
        leading: Icon(icone),
        title: Text(texto),
        selected: rotaAtual == rota,
        onTap: () => _ir(c, rota),
      );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<Usuario?>(
        stream: AuthService().usuarioStream(),
        builder: (context, snap) {
          final u = snap.data ?? AuthService().usuarioAtual;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(u?.nome ?? ''),
                accountEmail: Text(u?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  child: Text(
                    (u?.nome.isNotEmpty ?? false) ? u!.nome[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              _item(context, Icons.home, 'Início', '/home'),
              _item(context, Icons.checklist, 'Minhas tarefas', '/tarefas'),
              _item(context, Icons.settings, 'Configurações', '/configuracoes'),
              _item(context, Icons.info_outline, 'Sobre o aplicativo', '/sobre'),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () => _sair(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
