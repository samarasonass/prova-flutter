import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

/// Serve para cadastro (tarefa == null) e edição (tarefa != null).
class CadastroTarefaScreen extends StatefulWidget {
  final Tarefa? tarefa;
  const CadastroTarefaScreen({super.key, this.tarefa});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  late DateTime _data;
  late String _prioridade;
  late bool _concluida;
  bool _salvando = false;

  bool get _edicao => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _titulo = TextEditingController(text: t?.titulo ?? '');
    _descricao = TextEditingController(text: t?.descricao ?? '');
    _data = t?.dataVencimento ?? DateTime.now();
    _prioridade = t?.prioridade ?? 'Média';
    _concluida = t?.concluida ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final usuario = AuthService().usuarioAtual;
    if (usuario == null) return;
    setState(() => _salvando = true);
    try {
      final tarefa = Tarefa(
        id: widget.tarefa?.id ?? '',
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        dataVencimento: _data,
        prioridade: _prioridade,
        concluida: _concluida,
      );
      await FirebaseService().salvar(usuario.uid, tarefa);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Tarefa(titulo: '', dataVencimento: _data).dataFormatada;
    return Scaffold(
      appBar: AppBar(title: Text(_edicao ? 'Editar tarefa' : 'Nova tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricao,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _escolherData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Data de vencimento',
                      suffixIcon: Icon(Icons.calendar_today)),
                  child: Text(d),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _prioridade,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: Tarefa.prioridades
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _prioridade = v!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Situação'),
                subtitle: Text(_concluida ? 'Concluída' : 'Pendente'),
                value: _concluida,
                onChanged: (v) => setState(() => _concluida = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_edicao ? 'Salvar alterações' : 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
