
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';
import '../documento.dart';

class BancoLocalService {
  static const String _chaveUsuarios = 'usuarios';
  static const String _chaveDocumentos = 'documentos';

  // Salvar lista de usuários
  Future<void> salvarUsuarios(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = usuarios.map((u) => u.toJson()).toList();

    await prefs.setString(
      _chaveUsuarios,
      jsonEncode(dados),
    );
  }

  // Recuperar lista de usuários
  Future<List<Usuario>> listarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_chaveUsuarios);

    if (dados == null) return [];

    final lista = jsonDecode(dados) as List<dynamic>;

    return lista
        .map((item) => Usuario.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  // Salvar lista de documentos
  Future<void> salvarDocumentos(
    List<Documento> documentos,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = documentos
        .map((documento) => documento.toJson())
        .toList();

    await prefs.setString(
      _chaveDocumentos,
      jsonEncode(dados),
    );
  }

  // Listar todos os documentos
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

  // Criar documento
  Future<void> criarDocumento(Documento documento) async {
    final documentos = await listarDocumentos();

    documentos.add(documento);

    await salvarDocumentos(documentos);
  }

  // Atualizar documento existente
  Future<void> atualizarDocumento(
    Documento documento,
  ) async {
    final documentos = await listarDocumentos();

    final indice = documentos.indexWhere(
      (item) => item.id == documento.id,
    );

    if (indice == -1) {
      throw Exception('Documento não encontrado');
    }

    documentos[indice] = documento;

    await salvarDocumentos(documentos);
  }

  // Excluir documento
  Future<void> excluirDocumento(String id) async {
    final documentos = await listarDocumentos();

    documentos.removeWhere(
      (documento) => documento.id == id,
    );

    await salvarDocumentos(documentos);
  }
}
