import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';

/// CRUD de tarefas no Realtime Database.
/// Estrutura: /tarefas/{uid}/{idTarefa}  -> cada usuário só acessa seu nó.
class FirebaseService {
  DatabaseReference _ref(String uid) =>
      FirebaseDatabase.instance.ref('tarefas/$uid');

  /// Listener em tempo real (onValue).
  Stream<List<Tarefa>> tarefasStream(String uid) {
    return _ref(uid).onValue.map((event) {
      final valor = event.snapshot.value;
      if (valor == null || valor is! Map) return <Tarefa>[];
      final lista = valor.entries
          .map((e) => Tarefa.fromMap(e.key.toString(), e.value as Map))
          .toList();
      lista.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      return lista;
    });
  }

  Future<void> salvar(String uid, Tarefa tarefa) async {
    if (tarefa.id.isEmpty) {
      await _ref(uid).push().set(tarefa.toMap()); // cadastro
    } else {
      await _ref(uid).child(tarefa.id).set(tarefa.toMap()); // edição
    }
  }

  Future<void> alternarSituacao(String uid, Tarefa tarefa) =>
      _ref(uid).child(tarefa.id).update({'concluida': !tarefa.concluida});

  Future<void> excluir(String uid, String id) => _ref(uid).child(id).remove();
}
