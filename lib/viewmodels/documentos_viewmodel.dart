
import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../models/services/banco_local_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final BancoLocalService _banco = BancoLocalService();

  List<Documento> _documentos = [];
  bool _carregando = false;
  String? _erro;

  List<Documento> get documentos =>
      List.unmodifiable(_documentos);

  bool get carregando => _carregando;
  String? get erro => _erro;

  // Listar documentos do usuario
  Future<void> carregarDocumentos(String usuarioId) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final todos = await _banco.listarDocumentos();

      _documentos = todos
          .where((doc) => doc.usuarioId == usuarioId)
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar documentos';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // Criar documento
  Future<bool> criarDocumento(Documento documento) async {
    try {
      _erro = null;
      await _banco.criarDocumento(documento);
      await carregarDocumentos(documento.usuarioId);
      return _erro == null;
    } catch (e) {
      _erro = 'Erro ao criar documento';
      notifyListeners();
      return false;
    }
  }

  // Atualizar documento
  Future<bool> atualizarDocumento(Documento documento) async {
    try {
      _erro = null;
      await _banco.atualizarDocumento(documento);
      await carregarDocumentos(documento.usuarioId);
      return _erro == null;
    } catch (e) {
      _erro = 'Erro ao atualizar documento';
      notifyListeners();
      return false;
    }
  }

  // Excluir documento
  Future<bool> excluirDocumento(
    String id,
    String usuarioId,
  ) async {
    try {
      _erro = null;
      final pertenceAoUsuario = _documentos.any(
        (doc) => doc.id == id && doc.usuarioId == usuarioId,
      );

      if (!pertenceAoUsuario) {
        _erro = 'Documento nao encontrado';
        notifyListeners();
        return false;
      }

      await _banco.excluirDocumento(id);
      await carregarDocumentos(usuarioId);
      return _erro == null;
    } catch (e) {
      _erro = 'Erro ao excluir documento';
      notifyListeners();
      return false;
    }
  }
}
