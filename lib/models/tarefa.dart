class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final String prioridade; 
  final bool concluida;

  static const prioridades = ['Baixa', 'Média', 'Alta'];

  Tarefa({
    this.id = '',
    required this.titulo,
    this.descricao = '',
    required this.dataVencimento,
    this.prioridade = 'Média',
    this.concluida = false,
  });

  String get situacao => concluida ? 'Concluída' : 'Pendente';

  String get dataFormatada {
    final d = dataVencimento.day.toString().padLeft(2, '0');
    final m = dataVencimento.month.toString().padLeft(2, '0');
    return '$d/$m/${dataVencimento.year}';
  }

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataVencimento,
    String? prioridade,
    bool? concluida,
  }) =>
      Tarefa(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        descricao: descricao ?? this.descricao,
        dataVencimento: dataVencimento ?? this.dataVencimento,
        prioridade: prioridade ?? this.prioridade,
        concluida: concluida ?? this.concluida,
      );

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'dataVencimento': dataVencimento.toIso8601String(),
        'prioridade': prioridade,
        'concluida': concluida,
      };

  factory Tarefa.fromMap(String id, Map<dynamic, dynamic> map) => Tarefa(
        id: id,
        titulo: (map['titulo'] ?? '').toString(),
        descricao: (map['descricao'] ?? '').toString(),
        dataVencimento:
            DateTime.tryParse((map['dataVencimento'] ?? '').toString()) ??
                DateTime.now(),
        prioridade: (map['prioridade'] ?? 'Média').toString(),
        concluida: map['concluida'] == true,
      );
}
