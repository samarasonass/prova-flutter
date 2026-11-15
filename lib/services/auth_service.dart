import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/usuario.dart';

class AuthException implements Exception {
  final String mensagem;
  AuthException(this.mensagem);
  @override
  String toString() => mensagem;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Usuario? _converter(User? u) => u == null
      ? null
      : Usuario(
          uid: u.uid,
          nome: (u.displayName == null || u.displayName!.isEmpty)
              ? 'Usuário'
              : u.displayName!,
          email: u.email ?? '',
        );

  Usuario? get usuarioAtual => _converter(_auth.currentUser);

  /// Emite também quando o perfil (nome) é atualizado.
  Stream<Usuario?> usuarioStream() => _auth.userChanges().map(_converter);

  Future<void> cadastrar(String nome, String email, String senha) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: senha);
      await cred.user!.updateDisplayName(nome.trim());
      await cred.user!.reload();
      final u = Usuario(uid: cred.user!.uid, nome: nome.trim(), email: email.trim());
      await FirebaseDatabase.instance.ref('usuarios/${u.uid}').set(u.toMap());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e.code));
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e.code));
    }
  }

  Future<void> logout() => _auth.signOut();

  String _traduzir(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação ($code).';
    }
  }
}
