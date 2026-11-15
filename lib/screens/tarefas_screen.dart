import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../themes/app_theme.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';

class TarefasScreen extends StatelessWidget {
  const TarefasScreen({super.key});

  Future<bool> _confirmarExclusao(BuildContext context, Tarefa t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${t.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    return ok ?? false;
  }

  void _detalhes(BuildContext context, String uid, Tarefa t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(t.descricao.isEmpty ? 'Sem descrição.' : t.descricao),
            const SizedBox(height: 16),
            Text('Vencimento: ${t.dataFormatada}'),
            Text('Prioridade: ${t.prioridade}'),
            Text('Situação: ${t.situacao}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Excluir'),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    if (await _confirmarExclusao(context, t)) {
                      await FirebaseService().excluir(uid, t.id);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CadastroTarefaScreen(tarefa: t)));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioAtual;
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas tarefas')),
      drawer: const DrawerMenu(rotaAtual: '/tarefas'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CadastroTarefaScreen())),
        child: const Icon(Icons.add),
      ),
      body: usuario == null
          ? const SizedBox()
          : StreamBuilder<List<Tarefa>>(
              stream: FirebaseService().tarefasStream(usuario.uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Erro: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tarefas = snap.data!;
                if (tarefas.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa cadastrada.'));
                }
                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, i) {
                    final t = tarefas[i];
                    final cor = AppTheme.corPrioridade(t.prioridade);
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmarExclusao(context, t),
                      onDismissed: (_) =>
                          FirebaseService().excluir(usuario.uid, t.id),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cor.withValues(alpha: 0.2),
                          child: Icon(AppTheme.iconePrioridade(t.prioridade),
                              color: cor),
                        ),
                        title: Text(
                          t.titulo,
                          style: TextStyle(
                              decoration: t.concluida
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        subtitle: Text(
                            '${t.dataFormatada} • ${t.prioridade} • ${t.situacao}'),
                        trailing: Checkbox(
                          value: t.concluida,
                          onChanged: (_) => FirebaseService()
                              .alternarSituacao(usuario.uid, t),
                        ),
                        onTap: () => _detalhes(context, usuario.uid, t),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
