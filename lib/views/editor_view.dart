import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();

  final DocumentosViewModel _documentosVM = DocumentosViewModel();

  String? _usuarioId;
  Documento? _documento; // null = novo documento
  bool _inicializado = false;

  bool get _editando => _documento != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_inicializado) return;
    _inicializado = true;

    final argumentos = ModalRoute.of(context)?.settings.arguments;

    if (argumentos is Documento) {
      // Edição: recebeu o documento selecionado
      _documento = argumentos;
      _usuarioId = argumentos.usuarioId;
      _tituloController.text = argumentos.titulo;
      _conteudoController.text = argumentos.conteudo;
    } else if (argumentos is String && argumentos.isNotEmpty) {
      // Criação: recebeu o id do usuário
      _usuarioId = argumentos;
    } else {
      // Ex.: página recarregada (F5): usa a sessão salva
      _usuarioId = AuthViewModel().usuarioAtual?.id;
    }
  }

  Future<void> _salvarDocumento() async {
    final titulo = _tituloController.text.trim();
    final conteudo = _conteudoController.text.trim();

    if (titulo.isEmpty || conteudo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o título e o conteúdo'),
        ),
      );
      return;
    }

    if (_usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não identificado'),
        ),
      );
      return;
    }

    final agora = DateTime.now();

    final bool sucesso;

    if (_editando) {
      final atualizado = Documento(
        id: _documento!.id,
        usuarioId: _documento!.usuarioId,
        titulo: titulo,
        conteudo: conteudo,
        dataCriacao: _documento!.dataCriacao,
        dataAtualizacao: agora,
      );

      sucesso = await _documentosVM.atualizarDocumento(atualizado);
    } else {
      final novo = Documento(
        id: agora.microsecondsSinceEpoch.toString(),
        usuarioId: _usuarioId!,
        titulo: titulo,
        conteudo: conteudo,
        dataCriacao: agora,
        dataAtualizacao: agora,
      );

      sucesso = await _documentosVM.criarDocumento(novo);
    }

    if (!mounted) return;

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _documentosVM.erro ?? 'Erro ao salvar documento',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _documentosVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editando ? 'Editar documento' : 'Novo documento',
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título do documento',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TextField(
                    controller: _conteudoController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo',
                      hintText: 'Escreva seu documento...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListenableBuilder(
                  listenable: _documentosVM,
                  builder: (context, child) {
                    final salvando = _documentosVM.salvando;

                    return FilledButton.icon(
                      onPressed: salvando ? null : _salvarDocumento,
                      icon: salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        salvando
                            ? 'Salvando...'
                            : (_editando
                                ? 'Salvar alterações'
                                : 'Salvar documento'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}