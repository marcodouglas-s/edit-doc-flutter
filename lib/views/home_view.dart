
import 'package:flutter/material.dart';

import '../viewmodels/documentos_viewmodel.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final DocumentosViewModel _documentosVM =
      DocumentosViewModel();

  String? _usuarioId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_usuarioId != null) return;

    final argumentos =
        ModalRoute.of(context)?.settings.arguments;

    if (argumentos is String && argumentos.isNotEmpty) {
      _usuarioId = argumentos;

      _documentosVM.carregarDocumentos(_usuarioId!);
    }
  }

  @override
  void dispose() {
    _documentosVM.dispose();
    super.dispose();
  }

  
Future<void> _abrirEditor() async {
  if (_usuarioId == null) return;

  final resultado = await Navigator.pushNamed(
    context,
    '/editor',
    arguments: _usuarioId,
  );

  if (!mounted) return;

  if (resultado == true) {
    await _documentosVM.carregarDocumentos(
      _usuarioId!,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        centerTitle: true,
      ),
      body: _usuarioId == null
          ? const Center(
              child: Text(
                'Usuário não identificado. Faça login novamente.',
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
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/editor',
                            arguments: _usuarioId,
                          );
                        },
                        trailing: IconButton(
                          tooltip: 'Excluir documento',
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                          onPressed: () async {
                            await _documentosVM.excluirDocumento(
                              documento.id,
                              _usuarioId!,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirEditor,
        icon: const Icon(Icons.add),
        label: const Text('Novo documento'),
      ),
    );
  }
}
