import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../documento.dart';

class DocumentoStorageService {
  static const String _chaveDocumentos = 'documentos';

  // READ: todos os documentos
  Future<List<Documento>> listarDocumentos() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveDocumentos);

    if (dados == null) return [];

    final lista = jsonDecode(dados) as List<dynamic>;

    return lista
        .map((item) => Documento.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  // READ: documentos de um usuário
  Future<List<Documento>> listarPorUsuario(String usuarioId) async {
    final todos = await listarDocumentos();
    return todos.where((doc) => doc.usuarioId == usuarioId).toList();
  }

  // CREATE
  Future<void> criarDocumento(Documento documento) async {
    final documentos = await listarDocumentos();
    documentos.add(documento);
    await _salvar(documentos);
  }

  // UPDATE
  Future<void> atualizarDocumento(Documento documento) async {
    final documentos = await listarDocumentos();

    final indice = documentos.indexWhere(
      (item) => item.id == documento.id,
    );

    if (indice == -1) {
      throw Exception('Documento não encontrado');
    }

    documentos[indice] = documento;
    await _salvar(documentos);
  }

  // DELETE
  Future<void> excluirDocumento(String id) async {
    final documentos = await listarDocumentos();
    documentos.removeWhere((documento) => documento.id == id);
    await _salvar(documentos);
  }

  Future<void> _salvar(List<Documento> documentos) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = documentos.map((doc) => doc.toJson()).toList();

    await prefs.setString(_chaveDocumentos, jsonEncode(dados));
  }
}