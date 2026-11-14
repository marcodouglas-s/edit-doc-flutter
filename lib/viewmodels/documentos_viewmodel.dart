import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storage = DocumentoStorageService();

  List<Documento> _documentos = [];
  bool _carregando = false;
  bool _salvando = false;
  String? _erro;

  List<Documento> get documentos => List.unmodifiable(_documentos);

  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;

  // READ
  Future<void> carregarDocumentos(String usuarioId) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _documentos = await _storage.listarPorUsuario(usuarioId);
    } catch (e) {
      _erro = 'Erro ao carregar documentos';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // CREATE
  Future<bool> criarDocumento(Documento documento) async {
    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      await _storage.criarDocumento(documento);
      await carregarDocumentos(documento.usuarioId);
      return _erro == null;
    } catch (e) {
      _erro = 'Erro ao criar documento';
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  // UPDATE
  Future<bool> atualizarDocumento(Documento documento) async {
    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      await _storage.atualizarDocumento(documento);
      await carregarDocumentos(documento.usuarioId);
      return _erro == null;
    } catch (e) {
      _erro = 'Erro ao atualizar documento';
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<bool> excluirDocumento(String id, String usuarioId) async {
    try {
      _erro = null;

      final pertenceAoUsuario = _documentos.any(
        (doc) => doc.id == id && doc.usuarioId == usuarioId,
      );

      if (!pertenceAoUsuario) {
        _erro = 'Documento não encontrado';
        notifyListeners();
        return false;
      }

      await _storage.excluirDocumento(id);
      await carregarDocumentos(usuarioId);
      return _erro == null;
    } catch (e) {
      _erro = 'Erro ao excluir documento';
      notifyListeners();
      return false;
    }
  }
}