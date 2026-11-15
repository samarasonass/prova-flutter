class Usuario {
  final String uid;
  final String nome;
  final String email;

  Usuario({required this.uid, required this.nome, required this.email});

  Map<String, dynamic> toMap() => {'uid': uid, 'nome': nome, 'email': email};

  factory Usuario.fromMap(Map<dynamic, dynamic> map) => Usuario(
        uid: (map['uid'] ?? '').toString(),
        nome: (map['nome'] ?? '').toString(),
        email: (map['email'] ?? '').toString(),
      );
}
