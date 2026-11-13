
import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../viewmodels/documentos_viewmodel.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();

  final DocumentosViewModel _documentosVM =
      DocumentosViewModel();

  String? _usuarioId;
  bool _salvando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final argumentos =
        ModalRoute.of(context)?.settings.arguments;

    if (argumentos is String) {
      _usuarioId = argumentos;
    }
  }

  Future<void> _salvarDocumento() async {
    final titulo = _tituloController.text.trim();
    final conteudo = _conteudoController.text.trim();

    if (titulo.isEmpty || conteudo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha o título e o conteúdo',
          ),
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

    setState(() {
      _salvando = true;
    });

    final agora = DateTime.now();

    final documento = Documento(
      id: agora.microsecondsSinceEpoch.toString(),
      usuarioId: _usuarioId!,
      titulo: titulo,
      conteudo: conteudo,
      dataCriacao: agora,
      dataAtualizacao: agora,
    );

    final sucesso =
        await _documentosVM.criarDocumento(documento);

    if (!mounted) return;

    setState(() {
      _salvando = false;
    });

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _documentosVM.erro ??
                'Erro ao salvar documento',
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
        title: const Text('Editor de Documentos'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 750,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
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
                    textAlignVertical:
                        TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo',
                      hintText:
                          'Escreva seu documento...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: _salvando
                      ? null
                      : _salvarDocumento,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _salvando
                        ? 'Salvando...'
                        : 'Salvar documento',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
