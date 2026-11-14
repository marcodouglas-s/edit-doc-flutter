import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthViewModel _auth = AuthViewModel();
  final DocumentosViewModel _documentosVM = DocumentosViewModel();

  String? _usuarioId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_usuarioId != null) return;

    final argumentos = ModalRoute.of(context)?.settings.arguments;

    if (argumentos is String && argumentos.isNotEmpty) {
      _usuarioId = argumentos;
    } else {
      // Ex.: página recarregada (F5): usa a sessão salva
      _usuarioId = _auth.usuarioAtual?.id;
    }

    if (_usuarioId != null) {
      _documentosVM.carregarDocumentos(_usuarioId!);
    }
  }

  @override
  void dispose() {
    _documentosVM.dispose();
    super.dispose();
  }

  Future<void> _abrirEditor({Documento? documento}) async {
    if (_usuarioId == null) return;

    final resultado = await Navigator.pushNamed(
      context,
      '/editor',
      arguments: documento ?? _usuarioId,
    );

    if (!mounted) return;

    if (resultado == true) {
      await _documentosVM.carregarDocumentos(_usuarioId!);
    }
  }

  Future<void> _confirmarExclusao(Documento documento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text('Deseja excluir "${documento.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || _usuarioId == null) return;

    await _documentosVM.excluirDocumento(documento.id, _usuarioId!);
  }

  Future<void> _sair() async {
    await _auth.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: _auth,
            builder: (context, child) {
              return IconButton(
                tooltip:
                    _auth.temaEscuro ? 'Tema claro' : 'Tema escuro',
                icon: Icon(
                  _auth.temaEscuro
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: _auth.alternarTema,
              );
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      body: _usuarioId == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Usuário não identificado. Faça login novamente.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                    child: const Text('Ir para o login'),
                  ),
                ],
              ),
            )
          : ListenableBuilder(
              listenable: _documentosVM,
              builder: (context, child) {
                if (_documentosVM.carregando) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_documentosVM.erro != null) {
                  return Center(
                    child: Text(_documentosVM.erro!),
                  );
                }

                final documentos = _documentosVM.documentos;

                if (documentos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum documento encontrado.\n'
                      'Clique em Novo documento para começar!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documentos.length,
                  itemBuilder: (context, indice) {
                    final documento = documentos[indice];

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.deepPurple,
                        ),
                        title: Text(documento.titulo),
                        subtitle: Text(
                          documento.conteudo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _abrirEditor(
                          documento: documento,
                        ),
                        trailing: IconButton(
                          tooltip: 'Excluir documento',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              _confirmarExclusao(documento),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Novo documento'),
      ),
    );
  }
}